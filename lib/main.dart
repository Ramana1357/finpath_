import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For the Kotlin Bridge
import 'package:permission_handler/permission_handler.dart'; // For the pop-up
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction.dart';

// Global database variable for easy access
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
      title: 'FinPath Gateway',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _statusMessage = "Not logged in";

  // 1. Connect to the Kotlin Bridge
  static const EventChannel _smsChannel = EventChannel('com.finpath.messages');

  // 2. A list to hold our database transactions
  List<ExpenseTransaction> _savedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
    _startSmsListener();
  }

  Future<void> _startSmsListener() async {
    // Ask the user for permission
    var status = await Permission.sms.request();

    if (status.isGranted) {
      // Start listening to Kotlin!
      _smsChannel.receiveBroadcastStream().listen((dynamic event) {
        _saveSmsToDatabase(event);
      });
    }
  }

  Future<void> _saveSmsToDatabase(dynamic event) async {
    final Map<dynamic, dynamic> smsData = event;
    final String sender = smsData['sender'] ?? 'Unknown';
    final String message = smsData['message'] ?? '';

    // Create a new database entry (Blueprint)
    final newTransaction = ExpenseTransaction()
      ..title = sender
      ..amount = 0.0 // We will write regex to extract real money later!
      ..date = DateTime.now()
      ..isExpense = true
      ..smsRawText = message;

    // Save it to Isar permanently
    await isarDB.writeTxn(() async {
      await isarDB.expenseTransactions.put(newTransaction);
    });

    // Refresh the screen
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    // Fetch all saved transactions from Isar
    final transactions = await isarDB.expenseTransactions.where().findAll();
    setState(() {
      _savedMessages = transactions;
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
    return Scaffold(
      appBar: AppBar(title: const Text('FinPath Engine Test')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signInAnonymously,
            child: const Text('Generate User ID'),
          ),
          Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          const Text("Intercepted SMS (From Isar DB):", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          // Display the database items
          Expanded(
            child: ListView.builder(
              itemCount: _savedMessages.length,
              itemBuilder: (context, index) {
                final tx = _savedMessages[index];
                return ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: Text(tx.title),
                  subtitle: Text(tx.smsRawText ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}