import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DashboardScreen extends StatefulWidget {
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

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  Map<int, double> _calculateWeeklySpending(List<ExpenseTransaction> transactions) {
    Map<int, double> dailySpending = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var tx in transactions) {
      if (!tx.isExpense) continue;
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final difference = today.difference(txDate).inDays;
      
      if (difference >= 0 && difference < 7) {
        // 0 is today, 6 is 6 days ago. We want to map it to 0-6 index for display
        // Let's make index 6 = today, index 0 = 6 days ago for a chronological bar chart
        int index = 6 - difference;
        dailySpending[index] = (dailySpending[index] ?? 0) + tx.amount;
      }
    }
    return dailySpending;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: StreamBuilder<List<ExpenseTransaction>>(
          stream: widget.transactionsStream,
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
                          _buildSwipableCharts(transactions, monthlyLimit),
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
    final colorScheme = Theme.of(context).colorScheme;

    // Only show if the profile exists AND they haven't saved their spending targets yet
    if (profile == null || profile.hasSeenInitialSync) {
      return const SizedBox.shrink();
    }

    final dailyController = TextEditingController(text: profile.dailyLimit.toStringAsFixed(0));
    final monthlyController = TextEditingController(text: profile.monthlyLimit.toStringAsFixed(0));
    final _targetFormKey = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Form(
        key: _targetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Set Your Spending Targets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
                      Text('Daily Limit', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: dailyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Req";
                          final n = double.tryParse(val);
                          if (n == null || n <= 0) return "Min Amount";
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                          errorStyle: const TextStyle(height: 0),
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
                      Text('Monthly Limit', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: monthlyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Req";
                          final n = double.tryParse(val);
                          if (n == null || n <= 0) return "Min Amount";
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                          errorStyle: const TextStyle(height: 0),
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
                  if (!_targetFormKey.currentState!.validate()) return;

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
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save Targets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final cacheService = context.read<LocalCacheService>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;
    
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
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FINPATH',
            style: TextStyle(
              color: colorScheme.onPrimary,
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
                        icon: Icon(Icons.notifications_none, color: colorScheme.onPrimary),
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
                            decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(6)),
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
                        totalPoints: widget.totalPoints,
                        onSwitchTab: widget.onSwitchTab,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: colorScheme.secondary,
                  child: Text(initials, style: TextStyle(color: colorScheme.onSecondary, fontWeight: FontWeight.bold)),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (uid == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatsCard('Broke Date', 'N/A', Icons.calendar_today, colorScheme.error.withValues(alpha: 0.1)),
          _buildStatsCard('Savings', '₹0', Icons.trending_up, colorScheme.primary.withValues(alpha: 0.1)),
          _buildStatsCard('Pts', widget.totalPoints.toString(), Icons.emoji_events_outlined, colorScheme.secondary.withValues(alpha: 0.1)),
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
        final Color brokeTextColor = (brokeDate == "BROKE" || brokeDate == "Today") ? colorScheme.error : colorScheme.primary;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatsCard('Broke Date', brokeDate, Icons.calendar_today, colorScheme.error.withValues(alpha: 0.1), textColor: brokeTextColor),
            GestureDetector(
              onTap: () {
                if (widget.onSwitchTab != null) {
                  widget.onSwitchTab!(1); // Switch to Vault tab
                }
              },
              child: _buildStatsCard('Savings', '₹${totalSavings.toStringAsFixed(0)}', Icons.trending_up, colorScheme.primary.withValues(alpha: 0.1)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      totalPoints: widget.totalPoints,
                      onSwitchTab: widget.onSwitchTab,
                    ),
                  ),
                );
              },
              child: _buildStatsCard('Pts', widget.totalPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), Icons.emoji_events_outlined, colorScheme.secondary.withValues(alpha: 0.1)),
            ),
          ],
        );
      }
    );
  }

  // --- BROKE DATE PREDICTOR (ROLLING + BURN HYBRID) ---

  String _calculateBrokeDate(List<ExpenseTransaction> transactions, double allowance, bool isCrisis, double locked, double dailyLimit) {
    if (transactions.isEmpty) return "Safe";

    // Fuel Tank: Amount available to spend
    double fuel = allowance;
    if (isCrisis) fuel += locked;

    if (fuel <= 0) return "BROKE";

    final now = DateTime.now();

    // 1. Rolling Weighted Burn (Last 14 days)
    // We use a 14-day window for a more stable average than 7 days, 
    // but weight recent days more heavily to capture recent changes.
    const int burnWindow = 14;
    Map<int, double> dailyNetOutflow = {};
    for (int i = 0; i < burnWindow; i++) dailyNetOutflow[i] = 0.0;

    for (var tx in transactions) {
      final diff = now.difference(tx.date).inDays;
      if (diff >= 0 && diff < burnWindow) {
        if (tx.isExpense) {
          dailyNetOutflow[diff] = (dailyNetOutflow[diff] ?? 0) + tx.amount;
        } else {
          dailyNetOutflow[diff] = (dailyNetOutflow[diff] ?? 0) - tx.amount;
        }
      }
    }

    // Outlier mitigation: Cap extremely high spending days to 4x the median to avoid skewing
    List<double> nonZeroSpends = dailyNetOutflow.values.where((v) => v > 0).toList()..sort();
    if (nonZeroSpends.length >= 3) {
      double median = nonZeroSpends[nonZeroSpends.length ~/ 2];
      dailyNetOutflow.updateAll((k, v) => v > median * 4 ? median * 2 : v);
    }

    double weightedBurnSum = 0;
    double weightSum = 0;
    for (int i = 0; i < burnWindow; i++) {
      double weight = (burnWindow - i) / burnWindow; // Today (0) has highest weight
      weightedBurnSum += (dailyNetOutflow[i] ?? 0) * weight;
      weightSum += weight;
    }
    
    double burnRate = weightedBurnSum / weightSum;

    // FALLBACK: If burn rate is exceptionally low or 0, use a percentage of the daily limit
    if (burnRate < (dailyLimit * 0.1)) {
      burnRate = dailyLimit * 0.4; // Slightly more conservative fallback
    }

    double daysBurn = fuel / burnRate;

    // 2. Linear Regression (Last 15 Days Balance Trend)
    // Regression helps identify if spending is accelerating or decelerating
    const int regWindow = 15;
    List<double> balances = [];
    double runningFuel = fuel;

    // Pre-calculate daily nets for efficiency
    Map<int, double> dailyNets = {};
    for (int i = 0; i < regWindow; i++) dailyNets[i] = 0.0;
    for (var tx in transactions) {
      final diff = now.difference(tx.date).inDays;
      if (diff >= 0 && diff < regWindow) {
        dailyNets[diff] = (dailyNets[diff] ?? 0) + (tx.isExpense ? -tx.amount : tx.amount);
      }
    }

    for (int i = 0; i < regWindow; i++) {
      balances.add(runningFuel);
      runningFuel -= (dailyNets[i] ?? 0); // Walk backwards
    }

    List<double> x = List.generate(regWindow, (i) => i.toDouble());
    List<double> y = balances.reversed.toList();

    double slope = _computeSlope(x, y);
    double intercept = _computeIntercept(x, y, slope);

    double daysReg = double.infinity;
    if (slope < 0) {
      double tBroke = -intercept / slope;
      daysReg = tBroke - (regWindow - 1); // Relative to today
    }

    // 3. Smart Hybrid Calculation
    double finalDays;
    if (daysBurn.isFinite && daysReg.isFinite) {
      if (daysBurn > 0 && daysReg > 0) {
        // Favor the more conservative (shorter) prediction if they diverge significantly
        if ((daysBurn - daysReg).abs() > 10) {
          finalDays = (daysBurn < daysReg) ? (0.7 * daysBurn + 0.3 * daysReg) : (0.3 * daysBurn + 0.7 * daysReg);
        } else {
          finalDays = 0.5 * daysBurn + 0.5 * daysReg;
        }
      } else if (daysBurn > 0) {
        finalDays = daysBurn;
      } else if (daysReg > 0) {
        finalDays = daysReg;
      } else {
        return "Growing";
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

  Widget _buildStatsCard(String title, String value, IconData icon, Color iconBg, {Color? textColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveTextColor = textColor ?? colorScheme.primary;

    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, size: 18, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: effectiveTextColor)),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, List<ExpenseTransaction> transactions) {
    final authProvider = context.read<AuthProvider>();
    final cacheService = context.read<LocalCacheService>();
    final uid = authProvider.user?.uid;
    final colorScheme = Theme.of(context).colorScheme;

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
        
        final Color balanceColor = currentAllowance >= 0 ? (isCrisisMode ? colorScheme.error : colorScheme.primary) : colorScheme.error;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: isCrisisMode ? Border.all(color: colorScheme.error, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: (isCrisisMode ? colorScheme.error : colorScheme.secondary).withValues(alpha: 0.2),
                child: Icon(
                  isCrisisMode ? Icons.emergency_outlined : Icons.account_balance_wallet_outlined, 
                  color: isCrisisMode ? colorScheme.error : colorScheme.primary, 
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
                            color: isCrisisMode ? colorScheme.error : colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCrisisMode) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 16),
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

  Widget _buildSwipableCharts(List<ExpenseTransaction> transactions, double monthlyLimit) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildMonthlyOverviewCard(transactions, monthlyLimit),
              _buildWeeklyBarChartCard(transactions),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildMonthlyOverviewCard(List<ExpenseTransaction> transactions, double monthlyLimit) {
    final double totalSpent = _calculateTotalSpentThisMonth(transactions);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: TextStyle(color: colorScheme.onSurfaceVariant)), 
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
                      PieChartSectionData(color: colorScheme.primary, value: totalSpent > 0 ? totalSpent : 0.001, radius: 20, showTitle: false),
                      PieChartSectionData(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1), value: (monthlyLimit - totalSpent) > 0 ? (monthlyLimit - totalSpent) : 0.001, radius: 20, showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${(totalSpent / 1000).toStringAsFixed(1)}K', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    Text('of ₹${(monthlyLimit / 1000).toStringAsFixed(1)}K', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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

  Widget _buildWeeklyBarChartCard(List<ExpenseTransaction> transactions) {
    final dailySpending = _calculateWeeklySpending(transactions);
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              Text('Last 7 Days', style: TextStyle(color: colorScheme.onSurfaceVariant)), 
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dailySpending.values.reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${rod.toY.toStringAsFixed(0)}',
                        TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = now.subtract(Duration(days: 6 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E').format(date)[0],
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: dailySpending.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: entry.key == 6 ? colorScheme.primary : colorScheme.secondary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Swipe left to see monthly pie chart",
              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      {'name': 'Spending', 'color': colorScheme.primary},
      {'name': 'Remaining', 'color': colorScheme.onSurfaceVariant.withValues(alpha: 0.1)},
    ];
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: categories.map((c) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: c['color'] as Color),
          const SizedBox(width: 5),
          Text(c['name'] as String, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        ],
      )).toList(),
    );
  }

  Widget _buildTodaySpendingCard(List<ExpenseTransaction> transactions, double dailyLimit) {
    final double todaySpent = _calculateTotalSpentToday(transactions);
    final colorScheme = Theme.of(context).colorScheme;

    double percent = dailyLimit > 0 ? todaySpent / dailyLimit : 0.0;
    if (percent > 1.0) percent = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Spending', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '₹${todaySpent.toStringAsFixed(0)} ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    TextSpan(text: '/ ₹${dailyLimit.toStringAsFixed(0)} limit', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text("${(percent * 100).toStringAsFixed(0)}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            progressColor: colorScheme.primary,
            backgroundColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection(BuildContext context, List<ExpenseTransaction> transactions) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Logged Expenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllTransactionsScreen()),
                    );
                  },
                  child: Text("View All", style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text("No transactions logged yet.", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
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
                final Color amountColor = isExpense ? colorScheme.error : colorScheme.primary;
                final Color avatarBgColor = isExpense ? colorScheme.error.withValues(alpha: 0.1) : colorScheme.primary.withValues(alpha: 0.1);
                final IconData txIcon = isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

                return ListTile(
                  leading: CircleAvatar(
                      backgroundColor: avatarBgColor,
                      child: Icon(txIcon, color: amountColor, size: 20)
                  ),
                  title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  subtitle: Text(
                      isExpense ? 'Debit' : 'Credit',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)
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
    );
  }
}
