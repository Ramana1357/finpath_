import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Query, Type;


// This line tells Isar to generate the background code for this file
part 'transaction.g.dart';

@collection
class ExpenseTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? txId; // Property type now matches constructor parameter type
  
  late String title;
  late double amount;
  late DateTime date;
  late bool isExpense;
  late String category;
  String? smsRawText;

  ExpenseTransaction({
    String? txId,
    this.title = '',
    this.amount = 0.0,
    required this.date,
    this.isExpense = true,
    this.category = 'General',
    this.smsRawText,
  }) : txId = txId ?? const Uuid().v4();

  factory ExpenseTransaction.fromFirestore(Map<String, dynamic> map) {
    return ExpenseTransaction(
      txId: map['txId'] as String?,
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp).toDate(),
      isExpense: map['isExpense'] ?? true,
      category: map['category'] ?? 'General',
      smsRawText: map['smsRawText'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'txId': txId,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'category': category,
      'smsRawText': smsRawText,
    };
  }
}
