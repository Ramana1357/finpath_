import 'package:flutter/foundation.dart';

class ParsedSms {
  final double amount;
  final bool isExpense;

  ParsedSms({required this.amount, required this.isExpense});
}

class SmsParser {
  static ParsedSms parse(String message) {
    debugPrint("--- SMS Parser Debug Start ---");
    debugPrint("Raw String: $message");

    // Convert everything to lowercase so we don't have to worry about capitalization
    String lowerMsg = message.toLowerCase();

    // 1. DETERMINE THE TYPE (Income vs Expense)
    bool isExpense = true;

    // If we see these happy words, it means money came IN!
    if (lowerMsg.contains('credited') || 
        lowerMsg.contains('received') || 
        lowerMsg.contains('added')) {
      isExpense = false;
    }

    // 2. EXTRACT THE AMOUNT (The Regex Magic)
    double extractedAmount = 0.0;

    // This pattern hunts for "rs", "rs.", "inr", "re.", or "₹", ignores any spaces,
    // and captures the numbers (including commas and decimals) right next to it.
    RegExp amountRegex = RegExp(r'(?:rs\.?|inr|₹|re\.?)\s*([\d,]+(?:\.\d{1,2})?)');
    Match? match = amountRegex.firstMatch(lowerMsg);

    if (match != null && match.group(1) != null) {
      String rawAmountStr = match.group(1)!;
      debugPrint("Regex Match Found: $rawAmountStr");

      // We found a number! Let's clean out any commas (like 1,500.00 -> 1500.00)
      String cleanAmountStr = rawAmountStr.replaceAll(',', '');
      debugPrint("Cleaned String for Parsing: $cleanAmountStr");

      // Convert it from text into real math numbers
      extractedAmount = double.tryParse(cleanAmountStr) ?? 0.0;
    } else {
      debugPrint("No Regex match found for amount.");
    }

    debugPrint("Final Extracted Amount: $extractedAmount");
    debugPrint("Is Expense: $isExpense");
    debugPrint("--- SMS Parser Debug End ---");

    return ParsedSms(amount: extractedAmount, isExpense: isExpense);
  }
}