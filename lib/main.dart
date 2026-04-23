import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/biometric_auth_screen.dart';
import 'presentation/screens/profile_setup_screen.dart';
import 'screens/main_hub.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_cache_service.dart';
import 'utils/sms_parser.dart';
import 'models/transaction.dart';
import 'data/models/profile_model.dart';
import 'data/models/vault_model.dart';

// --- TOP-LEVEL BACKGROUND HANDLER (MANDATORY FOR TELEPHONY) ---
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  final String? body = message.body;
  if (body == null) return;

  try {
    // 1. Use Support Directory for background reliability on physical devices
    final dir = await getApplicationSupportDirectory();
    
    Isar isar;
    if (Isar.getInstance() == null) {
      isar = await Isar.open(
        [ProfileModelSchema, ExpenseTransactionSchema, VaultModelSchema],
        directory: dir.path,
      );
    } else {
      isar = Isar.getInstance()!;
    }

    // 2. Parse using the rebuilt Regex Engine
    final parsed = SmsParser.parse(body);

    // 3. Save if valid
    if (parsed.amount > 0) {
      final newTx = ExpenseTransaction(
        title: parsed.title,
        amount: parsed.amount,
        date: DateTime.now(),
        isExpense: parsed.isExpense,
        category: parsed.category,
        smsRawText: body,
      );

      await isar.writeTxn(() async {
        await isar.expenseTransactions.put(newTx);
      });
    }
  } catch (e) {
    debugPrint("Background SMS Error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // --- REGISTER SMS LISTENER (Physical Device Link) ---
  final Telephony telephony = Telephony.instance;
  bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  if (permissionsGranted != null && permissionsGranted) {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Foreground handling handled in MainHub, but keeping registered here
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  final cacheService = LocalCacheService();
  await cacheService.init();
  
  final userRepository = UserRepository(
    authService: AuthService(),
    firestoreService: FirestoreService(),
    cacheService: cacheService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cacheService),
        ChangeNotifierProvider(create: (_) => AuthProvider(userRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finpath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) return const AuthScreen();
    
    if (authProvider.isLoading && !authProvider.hasProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!authProvider.hasProfile) return const ProfileSetupScreen();

    // Only force biometric screen if enabled in profile AND not yet authenticated in this session
    final bool isBiometricEnabled = authProvider.profile?.biometricEnabled ?? false;
    if (isBiometricEnabled && !authProvider.isBiometricAuthenticated) {
      return const BiometricAuthScreen();
    }

    return const MainHub();
  }
}
