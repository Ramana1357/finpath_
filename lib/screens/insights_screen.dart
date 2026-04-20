import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/local_cache_service.dart';
import '../data/models/profile_model.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentTeal = Color(0xFF83C5BE);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheService = context.read<LocalCacheService>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: StreamBuilder<List<ExpenseTransaction>>(
          stream: cacheService.isar.expenseTransactions.where().watch(fireImmediately: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: _primaryTeal));
            }

            // Fetch ProfileModel synchronously for real-time reactivity
            final profile = cacheService.isar.profileModels.where().findFirstSync() ?? authProvider.profile;
            
            // Dynamic variables from ProfileModel
            final double mAllowance = (profile?.monthlyAllowance ?? 30000.0) <= 0 ? 1.0 : (profile?.monthlyAllowance ?? 30000.0);
            
            // Use allowancePercent, dreamVaultPercent, emergencyPercent from Isar (Budget Rules)
            final double nTarget = (profile?.allowancePercent ?? 50).toDouble();
            final double wTarget = (profile?.dreamVaultPercent ?? 30).toDouble();
            final double sTarget = (profile?.emergencyPercent ?? 20).toDouble();

            final double needsBudget = mAllowance * (nTarget / 100);
            final double wantsBudget = mAllowance * (wTarget / 100);
            final double savingsBudget = mAllowance * (sTarget / 100);
            
            final transactions = snapshot.data ?? [];
            final now = DateTime.now();
            
            // Filter transactions for current month
            final currentMonthTxs = transactions.where((tx) => 
              tx.date.month == now.month && 
              tx.date.year == now.year
            ).toList();

            // Calculate actual income for the month from transactions
            double actualIncome = currentMonthTxs
                .where((tx) => !tx.isExpense)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            // Use actual income if available, otherwise fallback to profile allowance
            final double effectiveAllowance = actualIncome > 0 ? actualIncome : mAllowance;
            
            final expenses = currentMonthTxs.where((tx) => tx.isExpense).toList();

            // Category Mapping
            final needsCats = {'food', 'groceries', 'rent', 'utilities', 'education', 'transport', 'health', 'bills'};
            final wantsCats = {'shopping', 'dining', 'entertainment', 'hobbies', 'subscriptions', 'travel', 'lifestyle'};
            
            double needsTotal = 0;
            double wantsTotal = 0;

            for (var tx in expenses) {
              final cat = tx.category.toLowerCase().trim();
              if (needsCats.contains(cat)) {
                needsTotal += tx.amount;
              } else if (wantsCats.contains(cat)) {
                wantsTotal += tx.amount;
              } else {
                // If uncategorized expense, default to Wants or split? 
                // Let's keep it in Wants for now or a separate bucket.
                wantsTotal += tx.amount;
              }
            }

            // Savings is what remains from income
            double savingsTotal = effectiveAllowance - (needsTotal + wantsTotal);
            if (savingsTotal < 0) savingsTotal = 0;

            // Ratio Math (0.0 to 1.0)
            final double needsRatio = (effectiveAllowance > 0 ? (needsTotal / effectiveAllowance) : 0.0);
            final double wantsRatio = (effectiveAllowance > 0 ? (wantsTotal / effectiveAllowance) : 0.0);
            final double savingsRatio = (effectiveAllowance > 0 ? (savingsTotal / effectiveAllowance) : 0.0);

            // Health Score Calculation
            double needsPct = needsRatio * 100;
            double wantsPct = wantsRatio * 100;
            double savingsPct = savingsRatio * 100;

            double healthScore = 100;
            if (expenses.isNotEmpty || actualIncome > 0) {
              // Deduct for overspending relative to dynamic targets
              if (needsPct > nTarget) healthScore -= (needsPct - nTarget) * 1.5;
              if (wantsPct > wTarget) healthScore -= (wantsPct - wTarget) * 1.0;
              if (savingsPct < sTarget) healthScore -= (sTarget - savingsPct) * 2.0;
            } else {
              healthScore = 100;
            }
            
            healthScore = healthScore.clamp(0.0, 100.0);

            // Re-calculate savings rate for status message
            double savingsRate = effectiveAllowance > 0 ? (savingsTotal / effectiveAllowance) : 0.0;

            return Column(
              children: [
                _buildAppBar(context, profile),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHealthScoreCard(healthScore, savingsRate),
                          const SizedBox(height: 25),
                          _buildTabBar(nTarget, wTarget, sTarget),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 480, 
                            child: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _KeepAliveWrapper(
                                  child: _buildBudgetDashboard(
                                    needsAmt: needsTotal, 
                                    wantsAmt: wantsTotal, 
                                    savingsAmt: savingsTotal,
                                    needsBudget: needsBudget,
                                    wantsBudget: wantsBudget,
                                    savingsBudget: savingsBudget,
                                    nTarget: nTarget,
                                    wTarget: wTarget,
                                    sTarget: sTarget,
                                  ),
                                ),
                                _KeepAliveWrapper(child: _buildComingSoon("Zero-Based")),
                                _KeepAliveWrapper(child: _buildComingSoon("Envelope")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileModel? profile) {
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: CircleAvatar(
                  backgroundColor: _accentTeal,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: _primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(double score, double savingsRate) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Financial Health Score",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "${score.toInt()}/100",
                  style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold),
                ),
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(double n, double w, double s) {
    final String ruleName = "${n.toInt()}/${w.toInt()}/${s.toInt()}";
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _accentTeal,
        ),
        labelColor: _primaryTeal,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: ruleName),
          const Tab(text: "Zero-Based"),
          const Tab(text: "Envelope"),
        ],
      ),
    );
  }

  Widget _buildBudgetDashboard({
    required double needsAmt, 
    required double wantsAmt, 
    required double savingsAmt,
    required double needsBudget,
    required double wantsBudget,
    required double savingsBudget,
    required double nTarget,
    required double wTarget,
    required double sTarget,
  }) {
    final String ruleName = "${nTarget.toInt()}/${wTarget.toInt()}/${sTarget.toInt()}";
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: _primaryTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  "$ruleName Dashboard",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressRow("Needs", nTarget.toInt(), needsAmt, needsBudget, Colors.blue.shade700),
            const SizedBox(height: 20),
            _buildProgressRow("Wants", wTarget.toInt(), wantsAmt, wantsBudget, Colors.orange.shade700),
            const SizedBox(height: 20),
            _buildProgressRow("Savings", sTarget.toInt(), savingsAmt, savingsBudget, Colors.green.shade700),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem("Needs", needsAmt),
                _buildSummaryItem("Wants", wantsAmt),
                _buildSummaryItem("Savings", savingsAmt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, int targetPct, double actualAmt, double budgetAmt, Color color) {
    final double ratio = budgetAmt > 0 ? (actualAmt / budgetAmt) : 0.0;
    final double usageOfBudget = ratio * 100;
    
    final bool isOverspent = (label != "Savings") && (ratio > 1.0);
    final bool isUnderSaving = (label == "Savings") && (ratio < 1.0);
    
    final Color barColor = isOverspent ? Colors.red.shade700 : (isUnderSaving ? Colors.orange.shade700 : color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label ($targetPct%)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(
              "₹${actualAmt.toStringAsFixed(0)} / ₹${budgetAmt.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 12, 
                color: (isOverspent || isUnderSaving) ? Colors.red : Colors.grey[700], 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: _backgroundGray,
            color: barColor,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label == "Savings" 
            ? "${usageOfBudget.toStringAsFixed(1)}% of Savings budget is secured"
            : "${usageOfBudget.toStringAsFixed(1)}% of $label Budget Used",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, double amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryTeal, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildComingSoon(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 50, color: _accentTeal.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text("$name Strategy", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Coming in V2", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
