import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class BiometricAuthScreen extends StatelessWidget {
  const BiometricAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Please authenticate to continue'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final success = await authProvider.authenticateWithBiometrics();
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Authentication failed')),
                  );
                }
              },
              child: const Text('Unlock with Biometrics'),
            ),
            TextButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Log out and use different account'),
            ),
          ],
        ),
      ),
    );
  }
}
