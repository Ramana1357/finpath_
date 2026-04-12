import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/auth_user_model.dart';
import '../data/models/profile_model.dart';
import '../data/models/user_lifetime_log_model.dart';

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

  // Logs
  Future<void> saveLog(UserLifetimeLogModel log) async {
    await _db.collection('user_lifetime_logs').doc(log.logId).set(log.toMap());
  }

  // Check if profile exists
  Future<bool> profileExists(String uid) async {
    final doc = await _db.collection('profiles').doc(uid).get();
    return doc.exists;
  }
}
