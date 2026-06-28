import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class ActivityHistoryView extends StatefulWidget {
  const ActivityHistoryView({super.key});
  @override
  State<ActivityHistoryView> createState() => _ActivityHistoryViewState();
}

class _ActivityHistoryViewState extends State<ActivityHistoryView>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'All';
  bool _isSearchFocused = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final List<String> _filters = [
    'All', 'Today', 'This Week', 'This Month',
    'Prompts', 'Community', 'Followers', 'Collections', 'Achievements', 'System',
  ];

  final List<Map<String, dynamic>> _summaryStats = [
    {'label': 'Activities', 'value': '284', 'icon': Icons.timeline_rounded, 'color': AppTheme.brandOrange},
    {'label': 'Prompts', 'value': '47', 'icon': Icons.edit_note_rounded, 'color': const Color(0xFF00D9FF)},
    {'label': 'Saved', 'value': '132', 'icon': Icons.bookmark_rounded, 'color': const Color(0xFF00E5A0)},
    {'label': 'Likes', 'value': '891', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFFF4D6A)},
    {'label': 'Comments', 'value': '63', 'icon': Icons.chat_bubble_rounded, 'color': const Color(0xFFFFC107)},
    {'label': 'Followers', 'value': '+28', 'icon': Icons.group_rounded, 'color': const Color(0xFF7C4DFF)},
  ];

  final List<Map<String, dynamic>> _timelineGroups = [
    {
      'group': 'Today',
      'items': [
        {'icon': Icons.auto_awesome_rounded, 'title': 'Published a prompt', 'desc': 'Cyberpunk Street Alley — Midjourney v6', 'time': '2:34 PM', 'type': 'prompt', 'color': AppTheme.brandOrange, 'status': 'Published'},
        {'icon': Icons.favorite_rounded, 'title': 'Received 12 likes', 'desc': 'Volumetric Cinematic Portrait', 'time': '1:15 PM', 'type': 'community', 'color': const Color(0xFFFF4D6A), 'status': null},
        {'icon': Icons.person_add_rounded, 'title': 'New follower', 'desc': 'NeonKitten started following you', 'time': '11:02 AM', 'type': 'follower', 'color': const Color(0xFF7C4DFF), 'status': null},
        {'icon': Icons.military_tech_rounded, 'title': 'Achievement Unlocked', 'desc': 'Conversation Starter — +75 XP', 'time': '9:45 AM', 'type': 'achievement', 'color': const Color(0xFFFFD700), 'status': 'Unlocked'},
      ],
    },
    {
      'group': 'Yesterday',
      'items': [
        {'icon': Icons.collections_bookmark_rounded, 'title': 'Created a collection', 'desc': 'Dark Cinematic Vol. 2', 'time': '6:20 PM', 'type': 'collection', 'color': const Color(0xFF00D9FF), 'status': 'Created'},
        {'icon': Icons.chat_bubble_rounded, 'title': 'Added a comment', 'desc': 'Replied on "Neon Forest Dreams"', 'time': '3:10 PM', 'type': 'community', 'color': const Color(0xFFFFC107), 'status': null},
        {'icon': Icons.bookmark_add_rounded, 'title': 'Saved a prompt', 'desc': 'Galaxy Nebula Composition', 'time': '12:05 PM', 'type': 'prompt', 'color': const Color(0xFF00E5A0), 'status': 'Saved'},
      ],
    },
    {
      'group': 'This Week',
      'items': [
        {'icon': Icons.trending_up_rounded, 'title': 'Rank increased', 'desc': 'Moved from #198 to #142 globally', 'time': 'Mon 4:00 PM', 'type': 'achievement', 'color': AppTheme.brandOrange, 'status': 'Promoted'},
        {'icon': Icons.edit_note_rounded, 'title': 'Updated prompt', 'desc': 'Neon Cyberpunk City — improved description', 'time': 'Mon 1:30 PM', 'type': 'prompt', 'color': const Color(0xFF00D9FF), 'status': 'Updated'},
        {'icon': Icons.manage_accounts_rounded, 'title': 'Profile updated', 'desc': 'Added new social links and expertise tags', 'time': 'Sun 10:00 AM', 'type': 'system', 'color': Colors.white54, 'status': 'Saved'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _aiInsights = [
    {'icon': Icons.star_rounded, 'text': 'Your most productive day was Monday — 6 activities logged.', 'color': AppTheme.brandGold},
    {'icon': Icons.access_time_rounded, 'text': 'Best publishing time: 2–4 PM. Your prompts get 2.4× more engagement.', 'color': AppTheme.electricBlue},
    {'icon': Icons.trending_up_rounded, 'text': 'Your fastest growing week: +28 followers in 7 days.', 'color': const Color(0xFF00E5A0)},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() => _isSearchFocused = _searchFocus.hasFocus));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.07), Colors.transparent]),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 100)),

              // ─── SUMMARY HERO ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildSummaryCard(),
                ),
              ),

              // ─── AI INSIGHTS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13),
                    const SizedBox(width: 6),
                    Text('AI INSIGHTS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _aiInsights.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _buildInsightCard(_aiInsights[i]),
                  ),
                ),
              ),

              // ─── TIMELINE ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text('ACTIVITY TIMELINE', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, groupIndex) => _buildTimelineGroup(_timelineGroups[groupIndex]),
                    childCount: _timelineGroups.length,
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
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 10),
          color: const Color(0xD506050C),
          child: Column(
            children: [
              Row(
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
                        Text('Activity History', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('Track your complete AI creator journey.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.filter_list_rounded, color: Colors.white70, size: 20), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 20), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 8),
              // Search Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _isSearchFocused ? AppTheme.brandOrange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    hintStyle: GoogleFonts.inter(fontSize: 12.5, color: Colors.white24),
                    prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Colors.white30),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Filter chips
              SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    return AnzorChip(
                      label: f,
                      isSelected: _activeFilter == f,
                      onTap: () { setState(() => _activeFilter = f); HapticFeedback.selectionClick(); },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AnzorCard(
      padding: const EdgeInsets.all(18),
      addGlow: true,
      glowColor: AppTheme.brandOrange,
      backgroundGradientColors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppTheme.brandOrange, size: 18),
              const SizedBox(width: 8),
              Text('ACTIVITY SUMMARY', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1)),
              const Spacer(),
              Text('Last 30 days', style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _summaryStats.length,
            itemBuilder: (_, i) {
              final stat = _summaryStats[i];
              final color = stat['color'] as Color;
              return Row(
                children: [
                  Icon(stat['icon'] as IconData, color: color, size: 14),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stat['value'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
                      Text(stat['label'] as String, style: GoogleFonts.inter(fontSize: 9, color: Colors.white30)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final color = insight['color'] as Color;
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(insight['icon'] as IconData, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(insight['text'] as String, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white60, height: 1.35), maxLines: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineGroup(Map<String, dynamic> group) {
    final items = group['items'] as List<Map<String, dynamic>>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.brandOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2)),
                ),
                child: Text(group['group'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.brandOrange)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.05))),
            ],
          ),
        ),
        ...items.asMap().entries.map((entry) => _buildTimelineItem(entry.value, entry.key == items.length - 1)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    final color = item['color'] as Color;
    final status = item['status'] as String?;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 13),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.05)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AnzorCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white))),
                        Text(item['time'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item['desc'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), height: 1.4)),
                    if (status != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(status, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
