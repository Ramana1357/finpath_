import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

// This line tells Isar to generate the background code for this file
part 'transaction.g.dart';

@collection
class ExpenseTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String txId; // Unique ID for Firebase sync
  
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
}
