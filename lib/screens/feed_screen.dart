import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../presentation/providers/auth_provider.dart';
import 'profile_screen.dart';
import 'cloud_feed_screen.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../services/finance_feed_service.dart';
import '../models/transaction.dart';
import '../models/cloud_insight.dart';
import '../models/finance_tip_model.dart';
import '../widgets/daily_quiz_card.dart';

// --- DATA MODELS ---

class OpportunityModel {
  final String title;
  final String company;
  final String salaryOrBadge;
  final String type;
  final IconData icon;
  final String url;

  OpportunityModel({
    required this.title,
    required this.company,
    required this.salaryOrBadge,
    required this.type,
    required this.icon,
    required this.url,
  });
}

class ScholarshipModel {
  final String title;
  final String coverage;
  final String awardOrDeadline;
  final Color deadlineColor;
  final String url;

  ScholarshipModel({
    required this.title,
    required this.coverage,
    required this.awardOrDeadline,
    required this.url,
    this.deadlineColor = Colors.grey,
  });
}

class FeedScreen extends StatefulWidget {
  final int currentPoints;
  final Function(int) onPointsAwarded;

  const FeedScreen({
    super.key,
    required this.currentPoints,
    required this.onPointsAwarded,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {
  late final Stream<List<ExpenseTransaction>> _transactionStream;
  final LocalCacheService _cacheService = LocalCacheService();
  final FinanceFeedService _feedService = FinanceFeedService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    await _cacheService.init();
    setState(() {
      _transactionStream = _cacheService.watchTransactions();
    });
    
    _transactionStream.listen((transactions) {
      if (transactions.isNotEmpty) {
        CloudService().runAutoAnalysisFromLocal(transactions);
      }
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while trying to open the link.')),
        );
      }
    }
  }

  // --- UI COLORS ---
  static const Color _primaryTeal = Color(0xFF006D77);
  static const Color _backgroundGray = Color(0xFFEDF6F9);
  static const Color _accentTeal = Color(0xFF83C5BE);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: _backgroundGray,
      body: SafeArea(
        child: CustomScrollView(
          cacheExtent: 1000,
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar(context)),
            SliverToBoxAdapter(child: _buildAiCoachSection()),
            const SliverToBoxAdapter(child: DailyQuizCard()),
            SliverToBoxAdapter(child: _buildSectionHeader("Opportunities for You", false)),
            SliverToBoxAdapter(child: _buildOpportunitiesList()),
            SliverToBoxAdapter(child: _buildSectionHeader("Active Scholarships", false)),
            SliverToBoxAdapter(child: _buildScholarshipsList()),
            SliverToBoxAdapter(child: _buildSectionHeader("Financial Insights & Tips", false)),
            _buildDynamicSliverTipsList(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC TIPS SECTION ---

  Widget _buildDynamicSliverTipsList() {
    return StreamBuilder<List<FinanceTipModel>>(
      stream: _feedService.getLatestTips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildTipShimmer());
        }
        
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Could not load latest tips. Check your connection."),
            ),
          );
        }

        final tips = snapshot.data ?? [];
        if (tips.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Stay tuned! New financial tips are arriving soon."),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildTipCard(tips[index]);
              },
              childCount: tips.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipCard(FinanceTipModel tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: tip.imageUrl,
                memCacheWidth: 600, 
                maxWidthDiskCache: 1000,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: _accentTeal.withOpacity(0.2),
                  child: const Icon(Icons.image_not_supported, color: _primaryTeal),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tip.type.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _primaryTeal,
                        ),
                      ),
                    ),
                    Text(
                      tip.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      _getTimeAgo(tip.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showFullTip(tip),
                      child: const Text("Read More", style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return "${difference.inDays}d ago";
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m ago";
    return "just now";
  }

  void _showFullTip(FinanceTipModel tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Source: ${tip.source}", style: const TextStyle(color: _primaryTeal, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: tip.imageUrl,
                        memCacheWidth: 800,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      tip.content,
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(2, (index) => Container(
            height: 300,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
          )),
        ),
      ),
    );
  }

  // --- APP BAR ---

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final String initials = profile?.name != null && profile!.name.isNotEmpty 
        ? profile.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'JD';

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
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
                child: CircleAvatar(
                  backgroundColor: _accentTeal,
                  child: Text(initials, style: const TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showSeeAll, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryTeal)),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All', style: TextStyle(color: _accentTeal, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // --- OPPORTUNITIES SECTION ---

  Widget _buildOpportunitiesList() {
    final List<OpportunityModel> _opportunities = [
      OpportunityModel(
        title: "Software Development Intern", 
        company: "TechNova Solutions", 
        salaryOrBadge: "₹25,000/mo", 
        type: "Intern", 
        icon: Icons.work_outline,
        url: "https://unstop.com/",
      ),
      OpportunityModel(
        title: "Data Analyst Intern", 
        company: "FinServe", 
        salaryOrBadge: "Remote", 
        type: "Remote", 
        icon: Icons.work_outline,
        url: "https://unstop.com/",
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final opp = _opportunities[index];
          return GestureDetector(
            onTap: () => _launchURL(opp.url),
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: _backgroundGray, child: Icon(opp.icon, color: _primaryTeal, size: 20)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(opp.company, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- SCHOLARSHIPS SECTION ---

  Widget _buildScholarshipsList() {
    final List<ScholarshipModel> _scholarships = [
      ScholarshipModel(
        title: "National Tech Scholarship", 
        coverage: "Covers 50% Tuition", 
        awardOrDeadline: "Closes in 5 Days", 
        deadlineColor: Colors.red,
        url: "https://scholarships.gov.in/",
      ),
      ScholarshipModel(
        title: "Women in STEM Grant", 
        coverage: "₹50,000 Award", 
        awardOrDeadline: "₹50,000 Award", 
        deadlineColor: Colors.orange,
        url: "https://scholarships.gov.in/",
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _scholarships.length,
        itemBuilder: (context, index) {
          final sch = _scholarships[index];
          return GestureDetector(
            onTap: () => _launchURL(sch.url),
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sch.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(sch.coverage, style: TextStyle(color: sch.deadlineColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiCoachSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primaryTeal, _accentTeal]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Your AI Coach is analyzing your last 3 days of spending...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
