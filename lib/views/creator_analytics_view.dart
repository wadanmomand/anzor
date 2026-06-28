import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class CreatorAnalyticsView extends StatefulWidget {
  const CreatorAnalyticsView({super.key});

  @override
  State<CreatorAnalyticsView> createState() => _CreatorAnalyticsViewState();
}

class _CreatorAnalyticsViewState extends State<CreatorAnalyticsView> {
  String _timeRange = '30 Days';

  final List<Map<String, dynamic>> _topPrompts = [
    {
      'title': 'Cyberpunk Neon Street Alley',
      'model': 'Midjourney v6',
      'views': '1.2K',
      'saves': '420',
      'copies': '890',
      'score': '98%',
      'image': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&q=80&w=200'
    },
    {
      'title': 'Volumetric Cinematic Portrait',
      'model': 'Flux.1 Pro',
      'views': '980',
      'saves': '310',
      'copies': '650',
      'score': '96%',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;
    final myProfile = appState.currentUserProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -120, right: -120,
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

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 70)),

              // Time Range Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CREATOR PERFORMANCE',
                        style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _timeRange,
                            dropdownColor: const Color(0xFF131024),
                            style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.brandOrange),
                            items: ['7 Days', '30 Days', '90 Days', '1 Year'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _timeRange = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overview Stats Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _buildMetricBox('Total Prompt Views', '14.5K', Icons.remove_red_eye_outlined, AppTheme.electricBlue),
                    _buildMetricBox('Total Prompt Saves', '2,450', Icons.bookmark_border_rounded, AppTheme.brandOrange),
                    _buildMetricBox('Prompt Copies', '6,890', Icons.copy_all_rounded, Colors.purpleAccent),
                    _buildMetricBox('Audience Growth', '+24%', Icons.trending_up_rounded, const Color(0xFF00FF7F)),
                  ],
                ),
              ),

              // Interactive Neon Chart Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY VIEWS TREND LINE',
                        style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderColor: AppTheme.brandOrange.withValues(alpha: 0.15),
                        child: const PerformanceChart(
                          title: 'DAILY REACH (VIEWS)',
                          dataPoints: [120, 240, 180, 420, 310, 560, 480],
                          neonColor: AppTheme.brandOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // AI Performance recommendations
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI REPUTATION INSIGHTS',
                        style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      AnzorCard(
                        borderColor: AppTheme.brandOrange.withValues(alpha: 0.2),
                        child: Column(
                          children: [
                            _buildAIInsightRow('Best posting time detected: 6:00 PM UTC on Thursdays.', Icons.av_timer_rounded),
                            const Divider(color: Color(0x1BFFFFFF), height: 16),
                            _buildAIInsightRow('Midjourney prompts targeting "volumetric cinematic" are trending +45%.', Icons.auto_awesome_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Performing Prompts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'TOP PERFORMING PROMPTS',
                    style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _topPrompts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnzorCard(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['image'], width: 44, height: 44, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'], style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text('${item['model']}  •  ${item['views']} views', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                                  ],
                                ),
                              ),
                              Text(item['score'], style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.brandOrange)),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _topPrompts.length,
                  ),
                ),
              ),

              // Audience distribution
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'AUDIENCE GEOGRAPHY INSIGHTS',
                    style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: AnzorCard(
                    child: Column(
                      children: [
                        _buildAudienceRow('United States', '42%', 0.42),
                        const SizedBox(height: 8),
                        _buildAudienceRow('United Kingdom', '18%', 0.18),
                        const SizedBox(height: 8),
                        _buildAudienceRow('Germany', '12%', 0.12),
                      ],
                    ),
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
        ],
      ),
    );
  }

  Widget _buildFrostedHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD206050C),
          child: Row(
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
                    'Creator Analytics',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  Text(
                    'Understand your growth and improve reach.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white60, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report generated & downloaded!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String val, IconData icon, Color color) {
    return AnzorCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildAIInsightRow(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.brandOrange),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.45)),
        ),
      ],
    );
  }

  Widget _buildAudienceRow(String country, String pct, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(country, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
            Text(pct, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.03),
          valueColor: const AlwaysStoppedAnimation(AppTheme.brandOrange),
          minHeight: 3,
        ),
      ],
    );
  }
}
