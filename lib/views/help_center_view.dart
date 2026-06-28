import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'contact_support_view.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});
  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  int _expandedFaq = -1;

  final List<Map<String, dynamic>> _quickHelp = [
    {'icon': Icons.rocket_launch_rounded, 'label': 'Getting Started', 'color': AppTheme.brandOrange},
    {'icon': Icons.smart_toy_rounded, 'label': 'AI Prompt Guide', 'color': const Color(0xFF00D9FF)},
    {'icon': Icons.workspace_premium_rounded, 'label': 'Premium Plan', 'color': const Color(0xFFFFD700)},
    {'icon': Icons.person_rounded, 'label': 'Account & Profile', 'color': const Color(0xFF00E5A0)},
    {'icon': Icons.collections_bookmark_rounded, 'label': 'Collections', 'color': const Color(0xFF7C4DFF)},
    {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': Colors.white54},
    {'icon': Icons.lock_rounded, 'label': 'Privacy', 'color': const Color(0xFFFF4D6A)},
    {'icon': Icons.bug_report_rounded, 'label': 'Report a Bug', 'color': const Color(0xFFFFC107)},
  ];

  final List<Map<String, dynamic>> _popularFaqs = [
    {
      'q': 'How do I create my first AI prompt?',
      'a': 'Tap the "Create" button on the home screen. Choose your AI model, describe what you want, and hit "Generate". Your prompt will be saved automatically.',
      'category': 'Getting Started',
    },
    {
      'q': 'How do I publish prompts to the community?',
      'a': 'Once you\'ve created a prompt, tap "Publish" from the prompt editor. Fill in the title, description, and category, then hit the Publish button.',
      'category': 'Publishing',
    },
    {
      'q': 'How do I earn creator badges?',
      'a': 'Badges are earned by completing achievements. Publish prompts, gain followers, receive likes, and participate in challenges to unlock badges.',
      'category': 'Achievements',
    },
    {
      'q': 'What does Anzor Premium include?',
      'a': 'Premium gives you unlimited AI prompt generation, access to 15+ advanced AI models, cloud backup, advanced analytics, unlimited collections, and priority support.',
      'category': 'Premium',
    },
    {
      'q': 'How do I recover my account?',
      'a': 'Go to the login screen and tap "Forgot Password". Enter your registered email address and you\'ll receive a reset link within 2 minutes.',
      'category': 'Account',
    },
    {
      'q': 'Can I use Anzor offline?',
      'a': 'Basic browsing and draft editing works offline. AI generation and publishing require an internet connection.',
      'category': 'General',
    },
  ];

  final List<Map<String, dynamic>> _guides = [
    {'icon': Icons.edit_note_rounded, 'title': 'Prompt Engineering', 'desc': '7 techniques to write better prompts', 'color': AppTheme.brandOrange, 'duration': '5 min read'},
    {'icon': Icons.person_pin_rounded, 'title': 'Creator Guide', 'desc': 'Build your audience and grow on Anzor', 'color': const Color(0xFF7C4DFF), 'duration': '8 min read'},
    {'icon': Icons.balance_rounded, 'title': 'Community Rules', 'desc': 'What\'s allowed on the platform', 'color': const Color(0xFFFF4D6A), 'duration': '3 min read'},
    {'icon': Icons.upload_rounded, 'title': 'Publishing Guide', 'desc': 'Maximize reach when you publish', 'color': const Color(0xFF00E5A0), 'duration': '6 min read'},
  ];

  final List<Map<String, dynamic>> _systemStatus = [
    {'label': 'AI Services', 'status': 'Operational', 'color': const Color(0xFF00E5A0)},
    {'label': 'Cloud Sync', 'status': 'Operational', 'color': const Color(0xFF00E5A0)},
    {'label': 'Notifications', 'status': 'Operational', 'color': const Color(0xFF00E5A0)},
    {'label': 'API Services', 'status': 'Degraded', 'color': const Color(0xFFFFC107)},
  ];

  final List<Map<String, dynamic>> _aiAnswers = [
    'How do I improve my prompts?',
    'Why was my prompt rejected?',
    'Which AI model should I use?',
    'How do I increase followers?',
  ].map((q) => {'q': q}).toList();

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
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.07), Colors.transparent]),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              // ─── QUICK HELP GRID ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('QUICK HELP', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildQuickHelpCard(_quickHelp[i]),
                    childCount: _quickHelp.length,
                  ),
                ),
              ),

              // ─── AI SUPPORT ASSISTANT ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13), const SizedBox(width: 6), Text('AI SUPPORT ASSISTANT', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4))]),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildAiAssistantCard(),
              )),

              // ─── POPULAR QUESTIONS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('POPULAR QUESTIONS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildFaqCard(i)),
                    childCount: _popularFaqs.length,
                  ),
                ),
              ),

              // ─── GUIDES ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('GUIDES & TUTORIALS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _guides.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildGuideCard(_guides[i]),
                ),
              )),

              // ─── SYSTEM STATUS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('SYSTEM STATUS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnzorCard(padding: const EdgeInsets.all(16), child: Column(
                  children: _systemStatus.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: s['color'] as Color, boxShadow: [BoxShadow(color: (s['color'] as Color).withValues(alpha: 0.5), blurRadius: 6)])),
                      const SizedBox(width: 12),
                      Text(s['label'] as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                      const Spacer(),
                      Text(s['status'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: s['color'] as Color)),
                    ]),
                  )).toList(),
                )),
              )),

              // ─── CONTACT OPTIONS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('STILL NEED HELP?', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final options = [
                        {'icon': Icons.chat_bubble_outline_rounded, 'title': 'Live Chat', 'desc': 'Chat with our support team (coming soon)', 'color': AppTheme.brandOrange, 'action': null},
                        {'icon': Icons.email_outlined, 'title': 'Email Support', 'desc': 'We reply within 24 hours', 'color': const Color(0xFF00D9FF), 'action': null},
                        {'icon': Icons.confirmation_number_outlined, 'title': 'Submit Ticket', 'desc': 'Track your support request', 'color': const Color(0xFF00E5A0), 'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportView()))},
                      ];
                      final o = options[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (o['action'] != null) (o['action'] as VoidCallback)();
                          },
                          child: AnzorCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: (o['color'] as Color).withValues(alpha: 0.1)), child: Icon(o['icon'] as IconData, color: o['color'] as Color, size: 20)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(o['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text(o['desc'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                              ])),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.2), size: 14),
                            ]),
                          ),
                        ),
                      );
                    },
                    childCount: 3,
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
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
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
                    Text('Help Center', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('How can we help you today?', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.headset_mic_rounded, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportView())),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isSearchFocused ? AppTheme.brandOrange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
                  boxShadow: _isSearchFocused ? [BoxShadow(color: AppTheme.brandOrange.withValues(alpha: 0.1), blurRadius: 12)] : [],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search help articles, guides...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white24),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Colors.white30),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () { _searchController.clear(); setState(() {}); },
                            child: const Icon(Icons.close_rounded, size: 16, color: Colors.white30),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'] as IconData, color: color, size: 22),
            const SizedBox(height: 6),
            Text(item['label'] as String, style: GoogleFonts.inter(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAssistantCard() {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      addGlow: true,
      glowColor: AppTheme.brandOrange,
      backgroundGradientColors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.3), Colors.transparent])), child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 17)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Support Assistant', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Ask anything — I\'ll find the answer instantly.', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
            ]),
          ]),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _aiAnswers.map((a) => GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                child: Text(a['q'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(int index) {
    final faq = _popularFaqs[index];
    final isOpen = _expandedFaq == index;
    return GestureDetector(
      onTap: () { setState(() => _expandedFaq = isOpen ? -1 : index); HapticFeedback.selectionClick(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0E1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isOpen ? AppTheme.brandOrange.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(faq['q'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: isOpen ? Colors.white : Colors.white70))),
              Icon(isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: isOpen ? AppTheme.brandOrange : Colors.white30, size: 20),
            ]),
            if (isOpen) ...[
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              const SizedBox(height: 8),
              Text(faq['a'] as String, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54, height: 1.6)),
              const SizedBox(height: 10),
              Row(children: [
                _feedbackBtn('Helpful', Icons.thumb_up_outlined, const Color(0xFF00E5A0)),
                const SizedBox(width: 8),
                _feedbackBtn('Not helpful', Icons.thumb_down_outlined, Colors.white30),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feedbackBtn(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: color)),
      ]),
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> guide) {
    final color = guide['color'] as Color;
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(guide['icon'] as IconData, color: color, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                child: Text(guide['duration'] as String, style: GoogleFonts.inter(fontSize: 8.5, color: color, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(guide['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(guide['desc'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38), maxLines: 2),
          ],
        ),
      ),
    );
  }
}
