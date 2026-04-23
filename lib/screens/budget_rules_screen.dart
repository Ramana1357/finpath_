import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';
import 'dart:io';

class BudgetRulesScreen extends StatefulWidget {
  const BudgetRulesScreen({super.key});

  @override
  State<BudgetRulesScreen> createState() => _BudgetRulesScreenState();
}

class _BudgetRulesScreenState extends State<BudgetRulesScreen> {
  late double allowance;
  late double dreamVault;
  late double emergency;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final profile = context.read<AuthProvider>().profile;
      allowance = (profile?.allowancePercent ?? 50).toDouble();
      dreamVault = (profile?.dreamVaultPercent ?? 30).toDouble();
      emergency = (profile?.emergencyPercent ?? 20).toDouble();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text("Budget Rules", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set Your Allocation Rules",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              "Define how your incoming funds should be automatically distributed across your accounts.",
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 30),
            _buildRuleCard(
              context: context,
              title: "Allowance",
              subtitle: "Daily expenses, food, and transport",
              value: allowance,
              icon: Icons.wallet_outlined,
              onChanged: (val) => setState(() => allowance = val),
            ),
            const SizedBox(height: 20),
            _buildRuleCard(
              context: context,
              title: "Dream Vault",
              subtitle: "Long-term goals and big purchases",
              value: dreamVault,
              icon: Icons.shield_outlined,
              onChanged: (val) => setState(() => dreamVault = val),
            ),
            const SizedBox(height: 20),
            _buildRuleCard(
              context: context,
              title: "Emergency Provisions",
              subtitle: "Safety net for unexpected costs",
              value: emergency,
              icon: Icons.emergency_outlined,
              onChanged: (val) => setState(() => emergency = val),
            ),
            const SizedBox(height: 40),
            _buildTotalCheck(context),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (allowance + dreamVault + emergency == 100) 
                  ? () async {
                      final profile = authProvider.profile;
                      if (profile != null) {
                        final updatedProfile = profile.copyWith(
                          allowancePercent: allowance.toInt(),
                          dreamVaultPercent: dreamVault.toInt(),
                          emergencyPercent: emergency.toInt(),
                          updatedAt: DateTime.now(),
                        );
                        await authProvider.saveProfile(updatedProfile);
                        if (mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Row(
                                children: [
                                  Icon(Icons.info_outline, color: colorScheme.primary),
                                  const SizedBox(width: 10),
                                  const Text("Changes Saved"),
                                ],
                              ),
                              content: const Text("Budget rules have been updated successfully. To apply these changes, please restart the app."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  child: Text("SHUTDOWN APP", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                  disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                child: authProvider.isLoading 
                  ? CircularProgressIndicator(color: colorScheme.onPrimary)
                  : const Text("Save Budget Rules", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                    Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "${value.toInt()}%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.1),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCheck(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double total = allowance + dreamVault + emergency;
    bool isValid = total == 100;

    final Color cardColor = isValid ? (colorScheme.primaryContainer) : colorScheme.errorContainer;
    final Color textColor = isValid ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;
    final Color iconColor = isValid ? colorScheme.primary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: iconColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              isValid 
                ? "Distribution is perfect (100%)" 
                : "Total must equal 100% (Current: ${total.toInt()}%)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
