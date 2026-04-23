import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'insights_screen.dart';
import 'feed_screen.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // REQUIRED FOR DateFormat
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../utils/sms_parser.dart';
import '../main.dart'; // For backgroundMessageHandler

import '../presentation/screens/profile_setup_screen.dart'; // Just in case, but usually not needed here
import 'all_transactions_screen.dart';

class MainHub extends StatefulWidget {
  const MainHub({super.key});

  @override
  State<MainHub> createState() => _MainHubState();
}

class _MainHubState extends State<MainHub> {
  int _selectedIndex = 0;
  Stream<List<ExpenseTransaction>>? _localStream;
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    // Use the cacheService from Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cacheService = context.read<LocalCacheService>();
      setState(() {
        _localStream = cacheService.watchTransactions();
      });

      final cloudService = context.read<CloudService>();
      await cloudService.updateStreak();

      final authProvider = context.read<AuthProvider>();
      // Removed: cloudService.fetchAndSyncMonthlyInsight (No longer exists in CloudService)

      if (authProvider.needsRestoreCheck) {
        _showRestoreDialog();
      }

      await _initSmsIntegration();
    });
  }

  Future<void> _initSmsIntegration() async {
    // 1. Force Permission Dialog for Android 14
    PermissionStatus status = await Permission.sms.request();

    if (status.isGranted) {
      debugPrint("SMS Engine: ONLINE");

      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // IMMEDIATE VISUAL PROOF on your phone screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("SMS Detected... Processing Transaction"),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              duration: const Duration(seconds: 1),
            ),
          );
          _processMessage(message.body);
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }

  Future<void> _processMessage(String? body) async {
    if (body == null) return;

    final authProvider = context.read<AuthProvider>();
    final isEnabled = authProvider.profile?.smsTrackingEnabled ?? true;

    if (!isEnabled) {
      debugPrint("SMS tracking is disabled by user. Ignoring message.");
      return;
    }

    // RUN THE BRAIN (Regex Engine)
    final parsed = SmsParser.parse(body);

    if (parsed.amount > 0) {
      await _handleParsedTransaction(parsed, body);

      // SUCCESS POP-UP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logged: ₹${parsed.amount} - ${parsed.isExpense ? 'Expense' : 'Income'}"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRestoreDialog() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    final shouldRestore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Restore Data?"),
        content: const Text("Would you like to fetch your last 6 months of transaction history from the cloud, or start fresh?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Fresh Start"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text("Fetch 6 Months", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );

    if (shouldRestore == true) {
      await authProvider.restoreData();
    } else {
      // Clear any existing local data on "Fresh Start"
      if (user != null) {
        await authProvider.clearLocalData(user.uid);
      }
    }
    
    authProvider.completeRestoreCheck();
  }

  void _addPoints(int points) async {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    if (profile != null) {
      // Create string date YYYY-MM-DD
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final updatedProfile = profile.copyWith(
        lifetimePoints: profile.lifetimePoints + points,
        lastQuizDate: todayDate, // SYNC STRING DATE TO CLOUD
        quizStatus: "completed",
        updatedAt: DateTime.now(),
      );
      await authProvider.saveProfile(updatedProfile);
    }
  }

  void _showManualTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Food';
    bool isExpense = true;
    DateTime selectedDate = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    final categories = ['Food', 'Shopping', 'Transport', 'Entertainment', 'Health', 'Education', 'Bills', 'Income', 'Other'];

    showDialog(
      context: context,
      builder: (context) {
        String? dialogError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Manual Transaction", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(dialogError!, style: TextStyle(color: colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    TextField(
                      controller: titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: "Title (e.g. Starbucks)",
                        prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
                      ),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixIcon: Icon(Icons.currency_rupee, color: colorScheme.primary),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => selectedCategory = val!),
                      decoration: InputDecoration(
                        labelText: "Category",
                        prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SwitchListTile(
                      title: const Text("Is Expense?"),
                      value: isExpense,
                      onChanged: (val) => setDialogState(() => isExpense = val),
                      activeColor: colorScheme.error,
                      activeThumbColor: colorScheme.error,
                      inactiveThumbColor: colorScheme.primary, // Usually Income
                      inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    ListTile(
                      title: Text("Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
                      leading: Icon(Icons.calendar_today, color: colorScheme.primary),
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
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant))),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text;
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    
                    if (title.isEmpty || amount <= 0) {
                      setDialogState(() => dialogError = "Please enter valid title and amount");
                      return;
                    }

                    final cacheService = context.read<LocalCacheService>();
                    final authProvider = context.read<AuthProvider>();

                    // --- Balance Check for Expenses ---
                    if (isExpense) {
                      final totalNet = await cacheService.getTotalNetBalance();
                      
                      final profile = authProvider.profile;
                      final locked = profile?.totalLockedSavings ?? 0;
                      final vault = profile?.totalVaultSavings ?? 0;
                      final isCrisisMode = profile?.isCrisisMode ?? false;
                      final currentAllowance = totalNet - locked - vault;

                      if (amount > currentAllowance && !isCrisisMode) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                                  const SizedBox(width: 10),
                                  const Text("Balance Error"),
                                ],
                              ),
                              content: Text(
                                "This expense (₹$amount) exceeds your current allowance (₹${currentAllowance.toStringAsFixed(2)}).\n\n"
                                "To spend from your savings, please update your settings in the Profile."
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                        return; // Prevent adding the transaction
                      }
                    }

                    final tx = ExpenseTransaction(
                      title: title,
                      amount: amount,
                      category: selectedCategory,
                      isExpense: isExpense,
                      date: selectedDate,
                    );
                    
                    await authProvider.saveTransaction(tx);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Transaction added!"), backgroundColor: colorScheme.primary),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Save", style: TextStyle(color: colorScheme.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );

  }

  Future<void> _handleParsedTransaction(ParsedSms parsed, String rawText) async {
    final authProvider = context.read<AuthProvider>();

    // Create the transaction
    final tx = ExpenseTransaction(
      title: parsed.title,
      amount: parsed.amount,
      category: parsed.category,
      isExpense: parsed.isExpense,
      date: DateTime.now(),
      smsRawText: rawText,
    );

    // Use AuthProvider to save transaction which triggers the centralized allocation logic
    await authProvider.saveTransaction(tx);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final totalPoints = authProvider.profile?.lifetimePoints ?? 0;

    final List<Widget> _screens = [
      DashboardScreen(
        transactionsStream: _localStream ?? const Stream.empty(),
        statusMessage: "Local-First Storage",
        onGenerateId: () {},
        totalPoints: totalPoints,
        onSwitchTab: (index) => setState(() => _selectedIndex = index),
      ),
      const VaultScreen(),
      FeedScreen(
        currentPoints: totalPoints,
        onPointsAwarded: _addPoints,
      ),
      const InsightsScreen(),
    ];

    return Scaffold(
      extendBody: true, // This allows the Scaffold's body to extend behind the BottomNavigationBar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          onPressed: () => _showManualTransactionDialog(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Home'),
              _buildNavItem(1, Icons.lock_outline, Icons.lock, 'Vault'),
              const SizedBox(width: 48), // Space for the floating button
              _buildNavItem(2, Icons.rss_feed_outlined, Icons.rss_feed, 'Feed'),
              _buildNavItem(3, Icons.analytics_outlined, Icons.analytics, 'Insights'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          splashColor: colorScheme.primary.withValues(alpha: 0.15),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
