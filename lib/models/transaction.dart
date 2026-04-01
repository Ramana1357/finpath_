import 'package:isar/isar.dart';

// This line tells Isar to generate the background code for this file
part 'transaction.g.dart';

@collection
class ExpenseTransaction {
  // Isar requires an ID. 'Isar.autoIncrement' automatically assigns a number (1, 2, 3...)
  Id id = Isar.autoIncrement;

  late String title; // e.g., "Amazon", "SBI ATM"

  late double amount; // e.g., 450.50

  late DateTime date; // The exact time it happened

  late bool isExpense; // True if money left your account, False if you received money

  String? smsRawText; // Optional: We will save the original bank SMS here later!
}