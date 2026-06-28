import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});
  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _badgeGlowController;
  String _activeCategory = 'All';

  final List<String> _categories = [
    'All', 'Unlocked', 'Locked', 'Prompt Creator', 'Community',
    'Leaderboard', 'Collections', 'Challenges', 'Elite', 'Legendary',
  ];

  final List<Map<String, dynamic>> _badges = [
    {
      'icon': Icons.auto_awesome_rounded,
      'name': 'Prompt Pioneer',
      'desc': 'Create your first AI prompt',
      'rarity': 'Bronze',
      'xp': 50,
      'progress': 1.0,
      'unlocked': true,
      'date': 'Jun 14, 2026',
      'color': const Color(0xFFCD7F32),
    },
    {
      'icon': Icons.local_fire_department_rounded,
      'name': 'On Fire',
      'desc': 'Publish 10 prompts in a week',
      'rarity': 'Silver',
      'xp': 150,
      'progress': 0.7,
      'unlocked': false,
      'date': null,
      'color': const Color(0xFFC0C0C0),
    },
    {
      'icon': Icons.emoji_events_rounded,
      'name': 'Top Creator',
      'desc': 'Reach Top 100 on the global leaderboard',
      'rarity': 'Gold',
      'xp': 500,
      'progress': 0.45,
      'unlocked': false,
      'date': null,
      'color': const Color(0xFFFFD700),
    },
    {
      'icon': Icons.groups_rounded,
      'name': 'Community Star',
      'desc': 'Gain 1,000 followers',
      'rarity': 'Platinum',
      'xp': 800,
      'progress': 0.32,
      'unlocked': false,
      'date': null,
      'color': const Color(0xFFE5E4E2),
    },
    {
      'icon': Icons.diamond_outlined,
      'name': 'Diamond Creator',
      'desc': 'Earn 10,000 total likes',
      'rarity': 'Diamond',
      'xp': 2000,
      'progress': 0.15,
      'unlocked': false,
      'date': null,
      'color': const Color(0xFF00D9FF),
    },
    {
      'icon': Icons.bolt_rounded,
      'name': 'Speed Demon',
      'desc': 'Publish 50 prompts in 30 days',
      'rarity': 'Elite',
      'xp': 1500,
      'progress': 0.06,
      'unlocked': false,
      'date': null,
      'color': const Color(0xFF7C4DFF),
    },
    {
      'icon': Icons.military_tech_rounded,
      'name': 'Legendary Creator',
      'desc': 'Achieve all Elite badges and rank #1',
      'rarity': 'Legendary',
      'xp': 9999,
      'progress': 0.01,
      'unlocked': false,
      'date': null,
      'color': AppTheme.brandOrange,
    },
    {
      'icon': Icons.chat_bubble_rounded,
      'name': 'Conversation Starter',
      'desc': 'Receive 100 comments on your prompts',
      'rarity': 'Bronze',
      'xp': 75,
      'progress': 1.0,
      'unlocked': true,
      'date': 'Jun 20, 2026',
      'color': const Color(0xFFCD7F32),
    },
  ];

  final List<Map<String, dynamic>> _streaks = [
    {'icon': Icons.calendar_today_rounded, 'label': 'Daily Login', 'count': 14, 'unit': 'days', 'color': AppTheme.brandOrange},
    {'icon': Icons.edit_note_rounded, 'label': 'Publishing Streak', 'count': 7, 'unit': 'days', 'color': const Color(0xFF00E5A0)},
    {'icon': Icons.favorite_rounded, 'label': 'Community Participation', 'count': 21, 'unit': 'days', 'color': const Color(0xFF00D9FF)},
  ];

  final List<Map<String, dynamic>> _nextGoals = [
    {'icon': Icons.upload_rounded, 'text': 'Publish 2 more prompts to unlock "Prompt Master"', 'badge': 'Silver', 'color': const Color(0xFFC0C0C0)},
    {'icon': Icons.group_add_rounded, 'text': 'Reach 1,000 followers for "Community Star"', 'badge': 'Platinum', 'color': const Color(0xFFE5E4E2)},
    {'icon': Icons.stars_rounded, 'text': 'Earn 500 XP to reach Elite Creator level', 'badge': 'Elite', 'color': const Color(0xFF7C4DFF)},
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _badgeGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _badgeGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final unlockedCount = _badges.where((b) => b['unlocked'] == true).length;
    final totalXp = _badges.where((b) => b['unlocked'] == true).fold<int>(0, (sum, b) => sum + (b['xp'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient glows
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.09), Colors.transparent]),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _badgeGlowController,
            builder: (_, __) => Positioned(
              bottom: 300, left: -80,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.electricBlue.withValues(alpha: 0.04 + _badgeGlowController.value * 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 90)),

              // ─── PROFILE PROGRESS HERO ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildProfileHeroCard(unlockedCount, totalXp),
                ),
              ),

              // ─── FEATURED ACHIEVEMENT ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildFeaturedAchievement(),
                ),
              ),

              // ─── CATEGORIES ───
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      return AnzorChip(
                        label: cat,
                        isSelected: _activeCategory == cat,
                        onTap: () {
                          setState(() => _activeCategory = cat);
                          HapticFeedback.selectionClick();
                        },
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ─── BADGE GRID ───
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildBadgeCard(_badges[i]),
                    childCount: _badges.length,
                  ),
                ),
              ),

              // ─── STREAKS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text('CREATOR STREAKS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _streaks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _buildStreakCard(_streaks[i]),
                  ),
                ),
              ),

              // ─── NEXT GOALS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 14),
                      const SizedBox(width: 6),
                      Text('AI NEXT GOALS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildNextGoalCard(_nextGoals[i]),
                    ),
                    childCount: _nextGoals.length,
                  ),
                ),
              ),
            ],
          ),

          // Glass Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildHeader(topPad),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD506050C),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achievements', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Track your milestones and unlock legendary badges.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white70, size: 20), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard(int unlockedCount, int totalXp) {
    return AnimatedBuilder(
      animation: _badgeGlowController,
      builder: (_, __) => AnzorCard(
        padding: const EdgeInsets.all(20),
        addGlow: true,
        glowColor: AppTheme.brandOrange,
        backgroundGradientColors: [
          AppTheme.brandOrange.withValues(alpha: 0.1 + _badgeGlowController.value * 0.04),
          AppTheme.brandGold.withValues(alpha: 0.03),
        ],
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.4), Colors.transparent]),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: AppTheme.brandOrange, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Creator Level 8', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.67,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandOrange),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('3,350 / 5,000 XP to Level 9', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _heroStat('$unlockedCount', 'Badges', AppTheme.brandOrange),
                _divider(),
                _heroStat('${totalXp}XP', 'Earned', const Color(0xFFFFD700)),
                _divider(),
                _heroStat('#142', 'Global Rank', const Color(0xFF00D9FF)),
                _divider(),
                _heroStat('${((unlockedCount / _badges.length) * 100).round()}%', 'Complete', const Color(0xFF00E5A0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.07));

  Widget _buildFeaturedAchievement() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.brandOrange.withValues(alpha: 0.15), AppTheme.brandGold.withValues(alpha: 0.08)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: AppTheme.brandOrange.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.4), Colors.transparent]),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.brandOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text('⭐ FEATURED', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1)),
                ),
                const SizedBox(height: 6),
                Text('Prompt Pioneer', style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Create your first AI prompt', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5A0), size: 14),
                    const SizedBox(width: 4),
                    Text('Unlocked Jun 14, 2026', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5A0))),
                    const Spacer(),
                    Text('+50 XP', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.brandGold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final unlocked = badge['unlocked'] as bool;
    final color = badge['color'] as Color;
    final progress = badge['progress'] as double;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showBadgeDetails(badge);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked ? color.withValues(alpha: 0.08) : const Color(0xFF0F0E1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: unlocked ? [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 12, spreadRadius: 1)] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: unlocked ? 0.2 : 0.06),
                  ),
                  child: Icon(badge['icon'] as IconData, color: unlocked ? color : Colors.white24, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge['rarity'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(badge['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: unlocked ? Colors.white : Colors.white38)),
            const SizedBox(height: 4),
            Text(badge['desc'] as String, maxLines: 2, style: GoogleFonts.inter(fontSize: 10, color: Colors.white30, height: 1.4)),
            const Spacer(),
            if (!unlocked) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text('${(progress * 100).round()}% complete', style: GoogleFonts.inter(fontSize: 9, color: color)),
            ] else
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5A0), size: 12),
                  const SizedBox(width: 4),
                  Text('Unlocked!', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5A0))),
                  const Spacer(),
                  Text('+${badge['xp']}XP', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.brandGold)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(Map<String, dynamic> streak) {
    final color = streak['color'] as Color;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(streak['icon'] as IconData, color: color, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${streak['count']} ${streak['unit']}', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
              Text(streak['label'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextGoalCard(Map<String, dynamic> goal) {
    final color = goal['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
            child: Icon(goal['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(goal['text'] as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(goal['badge'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(Map<String, dynamic> badge) {
    final color = badge['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F0E1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
              child: Icon(badge['icon'] as IconData, color: color, size: 36),
            ),
            const SizedBox(height: 14),
            Text(badge['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(badge['desc'] as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _detailStat('Rarity', badge['rarity'] as String, color),
                _detailStat('XP Reward', '+${badge['xp']}', AppTheme.brandGold),
                _detailStat('Progress', '${((badge['progress'] as double) * 100).round()}%', const Color(0xFF00E5A0)),
              ],
            ),
            const SizedBox(height: 20),
            if (badge['unlocked'] == true)
              AnzorButton(
                height: 48,
                onPressed: () { Navigator.pop(context); HapticFeedback.lightImpact(); },
                child: Text('Share Badge', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      ],
    );
  }
}
