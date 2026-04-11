import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Added for MethodChannel
import '../models/cloud_transaction.dart';
import '../models/cloud_insight.dart';

class CloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Bridge to Python/Kotlin
  static const _pythonChannel = MethodChannel('com.finpath.python');

  // Stream of transactions from Firestore for the current user
  Stream<List<CloudTransaction>> getTransactionsStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CloudTransaction.fromFirestore(doc))
            .toList());
  }

  // Stream of insights
  Stream<CloudInsight?> getInsightsStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _db.collection('insights').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CloudInsight.fromFirestore(doc);
    });
  }

  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }

  /// NEW: The Instant On-Device Analysis
  Future<void> updatePhysicalCash(double amount) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1. Update the Audit document in Firestore (Cloud)
    await _db.collection('audits').doc(uid).set({
      'cash_on_hand': amount,
      'last_updated': FieldValue.serverTimestamp(),
    });

    // 2. Trigger On-Device Calculation (Instant!)
    try {
      final snapshot = await _db.collection('transactions').where('userId', isEqualTo: uid).get();
      
      // Convert transactions to JSON for Python
      final txData = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "title": data['title'],
          "amount": data['amount'],
          "isExpense": data['isExpense'],
          "date": data['date']?.toString()
        };
      }).toList();

      final String pyResultJson = await _pythonChannel.invokeMethod('runInsights', {
        'transactions': jsonEncode(txData),
        'physicalCash': amount,
      });

      final Map<String, dynamic> result = jsonDecode(pyResultJson);
      
      if (result['status'] == 'success') {
        // Update the local insights document in Firestore so the UI updates instantly
        await _db.collection('insights').doc(uid).set({
          "health_score": result['health_score'],
          "physical_cash_balance": amount,
          "lastUpdated": FieldValue.serverTimestamp(),
          "status": "Updated Locally (Python)"
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Python Error: $e");
    }
  }
}
