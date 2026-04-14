import 'package:flutter/foundation.dart';

class ParsedSms {
  final double amount;
  final bool isExpense;
  final String title;

  ParsedSms({
    required this.amount, 
    required this.isExpense,
    this.title = 'SMS Transaction',
  });
}

class SmsParser {
  static ParsedSms parse(String message) {
    debugPrint("--- REBUILT REGEX ENGINE v2.0 ---");
    final String msg = message.toLowerCase();

    // 1. BANKING KEYWORDS (INDIAN CONTEXT)
    final List<String> expenseKeywords = [
      'debited', 'spent', 'paid', 'withdrawn', 'transfer to', 'vpa', 
      'purchase at', 'sent to', 'txn', 'payment of', 'used on'
    ];
    
    final List<String> incomeKeywords = [
      'credited', 'received', 'added', 'deposit', 'refund', 'transferred from', 'cashback'
    ];

    // 2. EXCLUSION FILTERS (OTP, Balance Checks)
    if (msg.contains('otp') || msg.contains('verification code') || msg.contains('login')) {
      return ParsedSms(amount: 0.0, isExpense: true);
    }
    
    // 3. FLEXIBLE AMOUNT REGEX
    // Catches: Rs. 500, INR 500, Rs500, ₹ 500.00, amt 1,200.50
    final RegExp amountRegex = RegExp(
      r'(?:rs\.?|inr|₹|amt|re\.?)\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    );

    final Match? match = amountRegex.firstMatch(msg);
    if (match == null) return ParsedSms(amount: 0.0, isExpense: true);

    String rawAmount = match.group(1) ?? "0";
    double amount = double.tryParse(rawAmount.replaceAll(',', '')) ?? 0.0;

    if (amount <= 0) return ParsedSms(amount: 0.0, isExpense: true);

    // 4. TRANSACTION TYPE DETECTION
    bool isExpense = true;
    
    // If it contains an income word, it's income
    if (incomeKeywords.any((k) => msg.contains(k))) {
      isExpense = false;
    } 
    // If it contains an expense word, it's definitely an expense
    else if (expenseKeywords.any((k) => msg.contains(k))) {
      isExpense = true;
    }
    // Safety check for balance alerts (don't log balance as transaction)
    if (msg.contains('balance') || msg.contains('bal:') || msg.contains('available limit')) {
      // If 'debited' or 'credited' is ALSO present, it's a txn, otherwise it's just an alert
      if (!msg.contains('debited') && !msg.contains('credited')) {
         return ParsedSms(amount: 0.0, isExpense: true);
      }
    }

    String typeLabel = isExpense ? "Expense" : "Income";
    debugPrint("DETECTED: $typeLabel of ₹$amount");
    
    return ParsedSms(
      amount: amount, 
      isExpense: isExpense,
      title: "Auto $typeLabel",
    );
  }
}
