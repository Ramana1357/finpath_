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
            const Icon(Icons.fingerprint, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              'Unlock Finpath',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Use biometric authentication to access your data'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => authProvider.authenticateWithBiometrics(),
              child: const Text('Authenticate'),
            ),
            TextButton(
              onPressed: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Log Out"),
                    content: const Text(
                      "the data regarding to dream vault and savings will be deleted permanently and the money will be allocated to total balance. "
                      "choose backup and logout incase of short term logout.else you can either choose to just logout or backup and logout",
                    ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
