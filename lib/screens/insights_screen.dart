import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/local_cache_service.dart';
import '../services/cloud_service.dart';
import '../models/cloud_insight.dart';
import 'profile_screen.dart';
import 'dart:math';

// --- LOCAL CALCULATOR HELPER ---
class LocalHealthCalculator {
  static Map<String, dynamic> calculate(List<ExpenseTransaction> transactions) {
    if (transactions.isEmpty) {
      print("DEBUG: No transactions found in Isar for Insights.");
      return {'score': 0, 'savingsRate': 0.0, 'categories': <Map<String, dynamic>>[]};
    }

    // Filter for CURRENT MONTH only to match Dashboard
    final now = DateTime.now();
    final currentMonthTransactions = transactions.where((tx) => 
      tx.date.month == now.month && tx.date.year == now.year
    ).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryMap = {};

    for (var tx in currentMonthTransactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
        categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    // Basic Health Score: (Savings / Income) * 100
    double score = 0;
    double savings = totalIncome - totalExpense;
    double savingsRate = 0;

    print("DEBUG: Insights Calculation (Current Month: ${now.month}/${now.year})");
    print("DEBUG: Count: ${currentMonthTransactions.length}, Total Income: $totalIncome, Total Expense: $totalExpense");

    if (totalIncome > 0) {
      savingsRate = (savings / totalIncome);
      // Clamp between 0 and 1 for the score
      score = (savingsRate.clamp(0.0, 1.0) * 100);
      print("DEBUG: Savings Rate: ${(savingsRate * 100).toStringAsFixed(1)}%, Score: $score");
    } else {
      // If no income this month, score is based on spending volume vs a 'warning' threshold
      score = max(0, 50 - (totalExpense / 1000)).toDouble();
      print("DEBUG: No income this month. Score: $score");
    }

    var sortedCats = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var topCategories = sortedCats.take(3).map((e) => {
      'category': e.key,
      'amount': e.value,
      'percentage': totalExpense > 0 ? (e.value / totalExpense * 100).toInt() : 0,
    }).toList();

    return {
      'score': score.toInt(),
      'savingsRate': savingsRate,
      'categories': topCategories,
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
    };
  }
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final CloudService _cloudService = CloudService();
  String _selectedStrategy = "50/30/20";
  final List<String> _strategies = ["50/30/20", "Zero-Based", "Envelope"];

  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentTeal = Color(0xFF83C5BE);

  @override
  Widget build(BuildContext context) {
    final cacheService = context.read<LocalCacheService>();

    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              StreamBuilder<List<ExpenseTransaction>>(
                stream: cacheService.watchTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final transactions = snapshot.data ?? [];
                  final localStats = LocalHealthCalculator.calculate(transactions);

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHealthScoreCard(localStats),
                        const SizedBox(height: 25),
                        _buildStrategySelector(),
                        const SizedBox(height: 25),
                        _buildRealtimeCategories(localStats['categories'] as List),
                        const SizedBox(height: 25),
                        // Keep AI Insights as a secondary cloud-powered section
                        StreamBuilder<CloudInsight?>(
                          stream: _cloudService.getInsightsStream(),
                          builder: (context, cloudSnapshot) {
                            final insight = cloudSnapshot.data;
                            if (insight == null) return const SizedBox.shrink();
                            
                            return Column(
                              children: [
                                if (insight.anomalies.isNotEmpty) ...[
                                  _buildAnomaliesCard(insight),
                                  const SizedBox(height: 25),
                                ],
                                _buildEndOfWeekCheckCard(insight),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final String initials = profile?.name != null && profile!.name.isNotEmpty 
        ? profile.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'JD';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _primaryTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FINPATH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: _accentTeal,
                  child: Text(initials, style: const TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _strategies.map((strategy) {
          bool isSelected = _selectedStrategy == strategy;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStrategy = strategy),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  strategy,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Analysis Pending", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryTeal)),
          const SizedBox(height: 10),
          const Text("Our Python engine is calculating your insights.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(Map<String, dynamic> stats) {
    final int score = stats['score'];
    final double savingsRate = stats['savingsRate'] ?? 0.0;
    Color scoreColor = score > 70 ? Colors.green : (score > 40 ? Colors.orange : Colors.red);

    String message = "";
    if (score > 80) {
      message = "Excellent! You're saving ${(savingsRate * 100).toInt()}% of your income.";
    } else if (score > 60) {
      message = "Good job. You're living within your means.";
    } else if (score > 0) {
      message = "Warning: Your expenses are high relative to your income.";
    } else {
      message = "Critical: You are spending more than you earn.";
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Financial Health Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: scoreColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Text("$score/100", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: _backgroundGray,
            color: scoreColor,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeCategories(List<dynamic> categories) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Spending Areas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal)),
          const SizedBox(height: 20),
          if (categories.isEmpty) 
            const Text("No expenses recorded yet.", style: TextStyle(color: Colors.grey)),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("₹${(cat['amount'] as double).toInt()} (${cat['percentage']}%)", style: const TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: cat['percentage'] / 100,
                  backgroundColor: _backgroundGray,
                  color: _accentTeal,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAnomaliesCard(CloudInsight insight) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Spending Alerts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          ...insight.anomalies.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "• High transaction: ₹${a.amount.toInt()} at ${a.title} on ${a.date}",
              style: const TextStyle(fontSize: 13, color: Colors.redAccent),
            ),
          )),
        ],
      ),
    );
  }

  void _showPhysicalCashAuditDialog() {
    final TextEditingController cashController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Physical Cash Audit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("To give you a 100% accurate financial picture, we need to know your actual physical cash on hand."),
            const SizedBox(height: 15),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Current Physical Cash (₹)",
                border: OutlineInputBorder(),
                prefixText: "₹ ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double? amount = double.tryParse(cashController.text);
              if (amount != null) {
                await _cloudService.updatePhysicalCash(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Audit submitted! Python is re-calculating..."), backgroundColor: _primaryTeal),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal, foregroundColor: Colors.white),
            child: const Text("Submit Audit"),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfWeekCheckCard(CloudInsight insight) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: _backgroundGray,
                child: Icon(Icons.account_balance_wallet_outlined, color: _primaryTeal),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cash Reconciliation",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      insight.physicalCashBalance > 0 
                        ? "Last reported cash: ₹${insight.physicalCashBalance.toInt()}"
                        : "Let's reconcile: How much physical cash do you actually have right now?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _showPhysicalCashAuditDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("Run Physical Cash Audit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
