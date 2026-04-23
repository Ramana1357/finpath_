import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../../data/models/profile_model.dart';

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
  final _professionController = TextEditingController();
  final _qualificationController = TextEditingController();
  
  String _selectedGender = 'Male';

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    const primaryTeal = Color(0xFF006D77);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF6F9),
      appBar: AppBar(
        title: const Text('Complete Your Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "We need a few more details to personalize your financial journey.",
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              const SizedBox(height: 25),
              
              _buildTextField(
                controller: _nameController, 
                label: 'Full Name', 
                icon: Icons.person_outline,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Name is required';
                  if (value.length > 20) return 'Name must be 20 characters or less';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController, 
                      label: 'Age', 
                      icon: Icons.calendar_today_outlined, 
                      isNumber: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final age = int.tryParse(value);
                        if (age == null) return 'Invalid number';
                        if (age < 16) return 'Must be 16+';
                        if (age > 120) return 'Invalid age';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          items: _genders.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _phoneController, 
                label: 'Mobile Number', 
                icon: Icons.phone_android_outlined, 
                isNumber: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (value.length != 10) return 'Enter a valid 10-digit number';
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _professionController, 
                label: 'Profession / Financial Status', 
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _qualificationController, 
                label: 'Qualification', 
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final user = authProvider.user;
                    if (user != null) {
                      final profile = ProfileModel(
                        uid: user.uid,
                        name: _nameController.text,
                        age: int.tryParse(_ageController.text) ?? 18,
                        phoneNo: _phoneController.text,
                        gender: _selectedGender,
                        financialDetails: _professionController.text,
                        qualification: _qualificationController.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await authProvider.saveProfile(profile);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    {required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF006D77), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(height: 0.8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
