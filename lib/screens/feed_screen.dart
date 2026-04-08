import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Added import

// --- DATA MODELS (Ready for Backend Integration) ---

class QuizModel {
  final String question;
  final List<String> options;
  final int points;

  QuizModel({required this.question, required this.options, required this.points});
}

class OpportunityModel {
  final String title;
  final String company;
  final String salaryOrBadge;
  final String type; // e.g., "Intern", "Remote"
  final IconData icon;

  OpportunityModel({
    required this.title,
    required this.company,
    required this.salaryOrBadge,
    required this.type,
    required this.icon,
  });
}

class ScholarshipModel {
  final String title;
  final String coverage;
  final String awardOrDeadline;
  final Color deadlineColor;

  ScholarshipModel({
    required this.title,
    required this.coverage,
    required this.awardOrDeadline,
    this.deadlineColor = Colors.grey,
  });
}

class TipModel {
  final String title;
  final String readTime;

  TipModel({required this.title, required this.readTime});
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // --- STATE VARIABLES (Swap these with Firebase Streams tomorrow) ---

  final QuizModel _dailyQuiz = QuizModel(
    question: "What happens to your money if the inflation rate is higher than your savings account interest rate?",
    options: ["Purchasing power increases", "Purchasing power decreases"],
    points: 50,
  );

  final List<OpportunityModel> _opportunities = [
    OpportunityModel(
      title: "Software Development Intern",
      company: "TechNova Solutions",
      salaryOrBadge: "₹25,000/mo",
      type: "Intern",
      icon: Icons.work_outline,
    ),
    OpportunityModel(
      title: "Data Analyst Intern",
      company: "FinServe",
      salaryOrBadge: "Remote",
      type: "Remote",
      icon: Icons.work_outline,
    ),
  ];

  final List<ScholarshipModel> _scholarships = [
    ScholarshipModel(
      title: "National Tech Scholarship",
      coverage: "Covers 50% Tuition",
      awardOrDeadline: "Closes in 5 Days",
      deadlineColor: Colors.red,
    ),
    ScholarshipModel(
      title: "Women in STEM Grant",
      coverage: "₹50,000 Award",
      awardOrDeadline: "₹50,000 Award",
      deadlineColor: Colors.orange,
    ),
  ];

  final List<TipModel> _tips = [
    TipModel(title: "The 50/30/20 Rule Explained simply.", readTime: "3 min read"),
    TipModel(title: "How to build an emergency corpus on a student budget.", readTime: "5 min read"),
  ];

  int? _selectedQuizOption;

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentTeal = Color(0xFF83C5BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context), // Passed context
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuizCard(),
                    _buildSectionHeader("Opportunities for You", true),
                    _buildOpportunitiesList(),
                    _buildSectionHeader("Active Scholarships", false),
                    _buildScholarshipsList(),
                    _buildSectionHeader("Quick Financial Tips", false),
                    _buildTipsList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  backgroundColor: _accentTeal,
                  child: Text('JD', style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily FinQuiz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryTeal)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(15)),
                child: Text("+${_dailyQuiz.points} Pts", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(_dailyQuiz.question, style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87)),
          const SizedBox(height: 20),
          ...List.generate(_dailyQuiz.options.length, (index) {
            bool isSelected = _selectedQuizOption == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedQuizOption = index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryTeal.withOpacity(0.05) : _backgroundGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? _primaryTeal : Colors.transparent),
                  ),
                  child: Center(
                    child: Text(
                      _dailyQuiz.options[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? _primaryTeal : Colors.black54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showViewAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (showViewAll)
            const Text("View All", style: TextStyle(color: _primaryTeal, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final opp = _opportunities[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _backgroundGray,
                  radius: 18,
                  child: Icon(opp.icon, color: _primaryTeal, size: 20),
                ),
                const SizedBox(height: 12),
                Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(opp.company, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(10)),
                      child: Text(opp.salaryOrBadge, style: const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Apply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScholarshipsList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _scholarships.length,
        itemBuilder: (context, index) {
          final sch = _scholarships[index];
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFF8E1),
                  radius: 18,
                  child: Icon(Icons.school_outlined, color: Color(0xFFF9C74F), size: 20),
                ),
                const SizedBox(height: 12),
                Text(sch.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Text(sch.coverage, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: sch.deadlineColor),
                    const SizedBox(width: 4),
                    Text(sch.awardOrDeadline, style: TextStyle(color: sch.deadlineColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFFDE7),
                child: Icon(Icons.lightbulb_outline, color: Color(0xFFFBC02D)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(tip.readTime, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
