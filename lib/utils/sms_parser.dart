import 'package:flutter/foundation.dart';

class ParsedSms {
  final double amount;
  final bool isExpense;

  ParsedSms({required this.amount, required this.isExpense});
}

class SmsParser {
  static ParsedSms parse(String message) {
    debugPrint("--- ULTRA-STRICT Parser Start ---");
    debugPrint("Raw SMS: $message");

    String lowerMsg = message.toLowerCase();

    // 1. Define Strict Keywords (Added "sent" and refined verbs)
    List<String> expenseKeywords = ['debited', 'spent', 'paid', 'withdrawn', 'transfer to', 'payment', 'txn', 'sent'];
    List<String> incomeKeywords = ['credited', 'received', 'added', 'deposit', 'refund', 'transferred from'];
    List<String> balanceKeywords = ['bal', 'balance', 'avl', 'available', 'limit', 'closing', 'total'];

    // 2. Initial Filter: If no transaction words exist in the WHOLE message, ignore it.
    bool hasExpenseWord = expenseKeywords.any((kw) => lowerMsg.contains(kw));
    bool hasIncomeWord = incomeKeywords.any((kw) => lowerMsg.contains(kw));

    if (!hasExpenseWord && !hasIncomeWord) {
      debugPrint("STRICT REJECTION: No transaction keywords found in the entire message.");
      return ParsedSms(amount: 0.0, isExpense: true);
    }

    // 3. Regex to find potential amounts (\s* already handles infinite spaces perfectly!)
    RegExp amountRegex = RegExp(
        r'(?:(?:rs\.?|inr|₹|re\.?|amt\.?)\s*)([\d,]+(?:\.\d{1,2})?)|([\d,]+\.\d{1,2})',
        caseSensitive: false
    );

    Iterable<RegExpMatch> matches = amountRegex.allMatches(lowerMsg);
    double bestAmount = 0.0;
    int highestScore = -1;

    for (var match in matches) {
      String? rawMatch = match.group(1) ?? match.group(2);
      if (rawMatch == null) continue;

      double val = double.tryParse(rawMatch.replaceAll(',', '')) ?? 0.0;
      if (val <= 0) continue;

      int start = match.start;
      int end = match.end;

      // Extract Context: 30 chars before AND 30 chars after the number
      String beforeContext = lowerMsg.substring(start > 30 ? start - 30 : 0, start);
      String afterContext = lowerMsg.substring(end, (end + 30) < lowerMsg.length ? end + 30 : lowerMsg.length);

      String totalContext = beforeContext + " [AMOUNT] " + afterContext;

      // RULE 1: Hard Rejection if "Balance" appears immediately before the amount
      if (balanceKeywords.any((kw) => beforeContext.contains(kw))) {
        debugPrint("CANDIDATE REJECTED: $val is tagged as a Balance/Limit.");
        continue;
      }

      // RULE 2: Scoring logic
      int currentScore = 0;

      // Significant score boost if a transaction keyword is near this specific number
      if (expenseKeywords.any((kw) => totalContext.contains(kw)) ||
          incomeKeywords.any((kw) => totalContext.contains(kw))) {
        currentScore += 100;
      }

      // Minor score boost if there's a currency symbol (Rs/₹) attached
      if (match.group(1) != null) currentScore += 20;

      debugPrint("Candidate: $val | Score: $currentScore | Context: ...$totalContext...");

      if (currentScore > highestScore) {
        highestScore = currentScore;
        bestAmount = val;
      }
    }

    // Final Safety: If the best number found didn't have a transaction keyword near it, reject it.
    if (highestScore < 50) {
      debugPrint("STRICT REJECTION: Found a number, but it wasn't near a transaction keyword.");
      bestAmount = 0.0;
    }

    // Determine final type for the transaction (If it has an income word, it's income. Otherwise expense)
    bool finalIsExpense = !hasIncomeWord;

    debugPrint("FINAL DECISION: Amount: $bestAmount, IsExpense: $finalIsExpense");
    debugPrint("--- ULTRA-STRICT Parser End ---");

    return ParsedSms(amount: bestAmount, isExpense: finalIsExpense);
  }
}