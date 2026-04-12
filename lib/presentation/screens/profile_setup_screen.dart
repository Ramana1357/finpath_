import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _financialController = TextEditingController();
  final _qualificationController = TextEditingController();
  String _gender = 'Other';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              TextFormField(
                controller: _financialController,
                decoration: const InputDecoration(labelText: 'Financial Details'),
              ),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              const SizedBox(height: 20),
              if (authProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final profile = ProfileModel(
                        uid: authProvider.user!.uid,
                        name: _nameController.text,
                        age: int.parse(_ageController.text),
                        email: authProvider.user!.email,
                        phoneNo: _phoneController.text,
                        gender: _gender,
                        financialDetails: _financialController.text,
                        qualification: _qualificationController.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await authProvider.saveProfile(profile);
                    }
                  },
                  child: const Text('Save Profile'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
