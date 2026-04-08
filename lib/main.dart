import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Models & Utils
import 'models/transaction.dart';
import 'utils/sms_parser.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/insights_screen.dart';

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
      setState(() {
        _statusMessage = "ID: ${userCredential.user?.uid}";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Login failed: $e";
      });
    }
  }

  // List of Screens for the Hub to swap between
  List<Widget> get _screens => [
    DashboardScreen(
      transactions: _savedMessages,
      statusMessage: _statusMessage,
      onGenerateId: _signInAnonymously,
    ),
    const VaultScreen(),
    const FeedScreen(),
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