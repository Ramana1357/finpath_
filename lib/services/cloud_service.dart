import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';

class CloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Bridge to Python/Kotlin
  static const _pythonChannel = MethodChannel('com.finpath.python');
  
  // Stream of transactions from Firestore for the current user
  Stream<List<ExpenseTransaction>> getTransactionsStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    // debugPrint("Fetching cloud transactions for UID: $uid"); // DEBUG

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          // debugPrint("Received ${snapshot.docs.length} docs from Firestore"); // DEBUG
          final txs = snapshot.docs
              .map((doc) => ExpenseTransaction.fromFirestore(doc.data()))
              .toList();
          
          // Sort in memory instead to avoid Firestore index errors
          txs.sort((a, b) => b.date.compareTo(a.date));
          return txs;
        });
  }

  // Stream of insights
  Stream<Map<String, dynamic>?> getInsightsStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _db.collection('insights').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }

  Future<void> updateUserProfile(String name, String bio) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'displayName': name,
      'bio': bio,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getUserProfileStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Updates the user's streak based on their last activity.
  /// This should be called when the app is opened or when a transaction is logged.
  Future<void> updateStreak() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = _db.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    
    // Create doc if it doesn't exist (e.g. new user)
    if (!snapshot.exists) {
      await userDoc.set({
        'streak': 1,
        'lastActive': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
    int currentStreak = data['streak'] ?? 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActive != null) {
      final lastActiveDate = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final difference = today.difference(lastActiveDate).inDays;

      if (difference == 1) {
        // Increment streak if last active was yesterday
        currentStreak++;
      } else if (difference > 1) {
        // Reset streak if last active was more than a day ago
        currentStreak = 1;
      } else if (difference == 0) {
        // Same day, update lastSeen but don't touch streak logic
        await userDoc.update({'lastSeen': FieldValue.serverTimestamp()});
        return; 
      }
    } else {
      currentStreak = 1;
    }

    await userDoc.set({
      'streak': currentStreak,
      'lastActive': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
