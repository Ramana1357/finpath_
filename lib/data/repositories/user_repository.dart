import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_cache_service.dart';
import '../models/auth_user_model.dart';
import '../models/profile_model.dart';
import '../../models/transaction.dart';
import '../../services/cloud_service.dart';

class UserRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final LocalCacheService _cacheService;

  UserRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
    required LocalCacheService cacheService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _cacheService = cacheService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<bool> handleAuthResult(UserCredential? credential, AuthProvider provider) async {
    if (credential == null || credential.user == null) return false;

    final user = credential.user!;
    final existingAuth = await _firestoreService.getAuthUser(user.uid);

    if (existingAuth == null) {
      final authUser = AuthUserModel(
        uid: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        authProvider: provider,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        accountStatus: 'active',
      );
      await _firestoreService.saveAuthUser(authUser);
    } else {
      // Update last login
      final updatedAuth = AuthUserModel(
        uid: existingAuth.uid,
        email: existingAuth.email ?? user.email,
        phoneNumber: existingAuth.phoneNumber ?? user.phoneNumber,
        authProvider: existingAuth.authProvider,
        createdAt: existingAuth.createdAt,
        lastLoginAt: DateTime.now(),
        accountStatus: existingAuth.accountStatus,
      );
      await _firestoreService.saveAuthUser(updatedAuth);
    }

    return await _firestoreService.profileExists(user.uid);
  }

  Future<ProfileModel?> getProfile(String uid, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cacheService.getProfile(uid);
      if (cached != null) return cached;
    }

    final remote = await _firestoreService.getProfile(uid);
    if (remote != null) {
      await _cacheService.saveProfile(remote);
    }
    return remote;
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await _firestoreService.saveProfile(profile);
    await _cacheService.saveProfile(profile);
  }

  Future<void> saveTransaction(ExpenseTransaction transaction, {String? uid}) async {
    await _cacheService.saveTransaction(transaction);
    
    if (uid != null) {
      // 1. Trigger atomic income allocation if it's income
      if (!transaction.isExpense) {
        await _cacheService.performIncomeAllocation(uid, transaction.amount);
      }
      
      // 2. IMPORTANT: Sync the updated profile (potentially changed by Crisis Mode or Income Allocation) to Firestore
      final updatedProfile = await _cacheService.getProfile(uid);
      if (updatedProfile != null) {
        await _firestoreService.saveProfile(updatedProfile);
      }
    }
    
    // 3. Analysis is now handled by the Python backend asynchronously.
    // No longer triggering local analysis here.
  }

  Future<bool> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    return await handleAuthResult(credential, AuthProvider.google);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final credential = await _authService.signInWithEmail(email, password);
    return await handleAuthResult(credential, AuthProvider.emailPassword);
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    final credential = await _authService.signUpWithEmail(email, password);
    return await handleAuthResult(credential, AuthProvider.emailPassword);
  }

  Future<void> backupTransactions(String uid) async {
    final transactions = await _cacheService.getTransactionsForLastSixMonths();
    if (transactions.isEmpty) return;

    final batch = _firestoreService.getBatch();
    final collection = _firestoreService.getTransactionsCollection();

    for (final tx in transactions) {
      // Use txId as docId to prevent duplicates in Firestore
      final docRef = collection.doc(tx.txId);
      batch.set(docRef, {
        'txId': tx.txId,
        'userId': uid,
        'title': tx.title,
        'amount': tx.amount,
        'date': tx.date,
        'isExpense': tx.isExpense,
        'category': tx.category,
        'backedUpAt': DateTime.now(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> restoreTransactions(String uid) async {
    // 1. Fetch the latest remote profile to use its settings (emergencyPercent)
    final remoteProfile = await _firestoreService.getProfile(uid);
    if (remoteProfile == null) return;

    // 2. CRITICAL: Clear all local transactions and reset local savings before rebuilding
    await _cacheService.clearTransactions();
    final localProfile = await _cacheService.getProfile(uid);
    if (localProfile != null) {
      await _cacheService.saveProfile(localProfile.copyWith(
        totalLockedSavings: 0.0,
        totalVaultSavings: 0.0,
      ));
    }

    final snapshots = await _firestoreService.getTransactionsCollection()
        .where('userId', isEqualTo: uid)
        .get();

    double correctedTotalSavings = 0.0;
    
    // SMART DE-DUPLICATION: 
    // Uses a fingerprint of (Title + Amount + Date) to filter out duplicate records
    // that exist in Firestore with different IDs but identical content.
    final Set<String> contentHashes = {};

    for (final doc in snapshots.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      final String title = data['title'] ?? '';
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final DateTime date = (data['date'] as Timestamp).toDate();
      final bool isExpense = data['isExpense'] ?? true;
      
      // Create a unique fingerprint for this specific transaction
      final String fingerprint = "${title}_${amount}_${date.millisecondsSinceEpoch}";

      if (contentHashes.contains(fingerprint)) {
        continue; // Ignore duplicate data from previous buggy syncs
      }
      contentHashes.add(fingerprint);

      final tx = ExpenseTransaction(
        txId: data['txId'] ?? doc.id,
        title: title,
        amount: amount,
        date: date,
        isExpense: isExpense,
        category: data['category'] ?? 'General',
      );

      // Save to local Isar
      await _cacheService.saveTransaction(tx);

      // 3. Recalculate savings based ONLY on these unique, verified transactions
      if (!tx.isExpense) {
        correctedTotalSavings += (tx.amount * remoteProfile.emergencyPercent) / 100;
      }
    }

    // 4. Overwrite the profile's savings with the corrected, zero-based calculation
    final currentLocal = await _cacheService.getProfile(uid);
    final finalProfile = remoteProfile.copyWith(
      id: currentLocal?.id, // Ensure we update the existing Isar record
      totalLockedSavings: correctedTotalSavings,
      totalVaultSavings: 0.0, // Vaults will be empty until new income is logged
      updatedAt: DateTime.now(),
    );

    await saveProfile(finalProfile);

    // 5. Analysis is now handled by the Python backend asynchronously.
  }

  Future<void> clearLocalData(String uid) async {
    // 1. Wipe local Isar database completely
    await _cacheService.clearCache();

    // 2. Reset the source of truth (Firestore Profile) to zero savings
    final remoteProfile = await _firestoreService.getProfile(uid);
    if (remoteProfile != null) {
      final resetProfile = remoteProfile.copyWith(
        totalLockedSavings: 0.0,
        totalVaultSavings: 0.0,
        updatedAt: DateTime.now(),
      );
      // This updates both Firestore and the now-empty Local Cache
      await saveProfile(resetProfile);
    }
  }

  Future<void> logout(String uid, {bool shouldBackup = false}) async {
    if (shouldBackup) {
      await backupTransactions(uid);
    }
    
    // Explicitly reset savings to 0 on logout as requested
    final remoteProfile = await _firestoreService.getProfile(uid);
    if (remoteProfile != null) {
      final updatedProfile = remoteProfile.copyWith(
        totalLockedSavings: 0.0,
        totalVaultSavings: 0.0,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.saveProfile(updatedProfile);
    }

    // Clear local state
    await _cacheService.clearCache();
    await _authService.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }

  Future<bool> verifyPassword(String password) async {
    return await _authService.verifyPassword(password);
  }
}
