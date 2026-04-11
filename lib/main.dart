import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED THIS
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart'; // ADDED THIS

// Models & Utils
import 'models/transaction.dart';
import 'utils/sms_parser.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/cloud_feed_screen.dart'; // Added this

late final Isar isarDB;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dir = await getApplicationDocumentsDirectory();
  isarDB = await Isar.open(
    [ExpenseTransactionSchema],
    directory: dir.path,
  );

  runApp(const FinPathApp());
}

class FinPathApp extends StatelessWidget {
  const FinPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FINPATH',
      theme: ThemeData(
        primaryColor: const Color(0xFF006D77),
        fontFamily: 'Roboto',
      ),
      home: const MainEngine(),
    );
  }
}

class MainEngine extends StatefulWidget {
  const MainEngine({super.key});

  @override
  State<MainEngine> createState() => _MainEngineState();
}

class _MainEngineState extends State<MainEngine> {
  String _statusMessage = "Welcome to FinPath";
  static const EventChannel _smsChannel = EventChannel('com.finpath.messages');
  List<ExpenseTransaction> _savedMessages = [];
  int _userPoints = 1580; // Add this global state for points

  // Navigation State
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
    _startSmsListener();
  }

  Future<void> _startSmsListener() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      _smsChannel.receiveBroadcastStream().listen((dynamic event) {
        _saveSmsToDatabase(event);
      });
    }
  }

  Future<void> _saveSmsToDatabase(dynamic event) async {
    final Map<dynamic, dynamic> smsData = event;
    final String sender = smsData['sender'] ?? 'Unknown';
    final String message = smsData['message'] ?? '';
    final parsedData = SmsParser.parse(message);

    final newTransaction = ExpenseTransaction()
      ..title = sender
      ..amount = parsedData.amount
      ..date = DateTime.now()
      ..isExpense = parsedData.isExpense
      ..smsRawText = message;

    if (parsedData.amount > 0) {
      await isarDB.writeTxn(() async {
        await isarDB.expenseTransactions.put(newTransaction);
      });
    }

    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final transactions = await isarDB.expenseTransactions.where().findAll();
    setState(() {
      _savedMessages = transactions.reversed.toList();
    });
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final String? uid = userCredential.user?.uid;
      
      if (uid != null) {
        // Update status first
        setState(() {
          _statusMessage = "ID: $uid";
        });

        // Ping Firestore so the Python script knows this user is active
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'lastSeen': FieldValue.serverTimestamp(),
          'platform': 'android',
        });

        // Check if insights already exist for this user
        final doc = await FirebaseFirestore.instance.collection('insights').doc(uid).get();
        
        // If insights don't exist, it means the Python engine hasn't run for this ID yet
        if (!doc.exists && mounted) {
          _showRestartDialog();
        } else {
          setState(() {
            _statusMessage = "Cloud Synced: $uid";
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Login failed: $e";
      });
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Cloud Sync Required"),
        content: const Text("A new Cloud ID has been detected. To sync your insights, the app must close so the Python engine can process your account.\n\nPlease click 'Sync & Close' and then run the app again from Android Studio."),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // 1. Close the database safely
              await isarDB.close();
              // 2. Force terminate the app process
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D77),
              foregroundColor: Colors.white,
            ),
            child: const Text("Sync & Close"),
          ),
        ],
      ),
    );
  }

  // List of Screens for the Hub to swap between
  List<Widget> get _screens => [
    DashboardScreen(
      transactions: _savedMessages,
      statusMessage: _statusMessage,
      onGenerateId: _signInAnonymously,
      totalPoints: _userPoints, // Pass points to dashboard
    ),
    const VaultScreen(),
    FeedScreen(
      currentPoints: _userPoints,
      onPointsAwarded: (pts) {
        setState(() {
          _userPoints += pts;
        });
      },
    ),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006D77),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'Vault'),
          BottomNavigationBarItem(icon: Icon(Icons.chrome_reader_mode_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Insights'),
        ],
      ),
    );
  }
}