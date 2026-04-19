import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // REQUIRED FOR DateFormat
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';
import '../models/transaction.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../utils/sms_parser.dart';
import '../main.dart'; // For backgroundMessageHandler

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

      final cloudService = CloudService();
      await cloudService.updateStreak();

      final authProvider = context.read<AuthProvider>();
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
            const SnackBar(
              content: Text("SMS Detected... Processing Transaction"),
              backgroundColor: Colors.blueGrey,
              duration: Duration(seconds: 1),
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
          backgroundColor: const Color(0xFF006D77),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006D77)),
            child: const Text("Fetch 6 Months", style: TextStyle(color: Colors.white)),
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

  Future<void> _handleParsedTransaction(ParsedSms parsed, String rawText) async {
    final authProvider = context.read<AuthProvider>();

    // Create the transaction
    final tx = ExpenseTransaction(
      title: parsed.title,
      amount: parsed.amount,
      category: parsed.isExpense ? "Other" : "Income",
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006D77),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Vault'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Insights'),
        ],
      ),
    );
  }
}
