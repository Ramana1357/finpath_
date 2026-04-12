import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/biometric_auth_screen.dart';
import 'presentation/screens/profile_setup_screen.dart';
import 'screens/main_hub.dart'; // IMPORT THE NEW HUB
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final cacheService = LocalCacheService();
  await cacheService.init();
  
  // Silent cleanup of transactions older than 6 months
  cacheService.cleanupOldTransactions();

  final userRepository = UserRepository(
    authService: AuthService(),
    firestoreService: FirestoreService(),
    cacheService: cacheService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: cacheService),
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
      debugShowCheckedModeBanner: false, // REMOVED DEBUG BANNER
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
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

    if (!authProvider.isAuthenticated) {
      return const AuthScreen();
    }

    if (!authProvider.isBiometricAuthenticated) {
      return const BiometricAuthScreen();
    }

    if (authProvider.isLoading && !authProvider.hasProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.hasProfile) {
      return const ProfileSetupScreen();
    }

    // Success! Show the Main Hub with all your screens
    return const MainHub();
  }
}
