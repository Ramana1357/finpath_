import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Added Dart SDK
import '../models/cloud_transaction.dart';
import '../models/cloud_insight.dart';

class CloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Bridge to Python/Kotlin
  static const _pythonChannel = MethodChannel('com.finpath.python');
  
  // Gemini Configuration (Dart)
  static const String _geminiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Stream of transactions from Firestore for the current user
  Stream<List<CloudTransaction>> getTransactionsStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    print("Fetching cloud transactions for UID: $uid"); // DEBUG

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          print("Received ${snapshot.docs.length} docs from Firestore"); // DEBUG
          final txs = snapshot.docs
              .map((doc) => CloudTransaction.fromFirestore(doc))
              .toList();
          
          // Sort in memory instead to avoid Firestore index errors
          txs.sort((a, b) => b.date.compareTo(a.date));
          return txs;
        });
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

  /// Trigger analysis based on recent activity (Automatic)
  Future<void> runAutoAnalysis(List<CloudTransaction> transactions) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || transactions.isEmpty) return;

    try {
      final txData = transactions.map((tx) => {
        "title": tx.title,
        "amount": tx.amount,
        "isExpense": tx.isExpense,
        "date": tx.date.toIso8601String()
      }).toList();

      // 1. Get raw stats from Python (Pure Math, very fast)
      final String pyResultJson = await _pythonChannel.invokeMethod('runInsights', {
        'transactions': jsonEncode(txData),
        'physicalCash': 0.0,
      });
      final Map<String, dynamic> pyStats = jsonDecode(pyResultJson);

      if (pyStats['status'] == 'success') {
        // 2. Generate coaching cards using Dart Google AI SDK (Low Cost)
        final feedSummaries = await _generateDartAiCoach(pyStats);

        // 3. Update Firestore
        await _db.collection('insights').doc(uid).set({
          "health_score": pyStats['health_score'],
          "feed_summaries": feedSummaries,
          "lastUpdated": FieldValue.serverTimestamp(),
          "status": "AI Updated (Dart SDK)"
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Analysis Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _generateDartAiCoach(Map<String, dynamic> stats) async {
    try {
      // Reverting to the most standard 1.5-flash which has the highest free tier quota
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiKey);
      
      // DEBUG: List available models to console
      // Note: This requires the listModels API which might not be directly in the simple GenerativeModel class
      // but we can try to see what's available or just try the most common names.
      
      final prompt = """
      Role: Witty financial coach for a college student.
      Stats: Income: ${stats['income']}, Expenses: ${stats['expenses']}, Categories: ${stats['categories']}.
      Task: Create 2 short, catchy coaching cards.
      Output format: JSON list of objects.
      Keys: "type" (positive, warning, alert), "title", "message" (max 12 words).
      No markdown, just raw JSON.
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      String text = response.text?.trim() ?? "[]";
      
      // Basic cleaning in case AI returns markdown
      if (text.contains("```json")) {
        text = text.split("```json")[1].split("```")[0].trim();
      } else if (text.contains("```")) {
        text = text.split("```")[1].split("```")[0].trim();
      }

      return List<Map<String, dynamic>>.from(jsonDecode(text));
    } catch (e) {
      print("Dart AI Error: $e");
      return [{"type": "neutral", "title": "Focus On Spending", "message": "Keep logging your spends to get smart AI tips."}];
    }
  }

  Future<void> updatePhysicalCash(double amount) async {
    // ... logic remains same, but trigger auto analysis after audit
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('audits').doc(uid).set({'cash_on_hand': amount, 'last_updated': FieldValue.serverTimestamp()});
    // Trigger analysis with the current transactions
    final snapshot = await _db.collection('transactions').where('userId', isEqualTo: uid).get();
    final txs = snapshot.docs.map((doc) => CloudTransaction.fromFirestore(doc)).toList();
    await runAutoAnalysis(txs);
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
