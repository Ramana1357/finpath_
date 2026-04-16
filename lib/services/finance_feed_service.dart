import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/finance_tip_model.dart';
import '../models/quiz_model.dart';

class FinanceFeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FinanceTipModel>> getLatestTips() {
    return _firestore
        .collection('finance_feed')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTipModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<QuizModel?> getTodaysQuiz() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final query = await _firestore
        .collection('daily_quiz')
        .where('date_string', isEqualTo: today)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    
    return QuizModel.fromMap(query.docs.first.data());
  }
}
