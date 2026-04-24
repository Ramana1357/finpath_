import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../presentation/providers/auth_provider.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import '../services/cloud_service.dart';
import '../services/local_cache_service.dart';
import '../services/finance_feed_service.dart';
import '../models/transaction.dart';
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
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          cacheExtent: 1000,
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar(context)),
            const SliverToBoxAdapter(child: DailyQuizCard()),
            const SliverToBoxAdapter(child: EducationalLinksWidget()),
            /*SliverToBoxAdapter(child: _buildSectionHeader(context, "Opportunities for You", false)),
            SliverToBoxAdapter(child: _buildOpportunitiesList(context)),
            SliverToBoxAdapter(child: _buildSectionHeader(context, "Active Scholarships", false)),
            SliverToBoxAdapter(child: _buildScholarshipsList(context)),*/
            SliverToBoxAdapter(child: _buildSectionHeader(context, "Financial Insights & Tips", false)),
            _buildDynamicSliverTipsList(context),
            const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC TIPS SECTION ---

  Widget _buildDynamicSliverTipsList(BuildContext context) {
    return StreamBuilder<List<FinanceTipModel>>(
      stream: _feedService.getLatestTips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildTipShimmer(context));
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
                return _buildTipCard(context, tips[index]);
              },
              childCount: tips.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipCard(BuildContext context, FinanceTipModel tip) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                placeholder: (context, url) => Container(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.secondary.withValues(alpha: 0.2),
                  child: Icon(Icons.image_not_supported, color: colorScheme.primary),
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
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tip.type.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      tip.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 5),
                    Text(
                      _getTimeAgo(tip.timestamp),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showFullTip(context, tip),
                      child: Text("Read More", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
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

  void _showFullTip(BuildContext context, FinanceTipModel tip) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Source: ${tip.source}", style: TextStyle(color: colorScheme.primary, fontStyle: FontStyle.italic)),
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
                      style: TextStyle(fontSize: 16, height: 1.6, color: colorScheme.onSurface.withValues(alpha: 0.9)),
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

  Widget _buildTipShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Column(
          children: List.generate(2, (index) => Container(
            height: 300,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(25)),
          )),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // --- APP BAR ---

  Widget _buildAppBar(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;

    // SAFE ACCESS: Check if name exists before split/indexing
    String initials = 'JD';
    if (profile?.name != null && profile!.name.trim().isNotEmpty) {
      try {
        initials = profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').where((s) => s.isNotEmpty).take(2).join().toUpperCase();
        if (initials.isEmpty) initials = 'JD';
      } catch (e) {
        initials = 'JD';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FINPATH',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: colorScheme.onPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
                child: CircleAvatar(
                  backgroundColor: colorScheme.secondary,
                  child: Text(initials, style: TextStyle(color: colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool showSeeAll, {VoidCallback? onSeeAll}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAll,
              child: Text('See All', style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // --- OPPORTUNITIES SECTION ---



  // --- SCHOLARSHIPS SECTION ---


}

class EducationalLinksWidget extends StatelessWidget {
  const EducationalLinksWidget({super.key});

  Future<void> _handleURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the link.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: _buildLinkCard(
              context,
              title: "Job & Internships",
              icon: Icons.work_outline,
              color: colorScheme.primary,
              onTap: () => _handleURL(context, "https://unstop.com/"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildLinkCard(
              context,
              title: "Scholarships",
              icon: Icons.school_outlined,
              color: colorScheme.secondary,
              onTap: () => _handleURL(context, "https://www.buddy4study.com/"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 25,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
