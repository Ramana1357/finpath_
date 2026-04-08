import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Added import

// --- DATA MODEL (Ready for Backend Integration) ---
class DreamVaultModel {
  final String title;
  final IconData icon;
  final double currentAmount;
  final double targetAmount;

  DreamVaultModel({
    required this.title,
    required this.icon,
    required this.currentAmount,
    required this.targetAmount,
  });

  double get percentage => (currentAmount / targetAmount);
}

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  // --- STATE VARIABLES (Swap these with Database Streams tomorrow) ---
  final double _totalLockedSavings = 18500.00;
  final int _userLevel = 5;
  final String _userLevelName = "FinMaster";
  final double _levelProgress = 0.8; // 80%
  bool _isCrisisModeActive = false;

  final List<DreamVaultModel> _vaults = [
    DreamVaultModel(
      title: "Buy Bike",
      icon: Icons.directions_bike,
      currentAmount: 45000,
      targetAmount: 90000,
    ),
    DreamVaultModel(
      title: "Goa Trip",
      icon: Icons.flight_takeoff,
      currentAmount: 10000,
      targetAmount: 50000,
    ),
  ];

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentYellow = Color(0xFFF9C74F);
  static const Color _progressGreen = Color(0xFF43AA8B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      // Removed bottomNavigationBar as requested; handled by Main Hub
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context), // Passed context
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalSavingsCard(),
                    const SizedBox(height: 20),
                    _buildGamificationCard(),
                    const SizedBox(height: 25),
                    const Text(
                      "My Dream Vaults",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildVaultList(),
                    const SizedBox(height: 20),
                    _buildCrisisModeCard(),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildAppBar(BuildContext context) { // Accepts context
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _primaryTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FINPATH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              GestureDetector( // Added GestureDetector
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF83C5BE),
                  child: Text('JD',
                      style: TextStyle(
                          color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF023E3E), // Darker teal as per image
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Locked Savings",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            "₹${_totalLockedSavings.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard() {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _accentYellow, width: 8)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined,
                          color: _accentYellow),
                      const SizedBox(width: 10),
                      Text(
                        "Level $_userLevel: $_userLevelName",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    "${(_levelProgress * 100).toInt()}% to Level ${_userLevel + 1}",
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: _levelProgress,
                backgroundColor: _backgroundGray,
                color: _accentYellow,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _vaults.length,
      itemBuilder: (context, index) {
        final vault = _vaults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _backgroundGray,
                    child: Icon(vault.icon, color: _primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vault.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "₹${vault.currentAmount.toInt()} / ₹${vault.targetAmount.toInt()}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${(vault.percentage * 100).toInt()}%",
                    style: const TextStyle(
                      color: _progressGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: vault.percentage,
                backgroundColor: _backgroundGray,
                color: _progressGreen,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCrisisModeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _backgroundGray,
            child: Icon(
              Icons.shield_outlined,
              color: _isCrisisModeActive ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Crisis Mode Setup",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _primaryTeal),
                ),
                Text(
                  _isCrisisModeActive
                      ? "Crisis Mode ACTIVE"
                      : "Currently Safe (Inactive)",
                  style: TextStyle(
                    color: _isCrisisModeActive ? Colors.red : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCrisisModeActive,
            onChanged: (val) {
              setState(() {
                _isCrisisModeActive = val;
              });
            },
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
