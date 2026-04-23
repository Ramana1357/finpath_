import 'package:flutter/foundation.dart';

class ParsedSms {
  final double amount;
  final bool isExpense;
  final String title;
  final String category;

  ParsedSms({
    required this.amount, 
    required this.isExpense,
    this.title = 'SMS Transaction',
    this.category = 'General',
  });
}

class SmsParser {
  static ParsedSms parse(String message) {
    debugPrint("--- REBUILT REGEX ENGINE v2.1 (Categorization) ---");
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

    String category = 'General';
    if (isExpense) {
      // Needs: food, groceries, rent, utilities, education, transport, health, bills
      if (msg.contains('swiggy') || msg.contains('zomato') || msg.contains('restaurant') || msg.contains('eats')) {
        category = 'dining'; // Default to wants for food delivery
      } else if (msg.contains('grocery') || msg.contains('blinkit') || msg.contains('zepto') || msg.contains('mart') || msg.contains('bigbasket')) {
        category = 'groceries';
      } else if (msg.contains('electricity') || msg.contains('bescom') || msg.contains('water') || msg.contains('gas') || msg.contains('recharge') || msg.contains('jio') || msg.contains('airtel')) {
        category = 'utilities';
      } else if (msg.contains('uber') || msg.contains('ola') || msg.contains('rapido') || msg.contains('metro') || msg.contains('fuel') || msg.contains('petrol') || msg.contains('shell')) {
        category = 'transport';
      } else if (msg.contains('rent') || msg.contains('maintenance')) {
        category = 'rent';
      } else if (msg.contains('hospital') || msg.contains('pharmacy') || msg.contains('medical') || msg.contains('apollo')) {
        category = 'health';
      } 
      // Wants: shopping, dining, entertainment, hobbies, subscriptions, travel, lifestyle
      else if (msg.contains('amazon') || msg.contains('flipkart') || msg.contains('myntra') || msg.contains('nykaa') || msg.contains('shopping')) {
        category = 'shopping';
      } else if (msg.contains('netflix') || msg.contains('prime') || msg.contains('hotstar') || msg.contains('spotify') || msg.contains('youtube')) {
        category = 'subscriptions';
      } else if (msg.contains('pvr') || msg.contains('inox') || msg.contains('bookmyshow') || msg.contains('cinema')) {
        category = 'entertainment';
      }
      // Savings: savings, vault, investment, emergency fund, insurance
      else if (msg.contains('mutual fund') || msg.contains('sip') || msg.contains('zerodha') || msg.contains('groww') || msg.contains('indmoney') || msg.contains('investment')) {
        category = 'investment';
      } else if (msg.contains('lic') || msg.contains('insurance') || msg.contains('premium')) {
        category = 'insurance';
      }
    }

    String typeLabel = isExpense ? "Expense" : "Income";
    debugPrint("DETECTED: $typeLabel of ₹$amount in category $category");
    
    return ParsedSms(
      amount: amount, 
      isExpense: isExpense,
      title: "Auto $typeLabel",
      category: category,
    );
  }
}
