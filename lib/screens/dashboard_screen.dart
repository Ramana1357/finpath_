import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../presentation/providers/auth_provider.dart';
import '../services/local_cache_service.dart';
import '../data/models/profile_model.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'all_transactions_screen.dart';
import 'notifications_screen.dart';
import '../data/models/vault_model.dart';

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
    if (transactions.isEmpty) return 0.0;
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
    if (transactions.isEmpty) return 0.0;
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
    if (transactions.isEmpty) return 0.0;
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
            final authProvider = context.watch<AuthProvider>();
            final dailyLimit = authProvider.profile?.dailyLimit ?? 1000.0;
            final monthlyLimit = authProvider.profile?.monthlyLimit ?? 30000.0;
            
            return RefreshIndicator(
              onRefresh: () async {
                // Future implementation for cloud sync trigger
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          _buildInitialSetupInput(context),
                          const SizedBox(height: 15),
                          _buildTopStatsRow(context, transactions),
                          const SizedBox(height: 15),
                          _buildTotalBalanceCard(context, transactions),
                          const SizedBox(height: 15),
                          _buildMonthlyOverviewCard(transactions, monthlyLimit),
                          const SizedBox(height: 20),
                          _buildTodaySpendingCard(transactions, dailyLimit),
                          const SizedBox(height: 20),
                          _buildRecentExpensesSection(context, transactions),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildInitialSetupInput(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    // Only show if the profile exists AND they haven't saved their spending targets yet
    if (profile == null || profile.hasSeenInitialSync) {
      return const SizedBox.shrink();
    }

    final dailyController = TextEditingController(text: profile.dailyLimit.toStringAsFixed(0));
    final monthlyController = TextEditingController(text: profile.monthlyLimit.toStringAsFixed(0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryTeal.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph, color: primaryTeal, size: 20),
              SizedBox(width: 10),
              Text(
                'Set Your Spending Targets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Limit', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: dailyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Limit', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: monthlyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final dLimit = double.tryParse(dailyController.text) ?? profile.dailyLimit;
                final mLimit = double.tryParse(monthlyController.text) ?? profile.monthlyLimit;
                
                final updatedProfile = profile.copyWith(
                  dailyLimit: dLimit,
                  monthlyLimit: mLimit,
                  hasSeenInitialSync: true,
                );
                
                // This will save to BOTH Isar and Firestore via the repository
                await authProvider.saveProfile(updatedProfile);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Save Targets'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final cacheService = context.read<LocalCacheService>();
    final profile = authProvider.profile;
    
    // SAFE ACCESS: Check if name exists before split/indexing
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
              StreamBuilder<List<VaultModel>>(
                stream: cacheService.watchVaults(),
                builder: (context, snapshot) {
                  final vaults = snapshot.data ?? [];
                  final bool hasCompletedVault = vaults.any((v) => v.currentAmount >= v.targetAmount && v.targetAmount > 0);

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                      ),
                      if (hasCompletedVault)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                            constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                          ),
                        ),
                    ],
                  );
                },
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

  Widget _buildTopStatsRow(BuildContext context, List<ExpenseTransaction> transactions) {
    final authProvider = context.read<AuthProvider>();
    final cacheService = context.read<LocalCacheService>();
    final uid = authProvider.user?.uid;

    if (uid == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatsCard('Broke Date', 'N/A', Icons.calendar_today, Colors.red[100]!),
          _buildStatsCard('Savings', '₹0', Icons.trending_up, Colors.green[100]!),
          _buildStatsCard('Pts', totalPoints.toString(), Icons.emoji_events_outlined, Colors.orange[100]!),
        ],
      );
    }

    return StreamBuilder<ProfileModel?>(
      stream: cacheService.watchProfile(uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final double totalSavings = (profile?.totalLockedSavings ?? 0) + (profile?.totalVaultSavings ?? 0);
        
        // Calculate Fuel Tank for Prediction
        final double totalInflowMinusOutflow = _calculateTotalBalance(transactions);
        final double lockedSavings = profile?.totalLockedSavings ?? 0.0;
        final double vaultSavings = profile?.totalVaultSavings ?? 0.0;
        final bool isCrisisMode = profile?.isCrisisMode ?? false;
        
        final double currentAllowance = totalInflowMinusOutflow - lockedSavings - vaultSavings;
        final double dailyLimit = profile?.dailyLimit ?? 1000.0;
        final String brokeDate = _calculateBrokeDate(transactions, currentAllowance, isCrisisMode, lockedSavings, dailyLimit);
        final Color brokeTextColor = (brokeDate == "BROKE" || brokeDate == "Today") ? Colors.red : primaryTeal;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatsCard('Broke Date', brokeDate, Icons.calendar_today, Colors.red[100]!, textColor: brokeTextColor),
            GestureDetector(
              onTap: () {
                if (onSwitchTab != null) {
                  onSwitchTab!(1); // Switch to Vault tab
                }
              },
              child: _buildStatsCard('Savings', '₹${totalSavings.toStringAsFixed(0)}', Icons.trending_up, Colors.green[100]!),
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
              child: _buildStatsCard('Pts', totalPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), Icons.emoji_events_outlined, Colors.orange[100]!),
            ),
          ],
        );
      }
    );
  }

  // --- BROKE DATE PREDICTOR (ROLLING + BURN HYBRID) ---

  String _calculateBrokeDate(List<ExpenseTransaction> transactions, double allowance, bool isCrisis, double locked, double dailyLimit) {
    if (transactions.isEmpty) return "Safe";

    // Fuel Tank
    double fuel = allowance;
    if (isCrisis) fuel += locked;

    if (fuel <= 0) return "BROKE";

    final now = DateTime.now();

    // 1. Rolling Burn (Last 7 days)
    Map<int, double> dailyNetOutflow = {};
    for (int i = 0; i < 7; i++) dailyNetOutflow[i] = 0.0;

    for (var tx in transactions) {
      final diff = now.difference(tx.date).inDays;
      if (diff >= 0 && diff < 7) {
        if (tx.isExpense) {
          dailyNetOutflow[diff] = (dailyNetOutflow[diff] ?? 0) + tx.amount;
        } else {
          dailyNetOutflow[diff] = (dailyNetOutflow[diff] ?? 0) - tx.amount;
        }
      }
    }

    double burnRate = dailyNetOutflow.values.reduce((a, b) => a + b) / 7;

    // FALLBACK: If burn rate is exceptionally low or 0, use a percentage of the daily limit
    if (burnRate < (dailyLimit * 0.1)) {
      burnRate = dailyLimit * 0.3; // Assume 30% of limit as baseline burn
    }

    double daysBurn = fuel / burnRate;

    // 2. Linear Regression (Last 10 Days Balance Trend)
    List<double> balances = [];
    List<double> indices = [];
    double runningFuel = fuel;

    for (int i = 0; i < 10; i++) {
      indices.add(i.toDouble());
      balances.add(runningFuel);

      double dayNet = 0;
      for (var tx in transactions) {
        if (now.difference(tx.date).inDays == i) {
          dayNet += tx.isExpense ? -tx.amount : tx.amount;
        }
      }
      runningFuel -= dayNet; // Reverse to find previous balance
    }

    // Reverse to get 0 as 10 days ago, 9 as today
    List<double> x = List.generate(10, (i) => i.toDouble());
    List<double> y = balances.reversed.toList();

    double slope = _computeSlope(x, y);
    double intercept = _computeIntercept(x, y, slope);

    double daysReg = double.infinity;
    if (slope < 0) {
      double tBroke = -intercept / slope;
      daysReg = tBroke - 9; // Relative to today (index 9)
    }

    // 3. Hybrid Calculation
    double finalDays;
    if (daysBurn.isFinite && daysReg.isFinite) {
      // If both are positive, we take the weighted average.
      // If one is negative (growing), we prioritize the one that predicts a "broke" state.
      if (daysBurn > 0 && daysReg > 0) {
        finalDays = 0.6 * daysBurn + 0.4 * daysReg;
      } else if (daysBurn > 0) {
        finalDays = daysBurn;
      } else if (daysReg > 0) {
        finalDays = daysReg;
      } else {
        return "Growing"; // Both trends show increasing balance
      }
    } else if (daysBurn.isFinite && daysBurn > 0) {
      finalDays = daysBurn;
    } else if (daysReg.isFinite && daysReg > 0) {
      finalDays = daysReg;
    } else {
      return "Safe";
    }

    if (finalDays <= 0) return "Today";
    if (finalDays > 3650) return "Safe (>10y)"; // Cap at 10 years

    final predictedDate = now.add(Duration(days: finalDays.toInt()));

    if (finalDays > 365) {
      return DateFormat('MMM yyyy').format(predictedDate); // e.g., "Jan 2026"
    }
    return DateFormat('MMM d').format(predictedDate); // e.g., "Nov 15"
  }

  double _computeSlope(List<double> x, List<double> y) {
    int n = x.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumXX += x[i] * x[i];
    }
    double den = n * sumXX - sumX * sumX;
    return den == 0 ? 0 : (n * sumXY - sumX * sumY) / den;
  }

  double _computeIntercept(List<double> x, List<double> y, double slope) {
    double sumX = x.reduce((a, b) => a + b);
    double sumY = y.reduce((a, b) => a + b);
    return (sumY - slope * sumX) / x.length;
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color iconBg, {Color textColor = primaryTeal}) {
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
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, List<ExpenseTransaction> transactions) {
    final authProvider = context.read<AuthProvider>();
    final cacheService = context.read<LocalCacheService>();
    final uid = authProvider.user?.uid;

    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<ProfileModel?>(
      stream: cacheService.watchProfile(uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final double totalInflowMinusOutflow = _calculateTotalBalance(transactions);
        
        // Deduction logic: currentAllowance = Total - LockedSavings - VaultSavings
        final double lockedSavings = profile?.totalLockedSavings ?? 0.0;
        final double vaultSavings = profile?.totalVaultSavings ?? 0.0;
        final bool isCrisisMode = profile?.isCrisisMode ?? false;

        // Formula: Always show Allowance. 
        final double currentAllowance = totalInflowMinusOutflow - lockedSavings - vaultSavings;
        
        final Color balanceColor = currentAllowance >= 0 ? (isCrisisMode ? Colors.orange : primaryTeal) : Colors.redAccent;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: isCrisisMode ? Border.all(color: Colors.orange, width: 2) : null,
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
                backgroundColor: (isCrisisMode ? Colors.orange : accentTeal).withOpacity(0.2),
                child: Icon(
                  isCrisisMode ? Icons.emergency_outlined : Icons.account_balance_wallet_outlined, 
                  color: isCrisisMode ? Colors.orange : primaryTeal, 
                  size: 28
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isCrisisMode ? "CRISIS ALLOWANCE" : "Current Allowance",
                          style: TextStyle(
                            color: isCrisisMode ? Colors.orange : Colors.blueGrey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCrisisMode) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${currentAllowance.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyOverviewCard(List<ExpenseTransaction> transactions, double monthlyLimit) {
    final double totalSpent = _calculateTotalSpentThisMonth(transactions);

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
                      // SAFE ACCESS: Prevent 0 value crash in PieChart
                      PieChartSectionData(color: primaryTeal, value: totalSpent > 0 ? totalSpent : 0.001, radius: 20, showTitle: false),
                      PieChartSectionData(color: Colors.grey[200], value: (monthlyLimit - totalSpent) > 0 ? (monthlyLimit - totalSpent) : 0.001, radius: 20, showTitle: false),
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

  Widget _buildTodaySpendingCard(List<ExpenseTransaction> transactions, double dailyLimit) {
    final double todaySpent = _calculateTotalSpentToday(transactions);

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
              // SAFE ACCESS: Show empty state instead of crashing
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No transactions logged yet.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              else
                ListView.builder(
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
