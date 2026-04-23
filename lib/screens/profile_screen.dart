import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../models/transaction.dart';
import 'budget_rules_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final int totalPoints;
  final Function(int)? onSwitchTab;
  const ProfileScreen({super.key, this.totalPoints = 1580, this.onSwitchTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final cloudService = Provider.of<CloudService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    final String name = profile?.name ?? "New User";
    final String bio = profile?.qualification ?? "Financial Explorer";

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          "My Profile",
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cloudService.getUserProfileStream(),
        builder: (context, snapshot) {
          int streak = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            streak = data['streak'] ?? 0;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeader(name, bio, profile),
                const SizedBox(height: 30),
                _buildGamificationCard(streak, profile),
                const SizedBox(height: 30),
                _buildGeneralSettingsList(name, bio, profile),
                const SizedBox(height: 30),
                _buildTestTools(context),
                const SizedBox(height: 40),
                _buildLogoutButton(authProvider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- EXPORT LOGIC ---



  void _exportFinancialReport(BuildContext context) async {
    final cacheService = context.read<LocalCacheService>();
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final transactions = await cacheService.getAllTransactions();

    if (transactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No transactions to export."), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Header(
          level: 0,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Finpath Financial Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF006D77))),
              pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
            ],
          ),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            pw.Text("Account Holder Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(thickness: 1),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Name: ${profile?.name ?? 'N/A'}"),
                    pw.Text("Age: ${profile?.age ?? 'N/A'}"),
                    pw.Text("Gender: ${profile?.gender ?? 'N/A'}"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Qualification: ${profile?.qualification ?? 'N/A'}"),
                    pw.Text("Financial Goal: ${profile?.financialDetails ?? 'N/A'}"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text("Transaction History", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF006D77)),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
              data: transactions.map((tx) {
                return [
                  DateFormat('dd/MM/yyyy').format(tx.date),
                  tx.title,
                  tx.category,
                  tx.isExpense ? 'Expense' : 'Income',
                  'Rs. ${tx.amount.toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Generated by Finpath App", style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
              ],
            ),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: "Finpath_Report_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF generation complete."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- UI BUILDERS ---

  Widget _buildHeader(String name, String bio, ProfileModel? profile) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.primary,
          backgroundImage: (profile?.profilePictureUrl != null && profile!.profilePictureUrl!.isNotEmpty)
              ? NetworkImage(profile.profilePictureUrl!)
              : null,
          child: (profile?.profilePictureUrl == null || profile!.profilePictureUrl!.isEmpty)
              ? Icon(Icons.person, size: 50, color: colorScheme.onPrimary)
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          bio,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildGamificationCard(int streak, ProfileModel? profile) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "$streak Day Streak",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  "${profile?.lifetimePoints ?? 0} Pts",
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsList(String name, String bio, ProfileModel? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text("Account Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildSettingsItem(
            Icons.person_outline,
            "Personal Information",
            onTap: () => _showPersonalInformationBottomSheet(context),
          ),
          _buildSettingsItem(
            Icons.speed_outlined,
            "Expense Limits",
            onTap: () => _showExpenseLimitsBottomSheet(context),
          ),
          _buildSettingsItem(
            Icons.tune_outlined, 
            "Budget Rules (50/30/20)",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetRulesScreen()),
              );
            },
          ),
          _buildSettingsItem(
            Icons.shield_outlined,
            "My Dream Vaults",
            onTap: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(1); // Switch to Vault tab
              }
            },
          ),
          _buildSettingsItem(
            Icons.file_download_outlined, 
            "Export Financial Report (PDF)",
            onTap: () => _exportFinancialReport(context),
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text("Preferences & Security", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildSmsToggle(context, profile),
          _buildCrisisModeCard(profile?.isCrisisMode ?? false),
          _buildThemeSelector(context),
          _buildBiometricToggle(context, profile),
          _buildSettingsItem(
            Icons.lock_outline, 
            "Change Password",
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsToggle(BuildContext context, ProfileModel? profile) {
    final bool isEnabled = profile?.smsTrackingEnabled ?? true;
    final authProvider = context.read<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(Icons.chat_bubble_outline, color: colorScheme.primary),
        title: const Text("SMS Auto-Tracking", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(
          isEnabled ? "Regex engine active" : "Tracking disabled",
          style: TextStyle(fontSize: 12, color: isEnabled ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        trailing: Switch(
          value: isEnabled,
          activeColor: colorScheme.primary,
          onChanged: (bool value) async {
            if (profile != null) {
              final updatedProfile = profile.copyWith(
                smsTrackingEnabled: value,
                updatedAt: DateTime.now(),
              );
              await authProvider.saveProfile(updatedProfile);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCrisisModeCard(bool isActive) {
    final authProvider = context.read<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isActive ? colorScheme.error.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.background,
          child: Icon(
            Icons.shield_outlined,
            color: isActive ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        title: Text(
          "Crisis Mode Setup",
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 15),
        ),
        subtitle: Text(
          isActive ? "Crisis Mode ACTIVE" : "Currently Safe (Inactive)",
          style: TextStyle(
            color: isActive ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (val) async {
            final latestProfile = await context.read<LocalCacheService>().getProfile(authProvider.user!.uid);
            if (latestProfile != null) {
              final updatedProfile = latestProfile.copyWith(
                isCrisisMode: val,
                updatedAt: DateTime.now(),
              );
              await authProvider.saveProfile(updatedProfile);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? "CRISIS MODE ENABLED: Emergency funds unlocked." : "Crisis mode disabled."),
                    backgroundColor: val ? Colors.orange : Colors.green,
                  ),
                );
              }
            }
          },
          activeColor: colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(BuildContext context, ProfileModel? profile) {
    final bool isEnabled = profile?.biometricEnabled ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(Icons.fingerprint, color: colorScheme.primary),
        title: const Text("Biometric Lock", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: isEnabled,
          activeColor: colorScheme.primary,
          onChanged: (bool value) => _handleBiometricToggle(context, value, profile),
        ),
      ),
    );
  }

  void _handleBiometricToggle(BuildContext context, bool newValue, ProfileModel? profile) async {
    if (profile == null) return;

    final authProvider = context.read<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final passwordController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Verify Identity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter your password to change biometric settings."),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Text("Confirm", style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final bool isPasswordValid = await authProvider.verifyPassword(passwordController.text);
      if (isPasswordValid) {
        final updatedProfile = profile.copyWith(
          biometricEnabled: newValue,
          updatedAt: DateTime.now(),
        );
        await authProvider.saveProfile(updatedProfile);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Biometric Lock ${newValue ? 'Enabled' : 'Disabled'}")),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid password"), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? badge, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  // --- DEVELOPER TOOLS ---

  Widget _buildTestTools(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: Text("Developer Tools (Testing)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        _buildSettingsItem(
          Icons.stars_outlined, 
          "Add Lifetime Points (Debug)",
          onTap: () => _showAddPointsDialog(context, profile, authProvider),
        ),
        _buildSettingsItem(
          Icons.bug_report_outlined, 
          "Generate Test Transactions",
          onTap: () => _generateTestData(context),
        ),
        _buildSettingsItem(
          Icons.delete_sweep_outlined, 
          "Clear Transaction History",
          onTap: () => _clearTransactionHistory(context),
        ),
        _buildSettingsItem(
          Icons.auto_delete_outlined, 
          "Nuke Isar DB (Full Reset)",
          onTap: () => _nukeIsarDatabase(context),
        ),
        _buildSettingsItem(
          Icons.refresh_outlined, 
          "Fresh Restart (Clean Profile)",
          onTap: () => _freshRestart(context),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "DEBUG: FRESH RESET ENABLED",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _generateTestData(BuildContext context) async {
    final cacheService = context.read<LocalCacheService>();
    final authProvider = context.read<AuthProvider>();

    final List<Map<String, dynamic>> testData = [
      {'title': 'Starbucks Coffee', 'amount': 450.0, 'category': 'Food', 'isExpense': true, 'daysAgo': 0},
      {'title': 'Amazon Shopping', 'amount': 1200.0, 'category': 'Shopping', 'isExpense': true, 'daysAgo': 1},
      {'title': 'Monthly Salary', 'amount': 45000.0, 'category': 'Income', 'isExpense': false, 'daysAgo': 2},
      {'title': 'Zomato Dinner', 'amount': 850.0, 'category': 'Food', 'isExpense': true, 'daysAgo': 3},
      {'title': 'Uber Ride', 'amount': 200.0, 'category': 'Transport', 'isExpense': true, 'daysAgo': 5},
      {'title': 'Netflix Sub', 'amount': 499.0, 'category': 'Entertainment', 'isExpense': true, 'daysAgo': 10},
    ];

    for (var data in testData) {
      final tx = ExpenseTransaction(
        title: data['title'],
        amount: data['amount'],
        category: data['category'],
        isExpense: data['isExpense'],
        date: DateTime.now().subtract(Duration(days: data['daysAgo'])),
      );
      await cacheService.saveTransaction(tx);
      
      // Allocate to Locked Savings if Income (+x)
      if (!tx.isExpense && authProvider.profile != null) {
        final profile = authProvider.profile!;
        final double allocationAmount = (tx.amount * profile.emergencyPercent) / 100;
        final updatedProfile = profile.copyWith(
          totalLockedSavings: profile.totalLockedSavings + allocationAmount,
          updatedAt: DateTime.now(),
        );
        await authProvider.saveProfile(updatedProfile);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generated 6 test transactions! Graphs updating..."), backgroundColor: Colors.green),
      );
    }
  }

  void _clearTransactionHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Data?"),
        content: const Text("This will permanently delete all local transaction history. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete Everything", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cacheService = context.read<LocalCacheService>();
      await cacheService.clearTransactions();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction history cleared."), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _nukeIsarDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuke Local Database?"),
        content: const Text("This will delete EVERYTHING in Isar (Profile, Vaults, Transactions). This is intended for developer testing."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Nuke It", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cacheService = context.read<LocalCacheService>();
      await cacheService.clearCache();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Isar DB Nuked! Please restart the app."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _freshRestart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fresh Restart?"),
        content: const Text("This will clear all transactions, vaults, and reset your Profile's savings/vault totals to zero. Account settings remain."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Restart Data", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cacheService = context.read<LocalCacheService>();
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;

      if (profile != null) {
        await cacheService.freshRestart(profile.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data reset! Total savings set to 0."), backgroundColor: Colors.orange),
          );
        }
      }
    }
  }

  // --- BOTTOM SHEETS & DIALOGS ---

  void _showPersonalInformationBottomSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Personal Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note, color: colorScheme.primary, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditPersonalInformationDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildInfoRow(Icons.badge_outlined, "Full Name", profile?.name ?? "N/A"),
            _buildInfoRow(Icons.calendar_month_outlined, "Age", profile?.age.toString() ?? "N/A"),
            _buildInfoRow(Icons.wc_outlined, "Gender", profile?.gender ?? "N/A"),
            _buildInfoRow(Icons.school_outlined, "Qualification", profile?.qualification ?? "N/A"),
            _buildInfoRow(Icons.account_balance_wallet_outlined, "Financial Details", profile?.financialDetails ?? "N/A"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditPersonalInformationDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;

    final nameController = TextEditingController(text: profile?.name);
    final ageController = TextEditingController(text: profile?.age.toString());
    final phoneController = TextEditingController(text: profile?.phoneNo);
    final qualificationController = TextEditingController(text: profile?.qualification);
    final financialController = TextEditingController(text: profile?.financialDetails);
    final profilePicController = TextEditingController(text: profile?.profilePictureUrl);
    String? selectedGender = profile?.gender;

    final _editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Update Profile", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledTextField(
                    nameController, 
                    "Name", 
                    Icons.person_outline,
                    maxLength: 20,
                    validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                  ),
                  _buildStyledTextField(
                    ageController, 
                    "Age", 
                    Icons.calendar_today, 
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final age = int.tryParse(value);
                      if (age == null) return 'Invalid number';
                      if (age < 16) return 'Must be 16+';
                      if (age > 120) return 'Invalid age';
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    phoneController,
                    "Phone Number",
                    Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (value.length != 10) return 'Enter 10 digits';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: ["Male", "Female", "Other"].contains(selectedGender) ? selectedGender : null,
                    items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setDialogState(() => selectedGender = val),
                    validator: (value) => value == null ? "Required" : null,
                    decoration: InputDecoration(
                      labelText: "Gender",
                      prefixIcon: Icon(Icons.wc, color: colorScheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildStyledTextField(
                    qualificationController, 
                    "Qualification", 
                    Icons.school_outlined,
                  ),
                  _buildStyledTextField(
                    financialController, 
                    "Financial Details", 
                    Icons.wallet_outlined,
                  ),
                  _buildStyledTextField(profilePicController, "Profile Picture URL", Icons.image_outlined),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)))
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_editFormKey.currentState!.validate()) return;
                
                if (profile == null) return;
                final updatedProfile = profile.copyWith(
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? profile.age,
                  phoneNo: phoneController.text,
                  gender: selectedGender ?? profile.gender,
                  qualification: qualificationController.text,
                  financialDetails: financialController.text,
                  profilePictureUrl: profilePicController.text,
                  updatedAt: DateTime.now(),
                );
                await authProvider.saveProfile(updatedProfile);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_reset, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                "Change Password",
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Secure your account with a new password.",
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  hintText: "At least 6 characters",
                  prefixIcon: const Icon(Icons.password, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.verified_user_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final pass = newPasswordController.text;
                final confirm = confirmPasswordController.text;

                if (pass.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.orange),
                  );
                  return;
                }
                
                // Password Complexity Validation
                if (pass.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password must be at least 8 characters"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                if (!RegExp(r'[A-Z]').hasMatch(pass)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password must contain at least one uppercase letter"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                if (!RegExp(r'[0-9]').hasMatch(pass)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password must contain at least one number"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pass)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password must contain at least one special character"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }

                if (pass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }

                try {
                  await authProvider.updatePassword(pass);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Password updated successfully!"),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Update Password", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseLimitsBottomSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;
    if (profile == null) return;

    final dailyController = TextEditingController(text: profile.dailyLimit.toStringAsFixed(0));
    final monthlyController = TextEditingController(text: profile.monthlyLimit.toStringAsFixed(0));
    final _limitsFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _limitsFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Expense Limits",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  "Adjust your daily and monthly spending targets. These changes will reflect in your dashboard immediately.",
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                ),
                const SizedBox(height: 25),
                _buildStyledTextField(
                  dailyController, 
                  "Daily Limit (₹)", 
                  Icons.today_outlined, 
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    final n = double.tryParse(val);
                    if (n == null || n <= 0) return "Min Amount";
                    return null;
                  },
                ),
                _buildStyledTextField(
                  monthlyController, 
                  "Monthly Limit (₹)", 
                  Icons.calendar_month_outlined, 
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    final n = double.tryParse(val);
                    if (n == null || n <= 0) return "Min Amount";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_limitsFormKey.currentState!.validate()) return;

                      final dLimit = double.tryParse(dailyController.text) ?? profile.dailyLimit;
                      final mLimit = double.tryParse(monthlyController.text) ?? profile.monthlyLimit;
                    
                      final updatedProfile = profile.copyWith(
                        dailyLimit: dLimit,
                        monthlyLimit: mLimit,
                        updatedAt: DateTime.now(),
                      );
                      
                      await authProvider.saveProfile(updatedProfile);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Expense limits updated!"), backgroundColor: Colors.green),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _showAddPointsDialog(BuildContext context, ProfileModel? profile, AuthProvider authProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Points"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Points to add", hintText: "e.g. 500"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final pts = int.tryParse(controller.text) ?? 0;
              if (pts > 0 && profile != null) {
                final updatedProfile = profile.copyWith(
                  lifetimePoints: (profile.lifetimePoints ?? 0) + pts,
                  updatedAt: DateTime.now(),
                );
                await authProvider.saveProfile(updatedProfile);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$pts points added!")),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(Icons.brightness_medium_outlined, color: colorScheme.primary),
        title: const Text("App Theme", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: DropdownButton<ThemeMode>(
          value: authProvider.themeMode,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
            DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
            DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
          ],
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              authProvider.setThemeMode(mode);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: () async {
            final result = await showDialog<int>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Log Out"),
                content: const Text(
                  "Data regarding dream vaults and savings will be permanently deleted from this device unless backed up. Choose 'Backup & Logout' to sync with cloud, or 'Just Logout' to clear local data.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 0), // Cancel
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 1), // Logout No Backup
                    child: Text("Just Logout", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 2), // Logout With Backup
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
                    child: Text("Backup & Logout", style: TextStyle(color: colorScheme.onPrimary)),
                  ),
                ],
              ),
            );

            if (result != null && result > 0) {
              final bool shouldBackup = (result == 2);
              await authProvider.logout(shouldBackup: shouldBackup);
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  // --- HELPER UI ---

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {TextInputType? keyboardType, String? Function(String?)? validator, List<TextInputFormatter>? inputFormatters, int? maxLength}
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
