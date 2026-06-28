import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'creator_profile_view.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeCategory = 'Overall';

  final List<String> _categories = [
    'Overall', 'Midjourney', 'ChatGPT', 'Claude', 'Flux', 'AI Video', 'Coding'
  ];

  final List<Map<String, dynamic>> _topThree = [
    {
      'username': 'usman',
      'displayName': 'Usman Al-Farsi',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
      'rank': 1,
      'score': '99.8',
      'followers': '3.4K',
      'isVerified': true
    },
    {
      'username': 'NeonKitten',
      'displayName': 'Sarah Jennings',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
      'rank': 2,
      'score': '98.5',
      'followers': '1.2K',
      'isVerified': true
    },
    {
      'username': 'RetroRider',
      'displayName': 'Derrick Vance',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
      'rank': 3,
      'score': '96.2',
      'followers': '820',
      'isVerified': false
    }
  ];

  final List<Map<String, dynamic>> _leaderboardList = [
    {
      'rank': 4,
      'username': 'CyberBard',
      'displayName': 'Evelyn Gray',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=CyberBard',
      'score': '95.4',
      'followers': '1.5K',
      'isVerified': true,
      'growth': '+4.2%',
      'tier': 'Elite'
    },
    {
      'rank': 5,
      'username': 'PixelPioneer',
      'displayName': 'Marcus Cole',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=PixelPioneer',
      'score': '94.8',
      'followers': '980',
      'isVerified': false,
      'growth': '+2.5%',
      'tier': 'Elite'
    },
    {
      'rank': 6,
      'username': 'AI_Architect',
      'displayName': 'Liam Sterling',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=AI_Architect',
      'score': '93.2',
      'followers': '2.1K',
      'isVerified': true,
      'growth': '-1.1%',
      'tier': 'Creator'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              // ─── 1. TOP 3 PODIUM ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildPodium(),
                ),
              ),

              // ─── 2. CATEGORY CHIP FILTERS ───
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSel = _activeCategory == cat;
                      return AnzorChip(
                        label: cat,
                        isSelected: isSel,
                        onTap: () {
                          setState(() => _activeCategory = cat);
                          HapticFeedback.selectionClick();
                        },
                      );
                    },
                  ),
                ),
              ),

              // ─── 3. LEADERBOARD LIST ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _leaderboardList[index];
                      return _buildLeaderboardCard(item);
                    },
                    childCount: _leaderboardList.length,
                  ),
                ),
              ),
            ],
          ),

          // Glass Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildFrostedHeader(topPad),
          ),

          // Sticky current rank card at bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildStickyYourRankCard(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Frosted Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFrostedHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 8),
          color: const Color(0xD206050C),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator Leaderboard',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                        ),
                      ),
                      Text(
                        'Compete with the world\'s best AI creators.',
                        style: GoogleFonts.inter(
                          fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Ranking Filters Segmented Controls
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.brandOrange,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.white30,
                labelColor: AppTheme.brandOrange,
                onTap: (index) {
                  HapticFeedback.selectionClick();
                },
                tabs: const [
                  Tab(text: 'Global Reach'),
                  Tab(text: 'Weekly Growth'),
                  Tab(text: 'All Time'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top 3 Podium
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPodium() {
    // 2nd Place (Left), 1st Place (Center), 3rd Place (Right)
    final gold = _topThree.firstWhere((c) => c['rank'] == 1);
    final silver = _topThree.firstWhere((c) => c['rank'] == 2);
    final bronze = _topThree.firstWhere((c) => c['rank'] == 3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumColumn(silver, '🥈 Silver', 80, AppTheme.brandOrange.withValues(alpha: 0.15)),
        _podiumColumn(gold, '🥇 Gold', 110, AppTheme.brandGold.withValues(alpha: 0.25)),
        _podiumColumn(bronze, '🥉 Bronze', 65, Colors.brown.withValues(alpha: 0.25)),
      ],
    );
  }

  Widget _podiumColumn(Map<String, dynamic> creator, String title, double height, Color accentGlow) {
    return Column(
      children: [
        CircleAvatar(
          radius: title.contains('Gold') ? 26 : 22,
          backgroundImage: NetworkImage(creator['avatar']!),
        ),
        const SizedBox(height: 6),
        Text(
          creator['username'],
          style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'Score: ${creator['score']}',
          style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF131024),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: accentGlow),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title.split(' ').last,
                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                'Rank ${creator['rank']}',
                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.brandOrange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Leaderboard Row Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLeaderboardCard(Map<String, dynamic> item) {
    final growthPositive = item['growth'].toString().startsWith('+');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatorProfileView(username: item['username']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnzorCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                '#${item['rank']}',
                style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white30),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(item['avatar']!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['displayName'],
                          style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (item['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, color: AppTheme.brandOrange, size: 11),
                        ],
                      ],
                    ),
                    Text(
                      '@${item['username']} • ${item['tier']}',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Score: ${item['score']}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  Text(
                    item['growth'],
                    style: GoogleFonts.inter(fontSize: 9.5, color: growthPositive ? const Color(0xFF00FF7F) : Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sticky Bottom Your Rank Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStickyYourRankCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.15)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandOrange.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.military_tech_rounded, color: AppTheme.brandOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Global Rank: #456',
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Score: 78.4  •  Earn 250 XP to reach Top 100!',
                  style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white54),
                ),
              ],
            ),
          ),
          AnzorButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insight details opened.')),
              );
            },
            radius: 8, height: 32,
            gradient: AppTheme.brandGradient,
            glowColor: AppTheme.brandOrange,
            child: Text('View Details', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
