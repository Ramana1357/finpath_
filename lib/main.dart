import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction.dart';
import 'screens/dashboard_screen.dart'; // Import the new screen
import 'utils/sms_parser.dart';

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
      _savedMessages = transactions.reversed.toList(); // Newest first
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

  @override
  Widget build(BuildContext context) {
    // Navigate to Dashboard and pass the data/callbacks
    return DashboardScreen(
      transactions: _savedMessages,
      statusMessage: _statusMessage,
      onGenerateId: _signInAnonymously,
    );
  }
}