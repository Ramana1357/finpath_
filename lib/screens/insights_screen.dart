import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import 'profile_screen.dart';
import '../services/cloud_service.dart';
import '../models/cloud_insight.dart';

// --- DATA MODEL ---
class BudgetCategoryModel {
  final String title;
  final int percentage;
  final double currentAmount;
  final double targetAmount;
  final String status;
  final Color color;

  BudgetCategoryModel({
    required this.title,
    required this.percentage,
    required this.currentAmount,
    required this.targetAmount,
    required this.status,
    required this.color,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
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
  void initState() {
    super.initState();
    // Debug: Print the user ID to help sync with Python script
    _cloudService.getUserId().then((uid) {
      print("DEBUG: InsightsScreen active for User ID: $uid");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              StreamBuilder<CloudInsight?>(
                stream: _cloudService.getInsightsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final insight = snapshot.data;
                  if (insight == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: _buildNoDataState(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHealthScoreCard(insight),
                        const SizedBox(height: 25),
                        _buildStrategySelector(),
                        const SizedBox(height: 25),
                        _buildRealtimeCategories(insight),
                        const SizedBox(height: 25),
                        if (insight.anomalies.isNotEmpty) ...[
                          _buildAnomaliesCard(insight),
                          const SizedBox(height: 25),
                        ],
                        _buildEndOfWeekCheckCard(insight),
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

  Widget _buildHealthScoreCard(CloudInsight insight) {
    Color scoreColor = insight.healthScore > 70 ? Colors.green : (insight.healthScore > 40 ? Colors.orange : Colors.red);

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
                child: Text("${insight.healthScore}/100", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: insight.healthScore / 100,
            backgroundColor: _backgroundGray,
            color: scoreColor,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Text(
            insight.healthScore > 70 
              ? "Excellent! You're saving more than 30% of your income." 
              : "Warning: Your expenses are high relative to your income.",
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeCategories(CloudInsight insight) {
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
          ...insight.topCategories.map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("₹${cat.amount.toInt()} (${cat.percentage}%)", style: const TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: cat.percentage / 100,
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
