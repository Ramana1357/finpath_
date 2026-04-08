import 'package:flutter/material.dart';
import 'profile_screen.dart';

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
  final int _daysUntilExhaust = 12;
  String _selectedStrategy = "50/30/20";
  final List<String> _strategies = ["50/30/20", "Zero-Based", "Envelope"];

  final List<BudgetCategoryModel> _budgetCategories = [
    BudgetCategoryModel(
      title: "Needs",
      percentage: 50,
      currentAmount: 2500,
      targetAmount: 3500,
      status: "",
      color: const Color(0xFF006D77),
    ),
    BudgetCategoryModel(
      title: "Wants",
      percentage: 30,
      currentAmount: 1900,
      targetAmount: 2000,
      status: "Near Limit",
      color: const Color(0xFFE9C46A),
    ),
    BudgetCategoryModel(
      title: "Savings",
      percentage: 20,
      currentAmount: 1500,
      targetAmount: 1500,
      status: "Complete",
      color: const Color(0xFF2A9D8F),
    ),
  ];

  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentTeal = Color(0xFF83C5BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForecastCard(),
                    const SizedBox(height: 25),
                    _buildStrategySelector(),
                    const SizedBox(height: 25),
                    _buildBudgetBreakdownCard(),
                    const SizedBox(height: 25),
                    _buildEndOfWeekCheckCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                child: const CircleAvatar(
                  backgroundColor: _accentTeal,
                  child: Text('JD', style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: _primaryTeal, size: 20),
              SizedBox(width: 10),
              Text(
                "Financial Health Forecast",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("Mar 22nd", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.yellow, Colors.red],
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.5,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Funds exhaust in $_daysUntilExhaust Days (Mar",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
          return Expanded( // Added Expanded to handle small screen widths
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
                    fontSize: 13, // Slightly reduced font size for safety
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Budget Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal),
          ),
          const SizedBox(height: 25),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _budgetCategories.length,
            itemBuilder: (context, index) {
              final cat = _budgetCategories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded( // Added Expanded to prevent overflow on title + status
                          child: Wrap( // Changed to Wrap to handle long labels
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "${cat.title} (${cat.percentage}%)",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (cat.status.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cat.status == "Complete" ? Colors.green[50] : Colors.red[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    cat.status,
                                    style: TextStyle(
                                      color: cat.status == "Complete" ? Colors.green : Colors.red,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.status == "Complete" 
                            ? "Goal Met: ₹${cat.currentAmount.toInt()}"
                            : "₹${cat.currentAmount.toInt().toString()} / ₹${cat.targetAmount.toInt().toString()}",
                          style: TextStyle(
                            color: cat.status == "Complete" ? Colors.green : Colors.blueGrey[300],
                            fontSize: 12,
                            fontWeight: cat.status == "Complete" ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: cat.progress,
                      backgroundColor: _backgroundGray,
                      color: cat.color,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfWeekCheckCard() {
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
                child: Icon(Icons.assignment_turned_in_outlined, color: _primaryTeal),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "End of Week Check",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Let's reconcile: How much physical cash do you actually have right now?",
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("Run Reverse Audit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
