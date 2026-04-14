import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import '../main.dart'; // To access backgroundMessageHandler
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../utils/sms_parser.dart';

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
    
    // START THE SMS ENGINE
    _initSmsIntegration();

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

    // RUN THE BRAIN (Regex Engine)
    final parsed = SmsParser.parse(body);

    if (parsed.amount > 0) {
      final cacheService = context.read<LocalCacheService>();
      
      final newTx = ExpenseTransaction(
        title: parsed.title,
        amount: parsed.amount,
        date: DateTime.now(),
        isExpense: parsed.isExpense,
        category: 'SMS Auto-Log',
        smsRawText: body,
      );

      await cacheService.saveTransaction(newTx);

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

  // ... rest of the file ...
  void _showRestoreDialog() async {
    final authProvider = context.read<AuthProvider>();
    
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
    }
    
    authProvider.completeRestoreCheck();
  }

  void _addPoints(int points) async {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    if (profile != null) {
      final updatedProfile = profile.copyWith(
        lifetimePoints: profile.lifetimePoints + points,
        lastQuizDate: DateTime.now(),
        quizStatus: "completed",
        updatedAt: DateTime.now(),
      );
      await authProvider.saveProfile(updatedProfile);
    }
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
