import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/transaction.dart';
import 'profile_screen.dart'; // IMPORT ADDED HERE

class DashboardScreen extends StatelessWidget {
  final List<ExpenseTransaction> transactions;
  final String statusMessage;
  final VoidCallback onGenerateId;
  final int totalPoints; // Added this

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.statusMessage,
    required this.onGenerateId,
    this.totalPoints = 1580, // Default for backward compatibility
  });

  // Color Palette
  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);
  static const Color accentTeal = Color(0xFF83C5BE);

  // --- MATH HELPERS ---
  double _calculateTotalSpentThisMonth() {
    double total = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double _calculateTotalSpentToday() {
    double total = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.isExpense && tx.date.day == now.day && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context), // PASSED CONTEXT HERE FOR NAVIGATION
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopStatsRow(),
                    const SizedBox(height: 15),
                    _buildSyncStatus(), // Added this
                    const SizedBox(height: 15),
                    _buildMonthlyOverviewCard(),
                    const SizedBox(height: 20),
                    _buildTodaySpendingCard(),
                    const SizedBox(height: 20),
                    _buildRecentExpensesSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ADDED BuildContext context to this method so Navigator works
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: primaryTeal,
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
              // GESTURE DETECTOR ADDED HERE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: const CircleAvatar(
                  backgroundColor: accentTeal,
                  child: Text('JD', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatsCard('Out of Pocket', 'Mar 22nd', Icons.calendar_today, Colors.red[100]!),
        _buildStatsCard('Savings', '24% ↑', Icons.trending_up, Colors.green[100]!),
        _buildStatsCard('Pts', totalPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), Icons.emoji_events_outlined, Colors.orange[100]!),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color iconBg) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 18, backgroundColor: iconBg, child: Icon(icon, size: 18, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryTeal)),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return InkWell(
      onTap: onGenerateId,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: accentTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accentTeal.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_done_outlined, color: primaryTeal, size: 20),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cloud Connection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryTeal)),
                  Text(statusMessage, style: TextStyle(color: Colors.blueGrey[400], fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.refresh, color: primaryTeal, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyOverviewCard() {
    final double totalSpent = _calculateTotalSpentThisMonth();
    final double monthlyLimit = 8000.0; // Static for now, can be made dynamic later

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text('Monthly Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
              Text('April 2026', style: TextStyle(color: Colors.blueGrey[300])), // Updated to current month
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 180,
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(color: primaryTeal, value: 5, radius: 20, showTitle: false),
                      PieChartSectionData(color: accentTeal, value: 3, radius: 20, showTitle: false),
                      PieChartSectionData(color: Colors.grey[200], value: 2, radius: 20, showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Converts 5000 to 5.0K
                    Text('₹${(totalSpent / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('of ₹${(monthlyLimit / 1000).toStringAsFixed(1)}K', style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final categories = [
      {'name': 'Food & Dining', 'color': primaryTeal},
      {'name': 'Transport', 'color': accentTeal},
      {'name': 'Shopping', 'color': const Color(0xFF4ECDC4)},
      {'name': 'Entertainment', 'color': const Color(0xFF96E6B3)},
    ];
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: categories.map((c) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: c['color'] as Color),
          const SizedBox(width: 5),
          Text(c['name'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      )).toList(),
    );
  }

  Widget _buildTodaySpendingCard() {
    final double todaySpent = _calculateTotalSpentToday();
    final double dailyLimit = 750.0; // Static for now

    // Calculate percentage and cap it at 100% (1.0) to prevent the circle from overflowing
    double percent = dailyLimit > 0 ? todaySpent / dailyLimit : 0.0;
    if (percent > 1.0) percent = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Spending', style: TextStyle(color: Colors.blueGrey[300])),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '₹${todaySpent.toStringAsFixed(0)} ', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(text: '/ ₹${dailyLimit.toStringAsFixed(0)} limit', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text("${(percent * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            progressColor: primaryTeal,
            backgroundColor: backgroundGray,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection() {
    return Column(
      children: [
        Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: const Text('View Recent Logged Expenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            initiallyExpanded: true, // Auto-expand to show off the data
            children: [
              transactions.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20), child: Text("No transactions logged yet."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];

                  // UI Logic for Colors and Signs
                  final bool isExpense = tx.isExpense;
                  final String sign = isExpense ? '-' : '+';
                  final Color amountColor = isExpense ? Colors.redAccent : Colors.green;
                  final Color avatarBgColor = isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);
                  final IconData txIcon = isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

                  return ListTile(
                    leading: CircleAvatar(
                        backgroundColor: avatarBgColor,
                        child: Icon(txIcon, color: amountColor, size: 20)
                    ),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        isExpense ? 'Debit' : 'Credit',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)
                    ),
                    trailing: Text(
                        '$sign ₹${tx.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: amountColor, fontSize: 15)
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

/*Widget _buildBottomNav() {
    // ...
  }*/
}