import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/social_post_card.dart';
import 'settings_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedCounter
// Reusable premium counter widget for Creator rankings and statistics.
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedCounter extends StatefulWidget {
  final double value;
  final String prefix;
  final String suffix;
  final bool isInteger;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.isInteger = true,
    this.duration = const Duration(milliseconds: 1400),
    this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = widget.isInteger
            ? _animation.value.toInt().toString()
            : _animation.value.toStringAsFixed(1);
        return Text(
          '${widget.prefix}$val${widget.suffix}',
          style: widget.style ?? GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CreatorProfileView
// The ultimate AI Creator Portfolio view for Anzor.
// ─────────────────────────────────────────────────────────────────────────────
class CreatorProfileView extends StatefulWidget {
  final String username;

  const CreatorProfileView({super.key, required this.username});

  @override
  State<CreatorProfileView> createState() => _CreatorProfileViewState();
}

class _CreatorProfileViewState extends State<CreatorProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAboutExpanded = false;

  final List<String> _expertise = [
    'ChatGPT', 'Gemini', 'Claude', 'Midjourney', 'Flux',
    'Imagen', 'Runway', 'Veo', 'Logo Design', 'Photography', 'Cinematic', 'Anime',
  ];

  final List<(String, String, IconData)> _activities = [
    ('Published Prompt', 'Created a cinematic cyberpunk prompt', Icons.publish_rounded),
    ('Reached Trending', 'Cyberpunk Prompt reached global trends', Icons.trending_up_rounded),
    ('Earned Badge', 'Unlocked 100K Views achievement badge', Icons.star_rounded),
    ('Updated Profile', 'Added new Midjourney specialization details', Icons.edit_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateCreatorScore(int promptsCount, int totalLikes, int followersCount) {
    return (promptsCount * 15) + (totalLikes * 8) + (followersCount * 25) + 120;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creatorIndex = appState.creators.indexWhere((c) => c.username == widget.username);

    if (creatorIndex == -1) {
      return Scaffold(
        backgroundColor: const Color(0xFF06050C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF06050C),
          title: Text('Profile Not Found', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        ),
        body: const Center(child: Text('Creator profile not found.', style: TextStyle(color: Colors.white60))),
      );
    }

    final creator = appState.creators[creatorIndex];
    final currentUser = appState.currentUserProfile;
    final isMe = creator.username == currentUser.username;
    final isFollowing = currentUser.following.contains(creator.username);

    final creatorPrompts = appState.communityPrompts.where((p) => p.author == creator.username).toList();
    final totalLikes = creatorPrompts.fold<int>(0, (sum, p) => sum + p.likes);
    final creatorStats = appState.getCreatorStats(creator.username);

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient visual glows
          Positioned(
            top: 200, right: -120,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -120,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Cover banner
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: creator.coverBanner,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: const Color(0xFF131024)),
                          errorWidget: (_, __, ___) => Container(
                            decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent, Color(0xFF06050C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Avatar & Follow row
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.brandGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.brandOrange.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(creator.avatar),
                              backgroundColor: const Color(0xFF131024),
                            ),
                          ),
                          const Spacer(),

                          if (!isMe)
                            SizedBox(
                              width: 120,
                              height: 38,
                              child: AnzorButton(
                                onPressed: () {
                                  appState.toggleFollow(creator.username);
                                  HapticFeedback.mediumImpact();
                                },
                                radius: 19,
                                gradient: isFollowing
                                    ? const LinearGradient(colors: [Color(0xFF222133), Color(0xFF222133)])
                                    : AppTheme.brandGradient,
                                child: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isFollowing ? Colors.white60 : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Titles & Bio
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                creator.username,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              if (creator.username == 'usman' || creator.username == 'NeonKitten') ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, color: Color(0xFF00D9FF), size: 18),
                              ],
                            ],
                          ),
                          Text(
                            '@${creator.username.toLowerCase()} · AI Prompt Architect',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            creator.bio.isNotEmpty ? creator.bio : 'AI prompts architect crafting detailed custom outputs.',
                            style: GoogleFonts.inter(
                              fontSize: 13.5, height: 1.45,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(width: 6),
                              Text(
                                'Joined ${creator.joinDate}',
                                style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── SIGNATURE WOW FEATURE: Creator Identity & Reputation Dashboard ──
                    _buildReputationDashboard(creator, creatorPrompts.length, totalLikes, creatorStats),
                    const SizedBox(height: 16),

                    // Premium Custom Achievement Badges
                    _buildSectionHeader('Credentials & Badges'),
                    const SizedBox(height: 10),
                    _buildBadgesRow(creatorStats),
                    const SizedBox(height: 24),

                    // Expertise Chips
                    _buildSectionHeader('Expertise'),
                    const SizedBox(height: 10),
                    _buildExpertiseChips(),
                    const SizedBox(height: 24),

                    // Expandable About Section
                    _buildAboutCard(creator),
                    const SizedBox(height: 24),

                    // Social links row
                    _buildSocialLinks(),
                    const SizedBox(height: 24),

                    // Recent Activity timeline
                    _buildSectionHeader('Recent Portfolio Actions'),
                    const SizedBox(height: 12),
                    _buildActivityTimeline(),
                    const SizedBox(height: 32),

                    // Portfolio Tab bar header
                    _buildSectionHeader('Creator Portfolio'),
                    const SizedBox(height: 12),
                    _buildPortfolioTabs(creatorPrompts, appState),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),

          // Pinned Navigation Back Header
          Positioned(
            top: topPad + 10, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularActionBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _circularActionBtn(
                      icon: Icons.ios_share_rounded,
                      onTap: () => _showShareAlert(context),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Creator Identity & Reputation Dashboard
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReputationDashboard(CreatorProfile creator, int creations, int likes, CreatorStats creatorStats) {
    final score = _calculateCreatorScore(creations, likes, creator.followers.length);
    
    // Choose Tier based on score
    String tier = 'Bronze';
    Color tierColor = const Color(0xFFCD7F32);
    if (score > 1200) {
      tier = 'Elite';
      tierColor = const Color(0xFFFF4500);
    } else if (score > 800) {
      tier = 'Platinum';
      tierColor = const Color(0xFFE5E4E2);
    } else if (score > 400) {
      tier = 'Gold';
      tierColor = const Color(0xFFFFD700);
    } else if (score > 200) {
      tier = 'Silver';
      tierColor = const Color(0xFFC0C0C0);
    }

    // Dynamic metrics calculations
    final globalRank = max(1, 1000 - score ~/ 2);
    final countryRank = max(1, globalRank ~/ 8);
    final promptQuality = (85.0 + (score % 150) / 10).clamp(70.0, 99.9);
    final successRate = (95.0 + (score % 50) / 10).clamp(80.0, 100.0);
    final creatorLevel = (creatorStats.xp ~/ 1000) + 1;

    return AnzorCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.brandOrange.withValues(alpha: 0.25),
      addGlow: true,
      glowColor: AppTheme.brandOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.brandOrange.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: AppTheme.brandOrange, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'REPUTATION & IDENTITY DASHBOARD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Dynamic Tier label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tierColor.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text(
                  '$tier Tier'.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid entries
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _rankItem('🏆 Global Rank', globalRank.toDouble(), '#', ' Worldwide', true),
              _rankItem('🌍 Country Rank', countryRank.toDouble(), '#', ' in Pakistan', true),
              _rankItem('⭐ Prompt Quality', promptQuality, '', '% Quality', false),
              _rankItem('🔥 Creator Level', creatorLevel.toDouble(), 'Level ', '', true),
              _rankItem('👑 Reputation', 1.0, 'Top ', '% AI Creator', true),
              _rankItem('📈 Prompt Views', creatorStats.totalViews.toDouble(), '', ' Views', true),
              _rankItem('🎯 AI Expertise', creatorStats.xp.toDouble(), '', ' pts', true),
              _rankItem('✨ Success Rate', successRate, '', '% Success', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rankItem(String label, double value, String prefix, String suffix, bool isInt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5, color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            isInteger: isInt,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Achievement Badges Row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBadgesRow(CreatorStats creatorStats) {
    // Defined Badges from specification
    final List<(String, IconData, Color)> mockBadges = [
      ('Verified Creator', Icons.verified_rounded, const Color(0xFF00D9FF)),
      ('Top Creator', Icons.workspace_premium_rounded, const Color(0xFFFFD700)),
      ('Editor\'s Choice', Icons.offline_bolt_rounded, const Color(0xFF00FF7F)),
      ('Prompt Master', Icons.auto_awesome_rounded, const Color(0xFFFF8A00)),
      ('Community Favorite', Icons.favorite_rounded, const Color(0xFFFF4500)),
      ('AI Expert', Icons.psychology_rounded, const Color(0xFF8A2BE2)),
      ('Elite Creator', Icons.star_rounded, const Color(0xFFFF1493)),
    ];

    if (creatorStats.achievements.isNotEmpty) {
      return SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: creatorStats.achievements.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final ach = creatorStats.achievements[index];
            IconData iconData = Icons.star_rounded;
            Color accentColor = AppTheme.brandOrange;

            // Match icon codes from app_state.dart
            if (ach.icon == 'verified_user') {
              iconData = Icons.verified_rounded;
              accentColor = const Color(0xFF00D9FF);
            } else if (ach.icon == 'wb_incandescent') {
              iconData = Icons.wb_incandescent_rounded;
              accentColor = const Color(0xFFFFD700);
            } else if (ach.icon == 'trending_up') {
              iconData = Icons.trending_up_rounded;
              accentColor = const Color(0xFFFF8A00);
            } else if (ach.icon == 'thumb_up') {
              iconData = Icons.thumb_up_rounded;
              accentColor = const Color(0xFF00FF7F);
            }

            return AnzorCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              radius: 16,
              borderColor: accentColor.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(iconData, color: accentColor, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ach.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ach.description,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
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

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mockBadges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final b = mockBadges[index];
          return AnzorCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            radius: 16,
            borderColor: b.$3.withValues(alpha: 0.15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: b.$3.withValues(alpha: 0.1),
                  ),
                  child: Icon(b.$2, color: b.$3, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  b.$1,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Expertise Horizontal Chips
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildExpertiseChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _expertise.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final exp = _expertise[index];
          final isSel = index < 3; 
          return AnzorChip(
            label: exp,
            isSelected: isSel,
            onTap: () {},
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // About Creator Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAboutCard(CreatorProfile creator) {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'About Creator',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isAboutExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: Colors.white60,
                  size: 18,
                ),
                onPressed: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
              ),
            ],
          ),
          if (_isAboutExpanded) ...[
            const SizedBox(height: 10),
            Text(
              'A seasoned Prompt Architect working in generative models since 2022. Expert in fine-tuning visual styles, descriptive image descriptions, structural layout definitions, and complex chatbot persona constraints.',
              style: GoogleFonts.inter(
                fontSize: 12.5, height: 1.5,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            _aboutField('Specialization', 'Fine Art, LLM Personas, Visual Generation'),
            _aboutField('Primary Tools', 'ChatGPT, Gemini, Midjourney, Flux'),
            _aboutField('Languages', 'English, Urdu, Python'),
          ],
        ],
      ),
    );
  }

  Widget _aboutField(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Social Links Row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSocialLinks() {
    const list = [
      (Icons.language_rounded, 'Website'),
      (Icons.link_rounded, 'GitHub'),
      (Icons.work_outline_rounded, 'LinkedIn'),
      (Icons.share_rounded, 'X'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list.map((item) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        ),
        alignment: Alignment.center,
        child: Icon(item.$1, size: 16, color: Colors.white.withValues(alpha: 0.6)),
      )).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Activity Timeline
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActivityTimeline() {
    return Column(
      children: List.generate(_activities.length, (index) {
        final act = _activities[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandOrange,
                  ),
                ),
                if (index < _activities.length - 1)
                  Container(
                    width: 1.5, height: 32,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act.$1,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  Text(
                    act.$2,
                    style: GoogleFonts.inter(
                      fontSize: 10.5, color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Portfolio Tabs & Grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPortfolioTabs(List<PromptItem> prompts, AppState appState) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandOrange,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Prompts'),
            Tab(text: 'Collections'),
            Tab(text: 'Favorites'),
            Tab(text: 'Activity'),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 380, 
          child: TabBarView(
            controller: _tabController,
            children: [
              prompts.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: prompts.length,
                      itemBuilder: (context, i) => _buildPortfolioCard(prompts[i], appState),
                    ),
              _buildEmptyState(message: 'No collections created yet.'),
              _buildEmptyState(message: 'No favorites marked.'),
              _buildEmptyState(message: 'No logged activity logs.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioCard(PromptItem item, AppState appState) {
    return AnzorCard(
      padding: EdgeInsets.zero,
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: item.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFF131024)),
                    errorWidget: (_, __, ___) => Container(
                      decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.inter(
                        fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          item.likes.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    AnzorActionButton(
                      icon: Icons.copy_rounded,
                      label: '',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: item.prompt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Prompt copied!')),
                        );
                      },
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

  Widget _buildEmptyState({String message = 'No items found.'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 36, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Widgets & Alerts
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _circularActionBtn({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  void _showShareAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share profile link copied!')),
    );
  }

  void _showSettingsAlert(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    );
  }
}
