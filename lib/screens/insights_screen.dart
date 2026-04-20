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
            final double nTarget = profile?.needsTarget ?? 50.0;
            final double wTarget = profile?.wantsTarget ?? 30.0;
            final double sTarget = profile?.savingsTarget ?? 20.0;

            final double needsBudget = mAllowance * (nTarget / 100);
            final double wantsBudget = mAllowance * (wTarget / 100);
            final double savingsBudget = mAllowance * (sTarget / 100);
            
            final transactions = snapshot.data ?? [];
            final now = DateTime.now();
            
            // Filter transactions for current month (expenses only)
            final currentMonthTxs = transactions.where((tx) => 
              tx.date.month == now.month && 
              tx.date.year == now.year && 
              tx.isExpense
            ).toList();

            // Category Mapping
            final needsCats = {'food', 'groceries', 'rent', 'utilities', 'education', 'transport', 'health'};
            final wantsCats = {'shopping', 'dining', 'entertainment', 'hobbies', 'subscriptions'};
            
            double needsTotal = 0;
            double wantsTotal = 0;
            double savingsTotal = 0;

            for (var tx in currentMonthTxs) {
              final cat = tx.category.toLowerCase().trim();
              if (needsCats.contains(cat)) {
                needsTotal += tx.amount;
              } else if (wantsCats.contains(cat)) {
                wantsTotal += tx.amount;
              } else {
                savingsTotal += tx.amount;
              }
            }

            // Ratio Math (0.0 to 1.0)
            final double needsRatio = (needsBudget > 0 ? (needsTotal / needsBudget) : 0.0).clamp(0.0, 1.0);
            final double wantsRatio = (wantsBudget > 0 ? (wantsTotal / wantsBudget) : 0.0).clamp(0.0, 1.0);
            final double savingsRatio = (savingsBudget > 0 ? (savingsTotal / savingsBudget) : 0.0).clamp(0.0, 1.0);

            // Health Score: Start at 100. Subtract for exceeding targets.
            double needsPct = (needsTotal / mAllowance) * 100;
            double wantsPct = (wantsTotal / mAllowance) * 100;
            double savingsPct = (savingsTotal / mAllowance) * 100;

            double healthScore = 100;
            if (currentMonthTxs.isNotEmpty) {
              if (needsPct > nTarget) healthScore -= (needsPct - nTarget);
              if (wantsPct > wTarget) healthScore -= (wantsPct - wTarget);
              if (savingsPct < sTarget) healthScore -= (sTarget - savingsPct);
            }
            healthScore = healthScore.clamp(0.0, 100.0);

            // Re-calculate savings rate for status message
            double totalSpent = needsTotal + wantsTotal + savingsTotal;
            double savingsRate = mAllowance > 0 ? (mAllowance - totalSpent) / mAllowance : 0.0;

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
                          _buildTabBar(),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 480, 
                            child: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _KeepAliveWrapper(
                                  child: _build503020Dashboard(
                                    needsRatio: needsRatio, 
                                    wantsRatio: wantsRatio, 
                                    savingsRatio: savingsRatio, 
                                    needsAmt: needsTotal, 
                                    wantsAmt: wantsTotal, 
                                    savingsAmt: savingsTotal,
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

  Widget _buildTabBar() {
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
        tabs: const [
          Tab(text: "50/30/20"),
          Tab(text: "Zero-Based"),
          Tab(text: "Envelope"),
        ],
      ),
    );
  }

  Widget _build503020Dashboard({
    required double needsRatio, 
    required double wantsRatio, 
    required double savingsRatio, 
    required double needsAmt, 
    required double wantsAmt, 
    required double savingsAmt,
    required double nTarget,
    required double wTarget,
    required double sTarget,
  }) {
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
                const Text(
                  "50/30/20 Dashboard",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressRow("Needs", nTarget.toInt(), needsRatio, Colors.blue.shade700),
            const SizedBox(height: 20),
            _buildProgressRow("Wants", wTarget.toInt(), wantsRatio, Colors.orange.shade700),
            const SizedBox(height: 20),
            _buildProgressRow("Savings", sTarget.toInt(), savingsRatio, Colors.green.shade700),
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

  Widget _buildProgressRow(String label, int target, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(
              "Target: $target% | Usage: ${(ratio * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: _backgroundGray,
            color: color,
            minHeight: 10,
          ),
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
