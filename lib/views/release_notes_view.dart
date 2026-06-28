import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class ReleaseNotesView extends StatefulWidget {
  const ReleaseNotesView({super.key});
  @override
  State<ReleaseNotesView> createState() => _ReleaseNotesViewState();
}

class _ReleaseNotesViewState extends State<ReleaseNotesView>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  int _expandedBug = -1;
  int _expandedHistory = -1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, dynamic> _latestRelease = {
    'version': '2.4.0',
    'date': 'June 28, 2026',
    'size': '24.5 MB',
    'status': 'Latest',
    'highlights': ['New AI Models', 'Trending Dashboard', 'Performance Boost', 'UI Overhaul'],
    'platform': ['iOS', 'Android'],
  };

  final List<Map<String, dynamic>> _versions = [
    {'version': '2.4.0', 'date': 'Jun 28, 2026', 'size': '24.5 MB', 'status': 'Latest', 'color': AppTheme.brandOrange},
    {'version': '2.3.5', 'date': 'Jun 12, 2026', 'size': '8.2 MB', 'status': 'Stable', 'color': const Color(0xFF00E5A0)},
    {'version': '2.3.0', 'date': 'May 30, 2026', 'size': '18.7 MB', 'status': 'Stable', 'color': const Color(0xFF00D9FF)},
    {'version': '2.2.1', 'date': 'May 14, 2026', 'size': '5.4 MB', 'status': 'Hotfix', 'color': const Color(0xFFFF4D6A)},
    {'version': '2.2.0', 'date': 'Apr 25, 2026', 'size': '22.1 MB', 'status': 'Major', 'color': const Color(0xFF7C4DFF)},
  ];

  final List<Map<String, dynamic>> _features = [
    {'icon': '🤖', 'title': 'New AI Models', 'desc': 'GPT-4o, Claude 3.5 Sonnet, Flux Ultra, and Gemini 1.5 Pro are now available.', 'color': AppTheme.brandOrange, 'tag': 'New'},
    {'icon': '⚡', 'title': 'Faster Generation', 'desc': 'Prompt generation is now 3× faster with our new AI pipeline architecture.', 'color': const Color(0xFF00D9FF), 'tag': 'Improved'},
    {'icon': '🎨', 'title': 'UI Overhaul', 'desc': 'Redesigned cards, animations, and glassmorphism effects across the entire app.', 'color': const Color(0xFF7C4DFF), 'tag': 'Design'},
    {'icon': '📚', 'title': 'Collections 2.0', 'desc': 'Smart folders, AI-suggested organization, and batch management tools.', 'color': const Color(0xFF00E5A0), 'tag': 'New'},
    {'icon': '👑', 'title': 'Premium Features', 'desc': 'Lifetime plan, team features, and 500+ premium templates added.', 'color': AppTheme.brandGold, 'tag': 'Premium'},
    {'icon': '📊', 'title': 'Analytics 3.0', 'desc': 'Deep audience insights, revenue tracking, and content performance scores.', 'color': const Color(0xFFFF4D6A), 'tag': 'Improved'},
  ];

  final List<Map<String, dynamic>> _bugFixes = [
    {'title': 'Prompt generation timeout', 'fixed': 'Fixed timeout on large context AI models', 'category': 'Performance', 'impact': 'High', 'status': 'Fixed'},
    {'title': 'Collection sync error', 'fixed': 'Cloud sync now handles conflicts correctly', 'category': 'Cloud', 'impact': 'Medium', 'status': 'Fixed'},
    {'title': 'Dark mode flickering', 'fixed': 'Eliminated frame drops during theme switching', 'category': 'UI', 'impact': 'Low', 'status': 'Fixed'},
    {'title': 'Notification badge count', 'fixed': 'Badge count now resets correctly on read', 'category': 'Notifications', 'impact': 'Low', 'status': 'Fixed'},
  ];

  final List<Map<String, dynamic>> _performance = [
    {'label': 'App Launch', 'before': '2.8s', 'after': '0.9s', 'improvement': '68%', 'icon': Icons.rocket_launch_rounded, 'color': AppTheme.brandOrange},
    {'label': 'Memory Usage', 'before': '184 MB', 'after': '112 MB', 'improvement': '39%', 'icon': Icons.memory_rounded, 'color': const Color(0xFF00D9FF)},
    {'label': 'Battery Impact', 'before': 'High', 'after': 'Low', 'improvement': '55%', 'icon': Icons.battery_charging_full_rounded, 'color': const Color(0xFF00E5A0)},
    {'label': 'Network Usage', 'before': '3.2 MB/hr', 'after': '1.1 MB/hr', 'improvement': '66%', 'icon': Icons.wifi_rounded, 'color': const Color(0xFF7C4DFF)},
  ];

  final List<Map<String, dynamic>> _roadmap = [
    {'icon': '🎙', 'title': 'AI Voice Prompts', 'desc': 'Generate prompts using voice commands', 'eta': 'Q3 2026', 'votes': 2840, 'color': AppTheme.brandOrange},
    {'icon': '👥', 'title': 'Team Collaboration', 'desc': 'Create and manage prompts as a team', 'eta': 'Q3 2026', 'votes': 1960, 'color': const Color(0xFF00D9FF)},
    {'icon': '🛒', 'title': 'Prompt Marketplace', 'desc': 'Buy and sell premium prompts', 'eta': 'Q4 2026', 'votes': 3120, 'color': AppTheme.brandGold},
    {'icon': '🔌', 'title': 'API Access', 'desc': 'Integrate Anzor with your own apps', 'eta': 'Q4 2026', 'votes': 1540, 'color': const Color(0xFF7C4DFF)},
    {'icon': '🖥', 'title': 'Desktop Version', 'desc': 'macOS and Windows native apps', 'eta': 'Q1 2027', 'votes': 2100, 'color': const Color(0xFF00E5A0)},
  ];

  final List<Map<String, dynamic>> _communityFeedback = [
    {'type': 'request', 'text': 'Add bulk export to Notion', 'votes': 847, 'status': 'Reviewing', 'color': AppTheme.brandOrange},
    {'type': 'love', 'text': 'The new collection UI is incredible!', 'votes': 1240, 'status': 'Loved', 'color': const Color(0xFFFF4D6A)},
    {'type': 'vote', 'text': 'Dark OLED theme support', 'votes': 632, 'status': 'Planned', 'color': const Color(0xFF7C4DFF)},
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          _buildAmbient(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 100)),

              // FEATURED RELEASE
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildFeaturedRelease())),

              // VERSION TIMELINE
              _sectionHeader('📋 VERSION TIMELINE'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildVersionCard(_versions[i], i == 0),
                  childCount: _versions.length,
                )),
              ),

              // NEW FEATURES
              _sectionHeader('✨ WHAT\'S NEW'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.4),
                  delegate: SliverChildBuilderDelegate((_, i) => _buildFeatureCard(_features[i]), childCount: _features.length),
                ),
              ),

              // BUG FIXES
              _sectionHeader('🐛 BUG FIXES'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildBugCard(i)),
                  childCount: _bugFixes.length,
                )),
              ),

              // PERFORMANCE
              _sectionHeader('⚡ PERFORMANCE IMPROVEMENTS'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7),
                  delegate: SliverChildBuilderDelegate((_, i) => _buildPerfCard(_performance[i]), childCount: _performance.length),
                ),
              ),

              // ROADMAP
              _sectionHeader('🗺 COMING SOON'),
              SliverToBoxAdapter(child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _roadmap.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildRoadmapCard(_roadmap[i]),
                ),
              )),

              // COMMUNITY
              _sectionHeader('💬 COMMUNITY FEEDBACK'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildFeedbackCard(_communityFeedback[i])),
                  childCount: _communityFeedback.length,
                )),
              ),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyBar()),
        ],
      ),
    );
  }

  Widget _buildAmbient() => AnimatedBuilder(
    animation: _glowController,
    builder: (_, __) => Stack(children: [
      Positioned(top: -80, right: -60, child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.08 + _glowController.value * 0.05), Colors.transparent])))),
      Positioned(bottom: 200, left: -80, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.05 + _glowController.value * 0.03), Colors.transparent])))),
    ]),
  );

  Widget _buildHeader(double topPad) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
        color: const Color(0xD506050C),
        child: Column(children: [
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("What's New", style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('Discover the latest updates and improvements.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
            ])),
            IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20), onPressed: () {}),
          ]),
        ]),
      ),
    ),
  );

  Widget _buildFeaturedRelease() => AnimatedBuilder(
    animation: _glowController,
    builder: (_, __) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.18 + _glowController.value * 0.06), AppTheme.brandGold.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppTheme.brandOrange.withValues(alpha: 0.18 + _glowController.value * 0.1), blurRadius: 28)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.brandOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.rocket_launch_rounded, color: AppTheme.brandOrange, size: 12),
            const SizedBox(width: 4),
            Text('LATEST RELEASE', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.brandOrange, letterSpacing: 0.8)),
          ])),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text('v${_latestRelease['version']}', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF00E5A0)))),
        ]),
        const SizedBox(height: 14),
        Text('Anzor ${_latestRelease['version']}', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text('Released ${_latestRelease['date']} • ${_latestRelease['size']}', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: (_latestRelease['highlights'] as List<String>).map((h) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Text(h, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
        )).toList()),
      ]),
    ),
  );

  Widget _buildVersionCard(Map<String, dynamic> v, bool isLatest) {
    final color = v['color'] as Color;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)])),
        if (!isLatest) Container(width: 1.5, height: 60, color: Colors.white.withValues(alpha: 0.08)),
      ]),
      const SizedBox(width: 14),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnzorCard(padding: const EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('v${v['version']}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)), child: Text(v['status'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w800, color: color))),
            ]),
            const SizedBox(height: 2),
            Text('${v['date']} • ${v['size']}', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
          ])),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2), size: 18),
        ])),
      )),
    ]);
  }

  Widget _buildFeatureCard(Map<String, dynamic> f) {
    final color = f['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Text(f['icon'] as String, style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)), child: Text(f['tag'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w800, color: color))),
        ]),
        const SizedBox(height: 8),
        Text(f['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1),
        const SizedBox(height: 3),
        Text(f['desc'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38, height: 1.3), maxLines: 2),
      ]),
    );
  }

  Widget _buildBugCard(int index) {
    final bug = _bugFixes[index];
    final isOpen = _expandedBug == index;
    return GestureDetector(
      onTap: () { setState(() => _expandedBug = isOpen ? -1 : index); HapticFeedback.selectionClick(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0E1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOpen ? const Color(0xFF00E5A0).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E5A0))),
            const SizedBox(width: 10),
            Expanded(child: Text(bug['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            _tagChip(bug['category'] as String, Colors.white.withValues(alpha: 0.1), Colors.white38),
            const SizedBox(width: 6),
            _tagChip(bug['impact'] as String, const Color(0xFF00E5A0).withValues(alpha: 0.1), const Color(0xFF00E5A0)),
          ]),
          if (isOpen) ...[const SizedBox(height: 10), Text(bug['fixed'] as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, height: 1.5))],
        ]),
      ),
    );
  }

  Widget _buildPerfCard(Map<String, dynamic> p) {
    final color = p['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(p['icon'] as IconData, color: color, size: 18), const Spacer(), Text('+${p['improvement']}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF00E5A0)))]),
        const SizedBox(height: 8),
        Text(p['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text('${p['before']} → ${p['after']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      ]),
    );
  }

  Widget _buildRoadmapCard(Map<String, dynamic> r) {
    final color = r['color'] as Color;
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r['icon'] as String, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(r['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(r['desc'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38), maxLines: 1),
        const Spacer(),
        Row(children: [
          Text(r['eta'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const Spacer(),
          const Icon(Icons.how_to_vote_rounded, color: Colors.white30, size: 12),
          const SizedBox(width: 3),
          Text('${r['votes']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
        ]),
      ]),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> f) {
    final color = f['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)), child: Icon(f['type'] == 'love' ? Icons.favorite_rounded : f['type'] == 'vote' ? Icons.how_to_vote_rounded : Icons.lightbulb_outline_rounded, color: color, size: 17)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f['text'] as String, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.arrow_upward_rounded, color: color, size: 11),
            const SizedBox(width: 3),
            Text('${f['votes']} votes', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
          ]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(f['status'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w700, color: color))),
      ]),
    );
  }

  Widget _buildStickyBar() => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); },
            child: Container(height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.share_rounded, color: Colors.white60, size: 16), const SizedBox(width: 6), Text('Share', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60))]))),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AnzorButton(height: 48, onPressed: () { HapticFeedback.mediumImpact(); }, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.system_update_rounded, color: Colors.white, size: 16), const SizedBox(width: 8), Text('Update Now', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))]))),
        ]),
      ),
    ),
  );

  SliverToBoxAdapter _sectionHeader(String label) => SliverToBoxAdapter(child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
  ));

  Widget _tagChip(String label, Color bg, Color text) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(label, style: GoogleFonts.inter(fontSize: 9, color: text)));
}
