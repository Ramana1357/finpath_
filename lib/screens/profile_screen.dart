import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloud_service.dart';

class ProfileScreen extends StatefulWidget {
  final int totalPoints;
  const ProfileScreen({super.key, this.totalPoints = 1580});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CloudService _cloudService = CloudService();
  String _userName = "Loading...";
  String _userSubtitle = "...";
  final int _currentStreak = 14;
  bool _isSmsListenerActive = true;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _cloudService.getUserProfileStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _userName = data['displayName'] ?? "New User";
          _userSubtitle = data['bio'] ?? "Financial Explorer";
        }

        return Scaffold(
          backgroundColor: _backgroundGray,
          appBar: AppBar(
            backgroundColor: _primaryTeal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              "My Profile",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildGamificationCard(),
                const SizedBox(height: 30),
                _buildSettingsList(),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _primaryTeal,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  onPressed: _showEditProfileDialog,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        Text(
          _userSubtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: _userName);
    TextEditingController bioController = TextEditingController(text: _userSubtitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Bio"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _cloudService.updateUserProfile(nameController.text, bioController.text);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryTeal, foregroundColor: Colors.white),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard() {
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
                  "$_currentStreak Day Streak",
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
                  "${widget.totalPoints} Lifetime Pts",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsItem(Icons.person_outline, "Personal Information", onTap: _showEditProfileDialog),
          _buildSettingsItem(Icons.shield_outlined, "My Dream Vaults"),
          _buildSettingsItem(Icons.file_download_outlined, "Export Financial Data"),
          const SizedBox(height: 20),
          _buildSettingsItem(
            Icons.chat_bubble_outline, 
            "SMS Listener Settings", 
            badge: _isSmsListenerActive ? "Active" : "Inactive",
            onTap: () {
              setState(() {
                _isSmsListenerActive = !_isSmsListenerActive;
              });
            }
          ),
          _buildSettingsItem(Icons.tune_outlined, "Smart Budget Rules"),
          const SizedBox(height: 20),
          _buildSettingsItem(Icons.fingerprint, "Biometric Lock"),
          _buildSettingsItem(Icons.lock_outline, "Change Password"),
        ],
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

  Widget _buildLogoutButton() {
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
                content: const Text("Are you sure you want to log out? This will end your current session."),
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
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Return to dashboard and maybe show a snackbar or trigger a refresh
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );
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
