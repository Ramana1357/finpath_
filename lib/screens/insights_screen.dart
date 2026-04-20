import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/local_cache_service.dart';
import '../services/cloud_service.dart';
import 'profile_screen.dart';
import 'dart:math';

// --- LOCAL CALCULATOR HELPER ---
class LocalHealthCalculator {
  static Map<String, dynamic> calculate(List<ExpenseTransaction> transactions) {
    // FIXED: Strict guard clause for empty transactions
    if (transactions.isEmpty) {
      return {
        'score': 0, 
        'savingsRate': 0.0, 
        'categories': <Map<String, dynamic>>[],
        'totalExpense': 0.0,
        'totalIncome': 0.0,
        'isEmpty': true, // Added flag for UI rendering
      };
    }

    final now = DateTime.now();
    final currentMonthTransactions = transactions.where((tx) => 
      tx.date.month == now.month && tx.date.year == now.year
    ).toList();

    // FIXED: Secondary guard if current month has no data
    if (currentMonthTransactions.isEmpty) {
      return {
        'score': 0, 
        'savingsRate': 0.0, 
        'categories': <Map<String, dynamic>>[],
        'totalExpense': 0.0,
        'totalIncome': 0.0,
        'isEmpty': true,
      };
    }

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

    double score = 0;
    double savings = totalIncome - totalExpense;
    double savingsRate = 0;

    if (totalIncome > 0) {
      savingsRate = (savings / totalIncome);
      score = (savingsRate.clamp(0.0, 1.0) * 100);
    } else {
      score = max(0, 50 - (totalExpense / 1000)).toDouble();
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
      'isEmpty': false,
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

                  // FIXED: Strict guard clause at the top of UI builder
                  if (localStats['isEmpty'] == true) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                      child: _buildEmptyInsightsState(),
                    );
                  }

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
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: _cloudService.getInsightsStream(),
                          builder: (context, cloudSnapshot) {
                            final insight = cloudSnapshot.data;
                            if (insight == null) return const SizedBox.shrink();
                            
                            final anomalies = insight['anomalies'] as List? ?? [];

                            return Column(
                              children: [
                                if (anomalies.isNotEmpty) ...[
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

  Widget _buildEmptyInsightsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Start logging transactions to see your financial insights.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryTeal),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your spending behavior will appear here.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    
    // SAFE ACCESS
    String initials = 'JD';
    if (profile?.name != null && profile!.name.trim().isNotEmpty) {
      try {
        initials = profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').where((s) => s.isNotEmpty).take(2).join().toUpperCase();
        if (initials.isEmpty) initials = 'JD';
      } catch (e) {
        initials = 'JD';
      }
    }

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

  Widget _buildHealthScoreCard(Map<String, dynamic> stats) {
    final int score = stats['score'] ?? 0;
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
            const Text("No expenses recorded yet.", style: TextStyle(color: Colors.grey))
          else
            ...categories.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat['category'] ?? "Other", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${(cat['amount'] as double).toInt()} (${cat['percentage']}%)", style: const TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (cat['percentage'] as int) / 100,
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

  Widget _buildAnomaliesCard(Map<String, dynamic> insight) {
    final anomalies = insight['anomalies'] as List? ?? [];
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
          ...anomalies.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "• High transaction: ₹${a['amount'].toInt()} at ${a['title']} on ${a['date']}",
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

  Widget _buildEndOfWeekCheckCard(Map<String, dynamic> insight) {
    final physicalCashBalance = insight['physical_cash_balance'] ?? 0.0;
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
                      physicalCashBalance > 0 
                        ? "Last reported cash: ₹${physicalCashBalance.toInt()}"
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
