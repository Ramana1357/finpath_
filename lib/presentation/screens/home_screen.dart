import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade900, Colors.blue.shade500],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Good morning,',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white24,
                            child: Text(
                              profile.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildInfoCard(context, profile),
                      const SizedBox(height: 20),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildActivityTile('Last Sync', 'Today, 10:30 AM'),
                            _buildActivityTile('Profile Update', 'Recently'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ProfileModel profile) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.email, 'Email', profile.email ?? 'N/A'),
            const Divider(),
            _buildInfoRow(Icons.school, 'Qualification', profile.qualification),
            const Divider(),
            _buildInfoRow(Icons.attach_money, 'Finances', profile.financialDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String time) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(time, style: const TextStyle(color: Colors.white60)),
      ),
    );
  }
}
