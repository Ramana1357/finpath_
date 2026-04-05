import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  final List<ExpenseTransaction> transactions;
  final String statusMessage;
  final VoidCallback onGenerateId;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.statusMessage,
    required this.onGenerateId,
  });

  // Color Palette
  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);
  static const Color accentTeal = Color(0xFF83C5BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopStatsRow(),
                    const SizedBox(height: 25),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
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
              const CircleAvatar(
                backgroundColor: accentTeal,
                child: Text('JD', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
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
        _buildStatsCard('Pts', '1,580', Icons.emoji_events_outlined, Colors.orange[100]!),
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

  Widget _buildMonthlyOverviewCard() {
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
              Text('March 2024', style: TextStyle(color: Colors.blueGrey[300])),
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
                    const Text('₹5.0K', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('of ₹8.0K', style: TextStyle(color: Colors.grey[400])),
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
                text: const TextSpan(
                  children: [
                    TextSpan(text: '₹320 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(text: '/ ₹750 limit', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 8.0,
            percent: 0.43,
            center: const Text("43%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
            children: [
              transactions.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20), child: Text("No transactions logged yet."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: backgroundGray, child: Icon(Icons.sms_outlined, color: primaryTeal)),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tx.smsRawText ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text('₹${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryTeal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'Vault'),
        BottomNavigationBarItem(icon: Icon(Icons.chrome_reader_mode_outlined), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Insights'),
      ],
    );
  }
}