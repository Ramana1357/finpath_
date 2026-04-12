import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';

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

  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);

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
    
    return Scaffold(
      backgroundColor: _backgroundGray,
      appBar: AppBar(
        backgroundColor: _primaryTeal,
        title: const Text("Budget Rules", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Your Allocation Rules",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryTeal),
            ),
            const SizedBox(height: 10),
            Text(
              "Define how your incoming funds should be automatically distributed across your accounts.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildRuleCard(
              title: "Allowance",
              subtitle: "Daily expenses, food, and transport",
              value: allowance,
              icon: Icons.wallet_outlined,
              onChanged: (val) => setState(() => allowance = val),
            ),
            const SizedBox(height: 20),
            _buildRuleCard(
              title: "Dream Vault",
              subtitle: "Long-term goals and big purchases",
              value: dreamVault,
              icon: Icons.shield_outlined,
              onChanged: (val) => setState(() => dreamVault = val),
            ),
            const SizedBox(height: 20),
            _buildRuleCard(
              title: "Emergency Provisions",
              subtitle: "Safety net for unexpected costs",
              value: emergency,
              icon: Icons.emergency_outlined,
              onChanged: (val) => setState(() => emergency = val),
            ),
            const SizedBox(height: 40),
            _buildTotalCheck(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (allowance + dreamVault + emergency == 100) 
                  ? () async {
                      final profile = authProvider.profile;
                      if (profile != null) {
                        final updatedProfile = ProfileModel(
                          uid: profile.uid,
                          name: profile.name,
                          age: profile.age,
                          email: profile.email,
                          gender: profile.gender,
                          financialDetails: profile.financialDetails,
                          qualification: profile.qualification,
                          allowancePercent: allowance.toInt(),
                          dreamVaultPercent: dreamVault.toInt(),
                          emergencyPercent: emergency.toInt(),
                          createdAt: profile.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        await authProvider.saveProfile(updatedProfile);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Budget rules saved successfully!")),
                          );
                          Navigator.pop(context);
                        }
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: authProvider.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Budget Rules", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _primaryTeal.withOpacity(0.1),
                child: Icon(icon, color: _primaryTeal, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "${value.toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryTeal),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primaryTeal,
              inactiveTrackColor: _primaryTeal.withOpacity(0.1),
              thumbColor: _primaryTeal,
              overlayColor: _primaryTeal.withOpacity(0.2),
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

  Widget _buildTotalCheck() {
    double total = allowance + dreamVault + emergency;
    bool isValid = total == 100;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isValid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isValid ? Colors.green[200]! : Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              isValid 
                ? "Distribution is perfect (100%)" 
                : "Total must equal 100% (Current: ${total.toInt()}%)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isValid ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
