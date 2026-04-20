import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/auth_user_model.dart';
import '../data/models/profile_model.dart';
import '../data/models/vault_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Auth Users
  Future<void> saveAuthUser(AuthUserModel user) async {
    await _db.collection('auth_users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AuthUserModel?> getAuthUser(String uid) async {
    final doc = await _db.collection('auth_users').doc(uid).get();
    if (doc.exists) {
      return AuthUserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Profiles
  Future<void> saveProfile(ProfileModel profile) async {
    await _db.collection('profiles').doc(profile.uid).set(profile.toMap());
  }

  Future<ProfileModel?> getProfile(String uid) async {
    final doc = await _db.collection('profiles').doc(uid).get();
    if (doc.exists) {
      return ProfileModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Vaults (Sub-collection under profile)
  Future<void> saveVaults(String uid, List<VaultModel> vaults) async {
    final batch = _db.batch();
    final vaultCollection = _db.collection('profiles').doc(uid).collection('vaults');

    // Clear existing remote vaults first to prevent duplicates/stale data
    final existingVaults = await vaultCollection.get();
    for (var doc in existingVaults.docs) {
      batch.delete(doc.reference);
    }

    for (var vault in vaults) {
      final docRef = vaultCollection.doc();
      batch.set(docRef, vault.toMap());
    }
    await batch.commit();
  }

  Future<List<VaultModel>> getVaults(String uid) async {
    final snapshot = await _db.collection('profiles').doc(uid).collection('vaults').get();
    return snapshot.docs.map((doc) => VaultModel.fromMap(doc.data())).toList();
  }

  // Check if profile exists
  Future<bool> profileExists(String uid) async {
    final doc = await _db.collection('profiles').doc(uid).get();
    return doc.exists;
  }

  // Transactions & Batch Helpers
  WriteBatch getBatch() => _db.batch();

  CollectionReference getTransactionsCollection() {
    return _db.collection('transactions');
  }
}
