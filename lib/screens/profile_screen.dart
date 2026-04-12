import 'package:flutter/material.dart';
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
  bool _isSmsListenerActive = true;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final cloudService = CloudService();

    final String name = profile?.name ?? "New User";
    final String bio = profile?.qualification ?? "Financial Explorer";

    return Scaffold(
      backgroundColor: _backgroundGray,
      appBar: AppBar(
        backgroundColor: _primaryTeal,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                _buildHeader(name, bio),
                const SizedBox(height: 30),
                _buildGamificationCard(streak, profile),
                const SizedBox(height: 30),
                _buildSettingsList(name, bio, profile),
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

  Widget _buildHeader(String name, String bio) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: _primaryTeal,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primaryTeal,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  onPressed: () => _showEditPersonalInformationDialog(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        Text(
          bio,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildGamificationCard(int streak, ProfileModel? profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
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
            color: Colors.grey[300],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  "${profile?.lifetimePoints ?? 0} Pts",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(String name, String bio, ProfileModel? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsItem(
            Icons.person_outline,
            "Personal Information",
            onTap: () => _showPersonalInformationBottomSheet(context),
          ),
          _buildSettingsItem(
            Icons.shield_outlined,
            "My Dream Vaults",
            onTap: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(1); // Switch to Vault tab
                Navigator.pop(context); // Close Profile
              }
            },
          ),
          _buildSettingsItem(
            Icons.file_download_outlined, 
            "Export Data",
            onTap: () => _exportTransactionData(context),
          ),
          const SizedBox(height: 20),
          _buildSettingsItem(
            Icons.chat_bubble_outline, 
            "SMS Listener", 
            badge: _isSmsListenerActive ? "Active" : "Inactive",
            onTap: () {
              setState(() {
                _isSmsListenerActive = !_isSmsListenerActive;
              });
            }
          ),
          _buildSettingsItem(
            Icons.tune_outlined, 
            "Budget Rules",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetRulesScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildBiometricToggle(context, profile),
          _buildSettingsItem(
            Icons.lock_outline, 
            "Change Password",
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 20),
          _buildTestTools(context),
        ],
      ),
    );
  }

  Widget _buildTestTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: Text("Developer Tools (Testing)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        _buildSettingsItem(
          Icons.bug_report_outlined, 
          "Generate Test Transactions",
          onTap: () => _generateTestData(context),
        ),
        _buildSettingsItem(
          Icons.add_circle_outline, 
          "Add Manual Transaction",
          onTap: () => _showManualTransactionDialog(context),
        ),
        _buildSettingsItem(
          Icons.delete_sweep_outlined, 
          "Clear Transaction History",
          onTap: () => _clearTransactionHistory(context),
        ),
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

    List<ExpenseTransaction> createdTxs = [];
    for (var data in testData) {
      final tx = ExpenseTransaction(
        title: data['title'],
        amount: data['amount'],
        category: data['category'],
        isExpense: data['isExpense'],
        date: DateTime.now().subtract(Duration(days: data['daysAgo'])),
      );
      await cacheService.saveTransaction(tx);
      createdTxs.add(tx);
    }

    // Trigger analysis with the new local data
    await CloudService().runAutoAnalysisFromLocal(createdTxs);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generated 6 test transactions! Graphs updating..."), backgroundColor: Colors.green),
      );
    }
  }

  void _showManualTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Food';
    bool isExpense = true;
    DateTime selectedDate = DateTime.now();

    final categories = ['Food', 'Shopping', 'Transport', 'Entertainment', 'Health', 'Education', 'Bills', 'Income', 'Other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Manual Transaction"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title (e.g. Starbucks)"),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text("Is Expense?"),
                  value: isExpense,
                  onChanged: (val) => setDialogState(() => isExpense = val),
                  activeColor: Colors.redAccent,
                  inactiveThumbColor: Colors.green,
                  inactiveTrackColor: Colors.green.withOpacity(0.5),
                ),
                ListTile(
                  title: Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                
                if (title.isEmpty || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter valid title and amount"), backgroundColor: Colors.redAccent),
                  );
                  return;
                }

                final cacheService = context.read<LocalCacheService>();
                final tx = ExpenseTransaction(
                  title: title,
                  amount: amount,
                  category: selectedCategory,
                  isExpense: isExpense,
                  date: selectedDate,
                );
                
                await cacheService.saveTransaction(tx);
                await CloudService().runAutoAnalysisFromLocal([tx]);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction added!"), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactionData(BuildContext context) async {
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
      
      // For Android/iOS, getApplicationDocumentsDirectory is a safe local storage.
      // On Android, this usually maps to /data/user/0/com.package.name/app_flutter
      // To save to the "Downloads" or "Documents" folder accessible by user, 
      // we would need additional permissions or use the printing package's built-in save.
      
      // However, we will use the Printing package to show a 'Save as PDF' dialog 
      // which is the most reliable way for users to pick a local destination.
      
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

  Widget _buildBiometricToggle(BuildContext context, ProfileModel? profile) {
    final bool isEnabled = profile?.biometricEnabled ?? false;
    final authProvider = context.read<AuthProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.fingerprint, color: _primaryTeal),
        title: const Text("Biometric Lock", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: isEnabled,
          activeColor: _primaryTeal,
          onChanged: (bool value) => _handleBiometricToggle(context, value, profile),
        ),
      ),
    );
  }

  void _handleBiometricToggle(BuildContext context, bool newValue, ProfileModel? profile) async {
    if (profile == null) return;

    final authProvider = context.read<AuthProvider>();
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
            style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
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

  void _showPersonalInformationBottomSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
                const Text(
                  "Personal Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: _primaryTeal, size: 28),
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
                  backgroundColor: _primaryTeal,
                  foregroundColor: Colors.white,
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

    final nameController = TextEditingController(text: profile?.name);
    final ageController = TextEditingController(text: profile?.age.toString());
    final qualificationController = TextEditingController(text: profile?.qualification);
    final financialController = TextEditingController(text: profile?.financialDetails);
    String? selectedGender = profile?.gender;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Update Profile", style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyledTextField(nameController, "Name", Icons.person_outline),
                _buildStyledTextField(ageController, "Age", Icons.calendar_today, keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: ["Male", "Female", "Other"].contains(selectedGender) ? selectedGender : null,
                  items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setDialogState(() => selectedGender = val),
                  decoration: InputDecoration(
                    labelText: "Gender",
                    prefixIcon: const Icon(Icons.wc, color: _primaryTeal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 15),
                _buildStyledTextField(qualificationController, "Qualification", Icons.school_outlined),
                _buildStyledTextField(financialController, "Financial Details", Icons.wallet_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () async {
                if (profile == null) return;
                final updatedProfile = profile.copyWith(
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? profile.age,
                  gender: selectedGender ?? profile.gender,
                  qualification: qualificationController.text,
                  financialDetails: financialController.text,
                  updatedAt: DateTime.now(),
                );
                await authProvider.saveProfile(updatedProfile);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primaryTeal, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryTeal, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? badge, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _primaryTeal),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
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
                  color: _primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset, color: _primaryTeal),
              ),
              const SizedBox(width: 12),
              const Text(
                "Change Password",
                style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Secure your account with a new password.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primaryTeal, width: 2),
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
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primaryTeal, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
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
                if (pass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password too short"), backgroundColor: Colors.redAccent),
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
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
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

  Widget _buildLogoutButton(AuthProvider authProvider) {
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
                content: const Text("Would you like to save your last 6 months of data to the cloud?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 0), // Cancel
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 1), // Logout No Backup
                    child: const Text("Just Logout", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 2), // Logout With Backup
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal),
                    child: const Text("Backup & Logout", style: TextStyle(color: Colors.white)),
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
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
