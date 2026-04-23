import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
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
  static const Color _savingsGreen = Color(0xFF43AA8B);
  static const Color _surfaceWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

            // --- Yearly Trend Data Calculation ---
            Map<int, double> monthlyNetMap = {};
            for (int i = 1; i <= 12; i++) {
              monthlyNetMap[i] = 0;
            }
            for (var tx in transactions) {
              if (tx.date.year == now.year) {
                final m = tx.date.month;
                if (tx.isExpense) {
                  monthlyNetMap[m] = (monthlyNetMap[m] ?? 0.0) - tx.amount;
                } else {
                  monthlyNetMap[m] = (monthlyNetMap[m] ?? 0.0) + tx.amount;
                }
              }
            }

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
            final savingsCats = {'savings', 'vault', 'investment', 'emergency fund', 'insurance'};
            
            double needsTotal = 0;
            double wantsTotal = 0;

            double intentionalSavingsTotal = 0;
            Map<String, double> categorySpent = {};

            for (var tx in expenses) {
              final cat = tx.category.toLowerCase().trim();
              categorySpent[cat] = (categorySpent[cat] ?? 0) + tx.amount;
              
              if (needsCats.contains(cat)) {
                needsTotal += tx.amount;
              } else if (wantsCats.contains(cat)) {
                wantsTotal += tx.amount;
              } else if (savingsCats.contains(cat)) {
                intentionalSavingsTotal += tx.amount;
              } else {
                // If uncategorized expense, default to Wants
                wantsTotal += tx.amount;
              }
            }

            // Savings is what remains from ACTUAL income if logged, otherwise 0
            // (Don't use effectiveAllowance here to avoid showing default 30k as savings)
            double savingsTotal = (actualIncome > 0) 
                ? actualIncome - (needsTotal + wantsTotal) 
                : 0.0;
            if (savingsTotal < 0) savingsTotal = 0;

            // Unassigned for Zero-Based strategy
            double unassignedTotal = actualIncome - (needsTotal + wantsTotal + intentionalSavingsTotal);
            if (unassignedTotal < 0) unassignedTotal = 0;

            // Ratio Math (0.0 to 1.0)
            final double needsRatio = (effectiveAllowance > 0 ? (needsTotal / effectiveAllowance) : 0.0);
            final double wantsRatio = (effectiveAllowance > 0 ? (wantsTotal / effectiveAllowance) : 0.0);
            final double savingsRatio = (effectiveAllowance > 0 ? (savingsTotal / effectiveAllowance) : 0.0);

            final double needsPct = needsRatio * 100;
            final double wantsPct = wantsRatio * 100;
            final double savingsPct = savingsRatio * 100;

            // Health Score Calculation
            double healthScore = 100.0;
            // Calculate base spending impact (1% spent = -1 point)
            double totalSpentPct = (effectiveAllowance > 0) ? ((needsTotal + wantsTotal) / effectiveAllowance) * 100 : 0.0;

            if (expenses.isNotEmpty || actualIncome > 0) {
              healthScore -= totalSpentPct;

              // Extra penalties for overspending relative to dynamic targets
              if (needsPct > nTarget) healthScore -= (needsPct - nTarget) * 1.5;
              if (wantsPct > wTarget) healthScore -= (wantsPct - wTarget) * 1.0;
              
              // Penalty for low savings if actual income is present
              if (actualIncome > 0 && savingsPct < sTarget) {
                healthScore -= (sTarget - savingsPct) * 0.5;
              }
            } else {
              healthScore = 100.0;
            }
            
            healthScore = healthScore.clamp(0.0, 100.0);

            // Re-calculate savings rate for status message
            double savingsRate = effectiveAllowance > 0 ? (savingsTotal / effectiveAllowance) : 0.0;

            // --- Envelope Strategy Data ---
            Map<String, double> envelopeLimits = {};
            if (profile?.envelopeLimitsJson != null) {
              try {
                final Map<String, dynamic> decoded = jsonDecode(profile!.envelopeLimitsJson!);
                envelopeLimits = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
              } catch (_) {}
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildAppBar(context, profile),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildHealthScoreCard(healthScore, savingsRate),
                        const SizedBox(height: 25),
                        _buildTabBar(nTarget, wTarget, sTarget),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 520, 
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
                              _KeepAliveWrapper(
                                child: _buildZeroBasedDashboard(
                                  actualIncome: actualIncome,
                                  needsTotal: needsTotal,
                                  wantsTotal: wantsTotal,
                                  intentionalSavings: intentionalSavingsTotal,
                                  unassigned: unassignedTotal,
                                ),
                              ),
                              _KeepAliveWrapper(
                                child: _buildEnvelopeDashboard(
                                  categorySpent: categorySpent,
                                  needsCats: needsCats,
                                  wantsCats: wantsCats,
                                  needsBudget: needsBudget,
                                  wantsBudget: wantsBudget,
                                  envelopeLimits: envelopeLimits,
                                  onUpdateLimit: (cat, limit) async {
                                    envelopeLimits[cat] = limit;
                                    final updatedProfile = profile?.copyWith(
                                      envelopeLimitsJson: jsonEncode(envelopeLimits),
                                      updatedAt: DateTime.now(),
                                    );
                                    if (updatedProfile != null) {
                                      await authProvider.saveProfile(updatedProfile);
                                    }
                                  },
                                ),
                              ),
                              _KeepAliveWrapper(
                                child: _buildYearlyTrendDashboard(monthlyNetMap, transactions),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryTeal),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _accentTeal.withValues(alpha: 0.2),
        ),
        labelColor: _primaryTeal,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: ruleName),
          const Tab(text: "Zero-Based"),
          const Tab(text: "Envelope"),
          const Tab(text: "Trends"),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            const SizedBox(height: 24),
            _buildProgressRow("Needs", nTarget.toInt(), needsAmt, needsBudget, _primaryTeal),
            const SizedBox(height: 24),
            _buildProgressRow("Wants", wTarget.toInt(), wantsAmt, wantsBudget, _accentTeal),
            const SizedBox(height: 24),
            _buildProgressRow("Savings", sTarget.toInt(), savingsAmt, savingsBudget, _savingsGreen),
            const SizedBox(height: 30),
            const Divider(height: 1, color: _backgroundGray),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem("Needs", needsAmt, _primaryTeal),
                _buildSummaryItem("Wants", wantsAmt, _accentTeal),
                _buildSummaryItem("Savings", savingsAmt, _savingsGreen),
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

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildZeroBasedDashboard({
    required double actualIncome,
    required double needsTotal,
    required double wantsTotal,
    required double intentionalSavings,
    required double unassigned,
  }) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: _primaryTeal, size: 20),
                SizedBox(width: 8),
                Text(
                  "Zero-Based Strategy",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Goal: Give every rupee a job. 'To be Assigned' should be ₹0.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 25),
            _buildAllocationRow("Total Income", actualIncome, actualIncome, Colors.grey.shade800, isIncome: true),
            const SizedBox(height: 15),
            const Divider(height: 1, color: _backgroundGray),
            const SizedBox(height: 15),
            _buildAllocationRow("Needs", needsTotal, actualIncome, _primaryTeal),
            const SizedBox(height: 15),
            _buildAllocationRow("Wants", wantsTotal, actualIncome, _accentTeal),
            const SizedBox(height: 15),
            _buildAllocationRow("Savings (Intentional)", intentionalSavings, actualIncome, _savingsGreen),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: unassigned > 0 ? Colors.orange.withValues(alpha: 0.1) : _savingsGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: unassigned > 0 ? Colors.orange.withValues(alpha: 0.2) : _savingsGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "To be Assigned",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: unassigned > 0 ? Colors.orange.shade900 : _savingsGreen
                        ),
                      ),
                      Text(
                        unassigned > 0 ? "Put this into your Vault!" : "Perfect! All income assigned.",
                        style: TextStyle(fontSize: 11, color: unassigned > 0 ? Colors.orange.shade800 : _savingsGreen.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                  Text(
                    "₹${unassigned.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: unassigned > 0 ? Colors.orange.shade900 : _savingsGreen
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationRow(String label, double amount, double total, Color color, {bool isIncome = false}) {
    final double pct = total > 0 ? (amount / total) * 100 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: isIncome ? FontWeight.bold : FontWeight.w500, fontSize: 14, color: isIncome ? _primaryTeal : Colors.black87)),
            Text(
              "₹${amount.toStringAsFixed(0)}",
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
            ),
          ],
        ),
        if (!isIncome) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (total > 0 ? (amount / total) : 0.0).clamp(0.0, 1.0),
              backgroundColor: _backgroundGray,
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text("${pct.toStringAsFixed(1)}% of total income", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ],
    );
  }

  Widget _buildEnvelopeDashboard({
    required Map<String, double> categorySpent,
    required Set<String> needsCats,
    required Set<String> wantsCats,
    required double needsBudget,
    required double wantsBudget,
    required Map<String, double> envelopeLimits,
    required Function(String, double) onUpdateLimit,
  }) {
    final sortedCategories = categorySpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mail_outline, color: _primaryTeal, size: 20),
                SizedBox(width: 8),
                Text(
                  "Envelope Strategy",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Track spending by category envelopes. Tap to adjust limits.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            if (categorySpent.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text("No expenses logged this month.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...sortedCategories.map((entry) {
                final cat = entry.key;
                final spent = entry.value;
                
                double limit = envelopeLimits[cat] ?? 0;
                Color catColor = Colors.grey;
                
                if (needsCats.contains(cat)) {
                  if (limit == 0) limit = needsBudget * 0.25; 
                  catColor = _primaryTeal;
                } else if (wantsCats.contains(cat)) {
                  if (limit == 0) limit = wantsBudget * 0.20;
                  catColor = _accentTeal;
                } else {
                  if (limit == 0) limit = (needsBudget + wantsBudget) * 0.05;
                  catColor = _savingsGreen;
                }

                return GestureDetector(
                  onTap: () => _showLimitDialog(context, cat, limit, onUpdateLimit),
                  child: _buildEnvelopeItem(cat, spent, limit, catColor),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog(BuildContext context, String cat, double currentLimit, Function(String, double) onUpdate) {
    final controller = TextEditingController(text: currentLimit.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Limit for ${cat[0].toUpperCase()}${cat.substring(1)}"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              final n = double.tryParse(val);
              if (n == null || n <= 0) return "Min Amount";
              return null;
            },
            decoration: const InputDecoration(
              prefixText: "₹ ", 
              labelText: "Monthly Limit",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final newLimit = double.tryParse(controller.text) ?? currentLimit;
              onUpdate(cat, newLimit);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTrendDashboard(Map<int, double> monthlyNet, List<ExpenseTransaction> allTransactions) {
    List<FlSpot> spots = [];
    double cumulative = 0;
    for (int i = 1; i <= 12; i++) {
      double net = monthlyNet[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), net));
      cumulative += net;
    }

    // --- Broke Date Prediction Logic ---
    String predictionMessage = "Keep tracking to get your 'Broke Date' prediction.";
    Color predictionColor = Colors.grey;

    final now = DateTime.now();
    final currentMonthTxs = allTransactions.where((tx) => 
      tx.date.month == now.month && 
      tx.date.year == now.year
    ).toList();

    double monthlyExpenses = currentMonthTxs
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    
    double monthlyIncome = currentMonthTxs
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // Fallback to profile allowance if no income recorded yet this month
    final profile = context.read<LocalCacheService>().isar.profileModels.where().findFirstSync();
    final double mAllowance = profile?.monthlyAllowance ?? 30000.0;
    final double effectiveIncome = monthlyIncome > 0 ? monthlyIncome : mAllowance;

    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int daysPassed = now.day;
    
    if (daysPassed > 0 && monthlyExpenses > 0) {
      double dailyBurnRate = monthlyExpenses / daysPassed;
      double remainingBalance = effectiveIncome - monthlyExpenses;
      
      if (remainingBalance > 0) {
        int daysLeft = (remainingBalance / dailyBurnRate).floor();
        DateTime brokeDate = now.add(Duration(days: daysLeft));
        
        if (brokeDate.month == now.month) {
          predictionMessage = "At your current spend rate, you'll run out of money by ${brokeDate.day} ${['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][brokeDate.month]}.";
          predictionColor = Colors.orange.shade700;
        } else {
          predictionMessage = "Great! You're on track to finish the month with a surplus.";
          predictionColor = _savingsGreen;
        }
      } else {
        predictionMessage = "You've already exceeded your ${monthlyIncome > 0 ? 'income' : 'budget'} for this month!";
        predictionColor = Colors.red.shade700;
      }
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: _primaryTeal, size: 20),
                const SizedBox(width: 8),
                const Text("Savings Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTeal)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Net savings month-over-month for ${DateTime.now().year}.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) return const SizedBox.shrink();
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          int idx = value.toInt() - 1;
                          if (idx < 0 || idx >= 12) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(months[idx], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _primaryTeal,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true, 
                        color: _primaryTeal.withValues(alpha: 0.1),
                        gradient: LinearGradient(
                          colors: [_primaryTeal.withValues(alpha: 0.2), _primaryTeal.withValues(alpha: 0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: _primaryTeal, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text("Monthly Net Savings", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: _backgroundGray),
            const SizedBox(height: 20),
            // Broke Date Prediction UI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: predictionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: predictionColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: predictionColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Broke Date Prediction",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          predictionMessage,
                          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cumulative YTD:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  "₹${cumulative.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryTeal, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvelopeItem(String category, double spent, double limit, Color color) {
    final double ratio = limit > 0 ? (spent / limit) : 0;
    final bool isOver = ratio > 1.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category[0].toUpperCase() + category.substring(1),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isOver ? Colors.red : Colors.grey[700]
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _backgroundGray,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOver ? Colors.red : color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Overspent by ₹${(spent - limit).toStringAsFixed(0)}!",
                style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 50, color: _accentTeal.withValues(alpha: 0.5)),
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
