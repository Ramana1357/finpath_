import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/profile_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  double _emergencyPercent = 10.0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 20),
            Text('Emergency Fund: ${_emergencyPercent.toInt()}% of income'),
            Slider(
              value: _emergencyPercent,
              min: 0,
              max: 50,
              divisions: 10,
              label: '${_emergencyPercent.toInt()}%',
              onChanged: (value) => setState(() => _emergencyPercent = value),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final user = authProvider.user;
                if (user != null) {
                  final profile = ProfileModel(
                    uid: user.uid,
                    name: _nameController.text,
                    age: 18, // Default value
                    gender: 'Other', // Default value
                    financialDetails: 'Student', // Default value
                    qualification: 'Undergraduate', // Default value
                    emergencyPercent: _emergencyPercent.toInt(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await authProvider.saveProfile(profile);
                }
              },
              child: const Text('Complete Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
