import 'package:isar/isar.dart';

// This line tells Isar to generate the background code for this file
part 'transaction.g.dart';

@collection
class ExpenseTransaction {
  Id id = Isar.autoIncrement;

  late String title;
  late double amount;
  late DateTime date;
  late bool isExpense;
  late String category; // Added category
  String? smsRawText;

  ExpenseTransaction({
    this.title = '',
    this.amount = 0.0,
    DateTime? date,
    this.isExpense = true,
    this.category = 'General',
    this.smsRawText,
  }) : date = date ?? DateTime.now();
}