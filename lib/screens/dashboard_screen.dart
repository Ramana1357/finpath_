import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../presentation/providers/auth_provider.dart';
import 'profile_screen.dart';
import 'all_transactions_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Stream<List<ExpenseTransaction>> transactionsStream;
  final String statusMessage;
  final VoidCallback onGenerateId;
  final int totalPoints;
  final Function(int)? onSwitchTab;

  const DashboardScreen({
    super.key,
    required this.transactionsStream,
    required this.statusMessage,
    required this.onGenerateId,
    this.totalPoints = 1580,
    this.onSwitchTab,
  });

  // Color Palette
  static const Color primaryTeal = Color(0xFF006D77);
  static const Color backgroundGray = Color(0xFFEDF6F9);
  static const Color accentTeal = Color(0xFF83C5BE);

  // --- MATH HELPERS ---
  double _calculateTotalSpentThisMonth(List<ExpenseTransaction> transactions) {
    double total = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.isExpense && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double _calculateTotalSpentToday(List<ExpenseTransaction> transactions) {
    double total = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.isExpense && tx.date.day == now.day && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double _calculateTotalBalance(List<ExpenseTransaction> transactions) {
    double total = 0;
    for (var tx in transactions) {
      if (tx.isExpense) {
        total -= tx.amount;
      } else {
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
        child: StreamBuilder<List<ExpenseTransaction>>(
          stream: transactionsStream,
          builder: (context, snapshot) {
            final transactions = snapshot.data ?? [];
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildTopStatsRow(),
                        const SizedBox(height: 15),
                        _buildTotalBalanceCard(transactions),
                        const SizedBox(height: 15),
                        _buildMonthlyOverviewCard(transactions),
                        const SizedBox(height: 20),
                        _buildTodaySpendingCard(transactions),
                        const SizedBox(height: 20),
                        _buildRecentExpensesSection(context, transactions),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        totalPoints: totalPoints,
                        onSwitchTab: onSwitchTab,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: accentTeal,
                  child: Text(initials, style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
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

  Widget _buildSyncStatus(BuildContext context, ConnectionState state) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid ?? "Not Logged In";
    
    final bool isLoading = state == ConnectionState.waiting;

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
            Icon(
              isLoading ? Icons.sync : Icons.cloud_done_outlined, 
              color: primaryTeal, 
              size: 20
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cloud Connection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryTeal)),
                  Text("User ID: $userId", style: TextStyle(color: Colors.blueGrey[400], fontSize: 10), overflow: TextOverflow.ellipsis),
                  Text(isLoading ? "Syncing..." : statusMessage, style: TextStyle(color: Colors.blueGrey[400], fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.refresh, color: primaryTeal, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(List<ExpenseTransaction> transactions) {
    final double totalBalance = _calculateTotalBalance(transactions);
    final Color balanceColor = totalBalance >= 0 ? primaryTeal : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: accentTeal.withOpacity(0.2),
            child: Icon(Icons.account_balance_wallet_outlined, color: primaryTeal, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Balance",
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${totalBalance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(List<ExpenseTransaction> transactions) {
    final double totalSpent = _calculateTotalSpentThisMonth(transactions);
    final double monthlyLimit = 8000.0; 

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
              Text('April 2026', style: TextStyle(color: Colors.blueGrey[300])), 
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
                      PieChartSectionData(color: primaryTeal, value: totalSpent > 0 ? totalSpent : 1, radius: 20, showTitle: false),
                      PieChartSectionData(color: Colors.grey[200], value: (monthlyLimit - totalSpent) > 0 ? (monthlyLimit - totalSpent) : 0, radius: 20, showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
      {'name': 'Spending', 'color': primaryTeal},
      {'name': 'Remaining', 'color': Colors.grey[200]},
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

  Widget _buildTodaySpendingCard(List<ExpenseTransaction> transactions) {
    final double todaySpent = _calculateTotalSpentToday(transactions);
    final double dailyLimit = 750.0;

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

  Widget _buildRecentExpensesSection(BuildContext context, List<ExpenseTransaction> transactions) {
    return Column(
      children: [
        Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Logged Expenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllTransactionsScreen()),
                    );
                  },
                  child: const Text("View All", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            initiallyExpanded: true, 
            children: [
              transactions.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20), child: Text("No transactions logged yet."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];

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
}
