import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import 'profile_screen.dart';

// --- DATA MODEL (Ready for Backend Integration) ---
import '../data/models/vault_model.dart';
import '../services/local_cache_service.dart';

class DreamVaultModel {
  final String title;
  final IconData icon;
  final double currentAmount;
  final double targetAmount;

  DreamVaultModel({
    required this.title,
    required this.icon,
    required this.currentAmount,
    required this.targetAmount,
  });

  double get percentage => (currentAmount / targetAmount);
}

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  // --- STATE VARIABLES ---
  bool _isCrisisModeActive = false;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentYellow = Color(0xFFF9C74F);
  static const Color _progressGreen = Color(0xFF43AA8B);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    
    final double totalLockedSavings = profile?.totalLockedSavings ?? 0.0;
    final int emergencyPercent = profile?.emergencyPercent ?? 20;
    final int userLevel = (profile?.lifetimePoints ?? 0) ~/ 500 + 1;
    final String userLevelName = userLevel > 5 ? "FinMaster" : "Novice Saver";
    final double levelProgress = ((profile?.lifetimePoints ?? 0) % 500) / 500;
    
    final cacheService = context.read<LocalCacheService>();

    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: StreamBuilder<List<VaultModel>>(
          stream: cacheService.watchVaults(),
          builder: (context, snapshot) {
            final vaults = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalSavingsCard(totalLockedSavings, emergencyPercent),
                        const SizedBox(height: 20),
                        _buildGamificationCard(userLevel, userLevelName, levelProgress),
                        const SizedBox(height: 25),
                        const Text(
                          "My Dream Vaults",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildVaultList(vaults),
                        const SizedBox(height: 20),
                        _buildCrisisModeCard(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVaultDialog(context),
        backgroundColor: _primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  void _showAddVaultDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final allocationController = TextEditingController(text: "0");
    final cacheService = context.read<LocalCacheService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Vault"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Goal Title (e.g. New Bike)",
                  hintText: "What are you saving for?",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(
                  labelText: "Target Amount (₹)",
                  hintText: "How much do you need?",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: allocationController,
                decoration: const InputDecoration(
                  labelText: "Allocation Share (%)",
                  hintText: "e.g. 50 for 50% of dream pot",
                  helperText: "Percentage of your 30% savings pot",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && targetController.text.isNotEmpty) {
                final vault = VaultModel(
                  title: titleController.text,
                  targetAmount: double.parse(targetController.text),
                  allocationPercent: double.tryParse(allocationController.text) ?? 0.0,
                  iconName: "stars", // Default icon
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await cacheService.saveVault(vault);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal),
            child: const Text("Create Vault", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
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
                onPressed: () {},
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF83C5BE),
                  child: Text(initials,
                      style: const TextStyle(
                          color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard(double amount, int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF023E3E), // Darker teal as per image
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Locked Savings ($percent%)",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            "₹${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard(int level, String name, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _accentYellow, width: 8)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( 
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined,
                            color: _accentYellow),
                        const SizedBox(width: 10),
                        Flexible( 
                          child: Text(
                            "Level $level: $name",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${(progress * 100).toInt()}% to Level ${level + 1}",
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: _backgroundGray,
                color: _accentYellow,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultList(List<VaultModel> vaults) {
    if (vaults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_outlined, size: 40, color: _primaryTeal.withOpacity(0.5)),
            const SizedBox(height: 15),
            const Text(
              "No vaults created yet.",
              style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTeal),
            ),
            const SizedBox(height: 5),
            const Text(
              "Tap '+' to start your first saving goal!",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vaults.length,
      itemBuilder: (context, index) {
        final vault = vaults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: _backgroundGray,
                    child: Icon(Icons.stars, color: _primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vault.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Share: ${vault.allocationPercent.toInt()}% | ₹${vault.currentAmount.toInt()} / ₹${vault.targetAmount.toInt()}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${(vault.percentage * 100).toInt()}%",
                    style: const TextStyle(
                      color: _progressGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: vault.percentage.clamp(0.0, 1.0),
                backgroundColor: _backgroundGray,
                color: _progressGreen,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCrisisModeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _backgroundGray,
            child: Icon(
              Icons.shield_outlined,
              color: _isCrisisModeActive ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Crisis Mode Setup",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
                Text(
                  _isCrisisModeActive
                      ? "Crisis Mode ACTIVE"
                      : "Currently Safe (Inactive)",
                  style: TextStyle(
                    color: _isCrisisModeActive ? Colors.red : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCrisisModeActive,
            onChanged: (val) {
              setState(() {
                _isCrisisModeActive = val;
              });
            },
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
