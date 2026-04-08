import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE VARIABLES (Swap these with Database Streams tomorrow) ---
  final String _userName = "Jayant D.";
  final String _userSubtitle = "B.Tech Student • Level 5 FinMaster";
  final int _currentStreak = 14;
  final int _lifetimePoints = 1580;
  final bool _isSmsListenerActive = true;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
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
                  "$_lifetimePoints Lifetime Pts",
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
          _buildSettingsItem(Icons.person_outline, "Personal Information"),
          _buildSettingsItem(Icons.shield_outlined, "My Dream Vaults"),
          _buildSettingsItem(Icons.file_download_outlined, "Export Financial Data"),
          const SizedBox(height: 20),
          _buildSettingsItem(
            Icons.chat_bubble_outline, 
            "SMS Listener Settings", 
            badge: _isSmsListenerActive ? "Active" : null
          ),
          _buildSettingsItem(Icons.tune_outlined, "Smart Budget Rules"),
          const SizedBox(height: 20),
          _buildSettingsItem(Icons.fingerprint, "Biometric Lock"),
          _buildSettingsItem(Icons.lock_outline, "Change Password"),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
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
          onPressed: () {},
          icon: const Icon(Icons.logout),
          label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryTeal,
            side: const BorderSide(color: _primaryTeal, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
