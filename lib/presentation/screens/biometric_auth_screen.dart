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
              onPressed: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Log Out"),
                    content: const Text("Would you like to save your last 6 months of data to the cloud?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 0), // Cancel
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 1), // Logout No Backup
                        child: const Text("Just Logout", style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, 2), // Logout With Backup
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006D77)),
                        child: const Text("Backup & Logout", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (result != null && result > 0) {
                  final bool shouldBackup = (result == 2);
                  await authProvider.logout(shouldBackup: shouldBackup);
                }
              },
              child: const Text('Log out and use different account'),
            ),
          ],
        ),
      ),
    );
  }
}
