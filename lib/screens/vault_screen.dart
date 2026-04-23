import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

// --- DATA MODEL (Ready for Backend Integration) ---
import '../data/models/vault_model.dart';
import '../data/models/profile_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    
    final cacheService = context.read<LocalCacheService>();
    final uid = authProvider.user?.uid;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: StreamBuilder<ProfileModel?>(
          stream: uid != null ? cacheService.watchProfile(uid) : Stream.value(null),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            final double totalLockedSavings = profile?.totalLockedSavings ?? 0.0;
            final int emergencyPercent = profile?.emergencyPercent ?? 20;
            final int points = profile?.lifetimePoints ?? 0;
            
            // Level Logic: 0-499: Novice, 500-999: Apprentice, etc.
            final int userLevel = (points ~/ 500) + 1;
            final double levelProgress = (points % 500) / 500;
            
            String userLevelName;
            if (userLevel == 1) userLevelName = "Novice Saver";
            else if (userLevel == 2) userLevelName = "Apprentice Saver";
            else if (userLevel == 3) userLevelName = "Budget Architect";
            else if (userLevel == 4) userLevelName = "Wealth Builder";
            else if (userLevel == 5) userLevelName = "Vault Guardian";
            else userLevelName = "FinMaster";

            return StreamBuilder<List<VaultModel>>(
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
                            Text(
                              "My Dream Vaults",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildVaultList(vaults, vaults),
                            const SizedBox(height: 10),
                            _buildAddVaultButton(context, vaults),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            );
          }
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildAddVaultButton(BuildContext context, List<VaultModel> vaults) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showAddVaultDialog(context, vaults),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              "Add New Vault",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditVaultDialog(BuildContext context, VaultModel vault, List<VaultModel> allVaults) {
    final titleController = TextEditingController(text: vault.title);
    final targetController = TextEditingController(text: vault.targetAmount.toString());
    final allocationController = TextEditingController(text: vault.allocationPercent.toString());
    final cacheService = context.read<LocalCacheService>();

    showDialog(
      context: context,
      builder: (context) {
        String? dialogError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Vault"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(dialogError!,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Goal Title"),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: targetController,
                      decoration:
                          const InputDecoration(labelText: "Target Amount (₹)"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: allocationController,
                      decoration: const InputDecoration(
                        labelText: "Allocation Share (%)",
                        helperText: "Percentage of your 30% savings pot",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Vault?"),
                        content: const Text(
                            "This will permanently remove this vault and its history."),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await cacheService.deleteVault(vault.id);
                      if (context.mounted) {
                        Navigator.pop(context); // Close edit dialog
                      }
                    }
                  },
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final target = double.tryParse(targetController.text) ?? 0;
                    final allocation =
                        double.tryParse(allocationController.text) ?? 0.0;

                    // Calculate total share of OTHER incomplete vaults
                    final double otherVaultsShare = allVaults
                        .where((v) =>
                            v.id != vault.id &&
                            (v.currentAmount < v.targetAmount))
                        .fold(0.0, (sum, v) => sum + v.allocationPercent);

                    if (titleController.text.isNotEmpty && target > 0) {
                      if (otherVaultsShare + allocation > 100) {
                        setDialogState(() => dialogError =
                            "Total allocation exceeds 100% (Already using ${otherVaultsShare.toStringAsFixed(0)}%)");
                        return;
                      }

                      final updatedVault = vault.copyWith(
                        title: titleController.text,
                        targetAmount: target,
                        allocationPercent:
                            double.tryParse(allocationController.text) ?? 0.0,
                        updatedAt: DateTime.now(),
                      );
                      await cacheService.saveVault(updatedVault);
                      if (context.mounted) Navigator.pop(context);
                    } else {
                      setDialogState(() => dialogError =
                          "Please enter a valid target amount (> 0)");
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text("Save Changes",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showAddVaultDialog(BuildContext context, List<VaultModel> allVaults) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final allocationController = TextEditingController(text: "0");
    final cacheService = context.read<LocalCacheService>();

    showDialog(
      context: context,
      builder: (context) {
        String? dialogError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create New Vault"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(dialogError!,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Goal Title (e.g. New Bike)",
                        hintText: "What are you saving for?",
                      ),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(
                        labelText: "Target Amount (₹)",
                        hintText: "How much do you need?",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
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
                    final target = double.tryParse(targetController.text) ?? 0;
                    final allocation =
                        double.tryParse(allocationController.text) ?? 0.0;

                    // Calculate total share of existing incomplete vaults
                    final double currentTotalShare = allVaults
                        .where((v) => v.currentAmount < v.targetAmount)
                        .fold(0.0, (sum, v) => sum + v.allocationPercent);

                    if (titleController.text.isNotEmpty && target > 0) {
                      if (currentTotalShare + allocation > 100) {
                        setDialogState(() => dialogError =
                            "Total allocation exceeds 100% (Already using ${currentTotalShare.toStringAsFixed(0)}%)");
                        return;
                      }

                      final vault = VaultModel(
                        title: titleController.text,
                        targetAmount: target,
                        allocationPercent:
                            double.tryParse(allocationController.text) ?? 0.0,
                        iconName: "stars", // Default icon
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await cacheService.saveVault(vault);
                      if (context.mounted) Navigator.pop(context);
                    } else {
                      setDialogState(() => dialogError =
                          "Please enter a valid target amount (> 0)");
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text("Create Vault",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
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
              IconButton(
                icon: Icon(Icons.notifications_none, color: colorScheme.onPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: colorScheme.secondary,
                  child: Text(initials,
                      style: TextStyle(
                          color: colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard(double amount, int percent) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Locked Savings ($percent%)",
            style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            "₹${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard(int level, String name, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentYellow = colorScheme.tertiary;

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentYellow, width: 8)),
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
                        Icon(Icons.emoji_events_outlined,
                            color: accentYellow),
                        const SizedBox(width: 10),
                        Flexible( 
                          child: Text(
                            "Level $level: $name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${(progress * 100).toInt()}% to Level ${level + 1}",
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.background,
                color: accentYellow,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultList(List<VaultModel> vaults, List<VaultModel> allVaults) {
    final colorScheme = Theme.of(context).colorScheme;
    if (vaults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: colorScheme.surface),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_outlined, size: 40, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 15),
            Text(
              "No vaults created yet.",
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 5),
            Text(
              "Click below to start your first saving goal!",
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
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
        final bool isCompleted = vault.currentAmount >= vault.targetAmount;
        final colorScheme = Theme.of(context).colorScheme;
        const progressGreen = Color(0xFF43AA8B);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: isCompleted ? Border.all(color: colorScheme.primary, width: 2) : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.background,
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.stars, 
                      color: isCompleted ? colorScheme.primary : colorScheme.primary, 
                      size: 20
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              vault.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                        Text(
                          "Share: ${vault.allocationPercent.toInt()}% | ₹${vault.currentAmount.toInt()} / ₹${vault.targetAmount.toInt()}",
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${(vault.percentage * 100).toInt()}%",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      isCompleted ? Icons.delete_outline : Icons.edit_outlined, 
                      size: 20, 
                      color: isCompleted ? colorScheme.error : colorScheme.onSurfaceVariant
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => isCompleted 
                        ? _confirmClaimVault(context, vault)
                        : _showEditVaultDialog(context, vault, allVaults),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: vault.percentage.clamp(0.0, 1.0),
                backgroundColor: colorScheme.background,
                color: colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmClaimVault(BuildContext context, VaultModel vault) {
    final cacheService = context.read<LocalCacheService>();
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Claim Goal?"),
        content: Text("You've reached your goal for '${vault.title}'! Claiming it will remove it from your list."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Not Yet")),
          ElevatedButton(
            onPressed: () async {
              await cacheService.deleteVault(vault.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Text("Claim & Remove", style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }
}
