import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';
import '../models/transaction.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';

class MainHub extends StatefulWidget {
  const MainHub({super.key});

  @override
  State<MainHub> createState() => _MainHubState();
}

class _MainHubState extends State<MainHub> {
  int _selectedIndex = 0;
  Stream<List<ExpenseTransaction>>? _localStream;

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
    });
  }

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
    final cloudService = CloudService();
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
