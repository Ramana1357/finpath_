import 'package:cloud_firestore/cloud_firestore.dart';

class CloudTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String? userId;

  CloudTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.userId,
  });

  factory CloudTransaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CloudTransaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      isExpense: data['isExpense'] ?? true,
      userId: data['userId'],
    );
  }
}
