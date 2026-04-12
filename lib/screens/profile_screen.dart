import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  final int totalPoints;
  const ProfileScreen({super.key, this.totalPoints = 1580});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSmsListenerActive = true;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);

  @override
  void initState() {
    super.initState();
    // Update streak when profile is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CloudService().updateStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final cloudService = CloudService();

    final String name = profile?.name ?? "New User";
    final String bio = profile?.qualification ?? "Financial Explorer";

    return Scaffold(
      backgroundColor: _backgroundGray,
      appBar: AppBar(
        backgroundColor: _primaryTeal,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't show back button in tab
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cloudService.getUserProfileStream(),
        builder: (context, snapshot) {
          int streak = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            streak = data['streak'] ?? 0;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeader(name, bio),
                const SizedBox(height: 30),
                _buildGamificationCard(streak),
                const SizedBox(height: 30),
                _buildSettingsList(name, bio),
                const SizedBox(height: 40),
                _buildLogoutButton(authProvider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name, String bio) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: _primaryTeal,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primaryTeal,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  onPressed: () {}, // Handle edit profile
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        Text(
          bio,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildGamificationCard(int streak) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "$streak Day Streak",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  "${widget.totalPoints} Pts",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(String name, String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsItem(
            Icons.person_outline,
            "Personal Information",
            onTap: () => _showPersonalInformationDialog(context),
          ),
          _buildSettingsItem(Icons.shield_outlined, "My Dream Vaults"),
          _buildSettingsItem(Icons.file_download_outlined, "Export Data"),
          const SizedBox(height: 20),
          _buildSettingsItem(
            Icons.chat_bubble_outline, 
            "SMS Listener", 
            badge: _isSmsListenerActive ? "Active" : "Inactive",
            onTap: () {
              setState(() {
                _isSmsListenerActive = !_isSmsListenerActive;
              });
            }
          ),
          _buildSettingsItem(Icons.tune_outlined, "Budget Rules"),
          const SizedBox(height: 20),
          _buildSettingsItem(Icons.fingerprint, "Biometric Lock"),
          _buildSettingsItem(Icons.lock_outline, "Change Password"),
        ],
      ),
    );
  }

  void _showPersonalInformationDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Personal Information"),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                Navigator.pop(context);
                _showEditPersonalInformationDialog(context);
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoText("Name", profile?.name ?? "N/A"),
            _buildInfoText("Age", profile?.age.toString() ?? "N/A"),
            _buildInfoText("Gender", profile?.gender ?? "N/A"),
            _buildInfoText("Qualification", profile?.qualification ?? "N/A"),
            _buildInfoText("Financial Details", profile?.financialDetails ?? "N/A"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showEditPersonalInformationDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    final nameController = TextEditingController(text: profile?.name);
    final ageController = TextEditingController(text: profile?.age.toString());
    final qualificationController = TextEditingController(text: profile?.qualification);
    final financialController = TextEditingController(text: profile?.financialDetails);
    String? selectedGender = profile?.gender;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Information"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setDialogState(() => selectedGender = val),
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                TextField(controller: qualificationController, decoration: const InputDecoration(labelText: "Qualification")),
                TextField(controller: financialController, decoration: const InputDecoration(labelText: "Financial Details")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final updatedProfile = ProfileModel(
                  uid: authProvider.user!.uid,
                  name: nameController.text,
                  email: authProvider.user!.email,
                  age: int.tryParse(ageController.text) ?? (profile?.age ?? 0),
                  gender: selectedGender ?? (profile?.gender ?? "Other"),
                  qualification: qualificationController.text,
                  financialDetails: financialController.text,
                  createdAt: profile?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await authProvider.saveProfile(updatedProfile);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? badge, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _primaryTeal),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Log Out"),
                content: const Text("Are you sure you want to log out?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await authProvider.logout();
              if (context.mounted) {
                // This clears any remaining screens and ensures we are at the root
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
