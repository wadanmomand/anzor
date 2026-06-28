import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({super.key});
  @override
  State<TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView>
    with TickerProviderStateMixin {
  late AnimationController _liveController;
  late AnimationController _pulseController;
  String _activeTime = 'Today';
  String _activeCategory = 'All';

  final List<String> _timeFilters = ['Today', 'This Week', 'This Month', 'All Time'];
  final List<String> _categories = [
    'All', 'Text', 'Image', 'Video', 'Business', 'Coding', 'Marketing', 'Photography', 'Education', 'Music', '3D',
  ];

  final List<Map<String, dynamic>> _trendingPrompts = [
    {'rank': 1, 'title': 'Cyberpunk Rain Street', 'creator': 'usman', 'model': 'Midjourney v6', 'score': '99.2', 'views': '24.5K', 'likes': '3.2K', 'growth': '+142%', 'image': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&q=80&w=80', 'color': AppTheme.brandOrange},
    {'rank': 2, 'title': 'Volumetric Portrait', 'creator': 'NeonKitten', 'model': 'Flux.1 Pro', 'score': '98.7', 'views': '18.2K', 'likes': '2.8K', 'growth': '+89%', 'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=80', 'color': const Color(0xFF00D9FF)},
    {'rank': 3, 'title': 'Galaxy Nebula Scene', 'creator': 'AI_Architect', 'model': 'Midjourney v6', 'score': '97.4', 'views': '12.1K', 'likes': '1.9K', 'growth': '+67%', 'image': 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&q=80&w=80', 'color': const Color(0xFF7C4DFF)},
    {'rank': 4, 'title': 'Product Launch Email', 'creator': 'PixelPioneer', 'model': 'GPT-4o', 'score': '95.8', 'views': '9.4K', 'likes': '1.2K', 'growth': '+44%', 'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&q=80&w=80', 'color': const Color(0xFF00E5A0)},
  ];

  final List<Map<String, dynamic>> _trendingCreators = [
    {'name': 'usman', 'display': 'Usman Al-Farsi', 'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=usman', 'growth': '+28%', 'followers': '3.4K', 'level': 'Elite', 'color': AppTheme.brandOrange},
    {'name': 'NeonKitten', 'display': 'Sarah Jennings', 'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten', 'growth': '+19%', 'followers': '1.2K', 'level': 'Creator', 'color': const Color(0xFF00D9FF)},
    {'name': 'CyberBard', 'display': 'Evelyn Gray', 'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=CyberBard', 'growth': '+15%', 'followers': '1.5K', 'level': 'Elite', 'color': const Color(0xFF7C4DFF)},
    {'name': 'RetroRider', 'display': 'Derrick Vance', 'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider', 'growth': '+11%', 'followers': '820', 'level': 'Creator', 'color': const Color(0xFF00E5A0)},
  ];

  final List<Map<String, dynamic>> _trendingModels = [
    {'logo': '🎨', 'name': 'Midjourney v6', 'usage': '38%', 'growth': '+12%', 'color': AppTheme.brandOrange},
    {'logo': '🤖', 'name': 'GPT-4o', 'usage': '29%', 'growth': '+7%', 'color': const Color(0xFF00E5A0)},
    {'logo': '⚡', 'name': 'Flux.1 Pro', 'usage': '18%', 'growth': '+22%', 'color': AppTheme.electricBlue},
    {'logo': '🧠', 'name': 'Claude 3.5', 'usage': '15%', 'growth': '+9%', 'color': const Color(0xFF7C4DFF)},
  ];

  final List<Map<String, dynamic>> _challenges = [
    {'title': 'Cinematic Portrait Week', 'reward': '500 XP + Gold Badge', 'participants': '1,240', 'timeLeft': '2d 14h', 'color': AppTheme.brandOrange, 'icon': Icons.camera_alt_rounded},
    {'title': 'AI Code Challenge', 'reward': '300 XP + Silver Badge', 'participants': '680', 'timeLeft': '4d 8h', 'color': const Color(0xFF00D9FF), 'icon': Icons.code_rounded},
    {'title': 'Abstract Art Sprint', 'reward': '200 XP + Bronze Badge', 'participants': '920', 'timeLeft': '6d 2h', 'color': const Color(0xFF7C4DFF), 'icon': Icons.palette_rounded},
  ];

  final List<Map<String, dynamic>> _aiInsights = [
    {'icon': Icons.trending_up_rounded, 'text': 'Image prompts are growing 45% faster than text prompts this week.', 'color': AppTheme.brandOrange},
    {'icon': Icons.access_time_rounded, 'text': 'Best publishing window: Saturday 2–5 PM. 3× more engagement.', 'color': AppTheme.electricBlue},
    {'icon': Icons.label_rounded, 'text': 'Trending keywords: "volumetric", "cinematic", "neon", "8K render".', 'color': const Color(0xFF00E5A0)},
  ];

  @override
  void initState() {
    super.initState();
    _liveController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _liveController.dispose();
    _pulseController.dispose();
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
            top: -60, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent]),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 110)),

              // ─── LIVE HERO ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildLiveHero())),

              // ─── TIME FILTER ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: _timeFilters.map((t) => Expanded(child: GestureDetector(
                    onTap: () { setState(() => _activeTime = t); HapticFeedback.selectionClick(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTime == t ? AppTheme.brandOrange.withValues(alpha: 0.15) : const Color(0xFF0F0E1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _activeTime == t ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Text(t, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, color: _activeTime == t ? AppTheme.brandOrange : Colors.white38)),
                    ),
                  ))).toList(),
                ),
              )),

              // ─── TRENDING PROMPTS ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: _sectionLabel('🔥 TRENDING PROMPTS'))),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildTrendingPromptCard(_trendingPrompts[i])),
                    childCount: _trendingPrompts.length,
                  ),
                ),
              ),

              // ─── TRENDING CREATORS ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 10), child: _sectionLabel('🚀 TRENDING CREATORS'))),
              SliverToBoxAdapter(child: SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _trendingCreators.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildCreatorCard(_trendingCreators[i]),
                ),
              )),

              // ─── TRENDING MODELS ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: _sectionLabel('🤖 TRENDING AI MODELS'))),
              SliverToBoxAdapter(child: SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _trendingModels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildModelCard(_trendingModels[i]),
                ),
              )),

              // ─── WEEKLY CHALLENGES ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: _sectionLabel('🏆 WEEKLY CHALLENGES'))),
              SliverToBoxAdapter(child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildChallengeCard(_challenges[i]),
                ),
              )),

              // ─── AI INSIGHTS ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13), const SizedBox(width: 6), _sectionLabel('AI INSIGHTS')]))),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildInsightCard(_aiInsights[i])),
                    childCount: _aiInsights.length,
                  ),
                ),
              ),
            ],
          ),

          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),
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
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Trending', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(width: 8),
                      AnimatedBuilder(animation: _liveController, builder: (_, __) => Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF4D6A).withValues(alpha: 0.5 + _liveController.value * 0.5),
                          boxShadow: [BoxShadow(color: const Color(0xFFFF4D6A).withValues(alpha: _liveController.value * 0.6), blurRadius: 6)],
                        ),
                      )),
                      const SizedBox(width: 4),
                      Text('LIVE', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFFF4D6A))),
                    ]),
                    Text('Discover what\'s trending across the AI world.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                  ])),
                  IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20), onPressed: () { HapticFeedback.lightImpact(); }),
                  IconButton(icon: const Icon(Icons.filter_list_rounded, color: Colors.white70, size: 20), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final c = _categories[i];
                    return AnzorChip(label: c, isSelected: _activeCategory == c, onTap: () { setState(() => _activeCategory = c); HapticFeedback.selectionClick(); });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHero() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.brandOrange.withValues(alpha: 0.14 + _pulseController.value * 0.04), AppTheme.electricBlue.withValues(alpha: 0.06)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: AppTheme.brandOrange.withValues(alpha: 0.12 + _pulseController.value * 0.06), blurRadius: 20)],
        ),
        child: Column(
          children: [
            Row(children: [
              const Icon(Icons.local_fire_department_rounded, color: AppTheme.brandOrange, size: 18),
              const SizedBox(width: 8),
              Text('LIVE TRENDING TODAY', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.brandOrange, letterSpacing: 1)),
              const Spacer(),
              Text('Updated just now', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _heroStat('🔥', 'Fastest Growing', 'Cyberpunk Rain Street', AppTheme.brandOrange),
              _verticalDivider(),
              _heroStat('⭐', 'Creator of the Day', '@usman', AppTheme.brandGold),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _heroStat('🤖', 'Top AI Model', 'Midjourney v6', AppTheme.electricBlue),
              _verticalDivider(),
              _heroStat('📈', 'Total Activity', '+12.4K today', const Color(0xFF00E5A0)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String emoji, String label, String value, Color color) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 4), Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38))]),
      Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    ]));
  }

  Widget _verticalDivider() => Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.06), margin: const EdgeInsets.symmetric(horizontal: 12));

  Widget _buildTrendingPromptCard(Map<String, dynamic> prompt) {
    final color = prompt['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
            child: Center(child: Text('#${prompt['rank']}', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: color))),
          ),
          const SizedBox(width: 10),
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(prompt['image'] as String, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: Colors.white10)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prompt['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1),
              Text('@${prompt['creator']} • ${prompt['model']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
              const SizedBox(height: 6),
              Row(children: [
                _miniStat(Icons.remove_red_eye_outlined, prompt['views'] as String),
                const SizedBox(width: 10),
                _miniStat(Icons.favorite_border_rounded, prompt['likes'] as String),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(prompt['growth'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF00E5A0))),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(prompt['score'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(children: [Icon(icon, color: Colors.white30, size: 11), const SizedBox(width: 3), Text(value, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38))]);
  }

  Widget _buildCreatorCard(Map<String, dynamic> creator) {
    final color = creator['color'] as Color;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(creator['avatar'] as String)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(creator['growth'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w800, color: const Color(0xFF00E5A0))),
            ),
          ]),
          const SizedBox(height: 8),
          Text(creator['display'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1),
          Text('${creator['followers']} followers', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final color = model['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(model['logo'] as String, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(model['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            Row(children: [
              Text('${model['usage']} usage', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
              const SizedBox(width: 6),
              Text(model['growth'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF00E5A0))),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final color = challenge['color'] as Color;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(challenge['icon'] as IconData, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(challenge['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1)),
          ]),
          const SizedBox(height: 6),
          Text('🏆 ${challenge['reward']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
          const Spacer(),
          Row(children: [
            Text('${challenge['participants']} joined', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
            const Spacer(),
            Text('⏳ ${challenge['timeLeft']}', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('Join Challenge', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: color))),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final color = insight['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)), child: Icon(insight['icon'] as IconData, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(insight['text'] as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.4))),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4));
  }
}
