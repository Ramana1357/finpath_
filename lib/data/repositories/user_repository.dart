import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_cache_service.dart';
import '../models/auth_user_model.dart';
import '../models/profile_model.dart';
import '../models/user_lifetime_log_model.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> logout(String uid) async {
    // Best effort logging
    final log = UserLifetimeLogModel(
      logId: const Uuid().v4(),
      uid: uid,
      eventType: 'logout',
      lifetimePoints: 0, // In a real app, fetch this from state
      categories: {'session_duration': 'unknown'},
      createdAt: DateTime.now(),
    );
    await _firestoreService.saveLog(log);
    
    await _cacheService.clearCache();
    await _authService.signOut();
  }
}
