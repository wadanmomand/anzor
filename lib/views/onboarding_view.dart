import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;
  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  int _currentPage = 0;
  String _selectedLang = 'English';

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '🤖',
      'headline': 'Welcome to Anzor AI',
      'sub': 'The world\'s premium platform for AI prompt creators.',
      'gradient': [const Color(0xFFFF6B35), const Color(0xFFFF8C00)],
      'bg': const Color(0xFF1A0A00),
      'particles': ['✦', '✧', '⭐', '✨', '🌟'],
    },
    {
      'emoji': '⚡',
      'headline': 'Create Smarter Prompts',
      'sub': 'Generate professional prompts for text, images, video, coding, business, and more with state-of-the-art AI models.',
      'gradient': [const Color(0xFF00D9FF), const Color(0xFF00A8CC)],
      'bg': const Color(0xFF001A22),
      'particles': ['💡', '⚡', '🔥', '✦', '✧'],
    },
    {
      'emoji': '🌍',
      'headline': 'Join the AI Creator Community',
      'sub': 'Follow creators, discover trending prompts, build collections, earn achievements, and climb the global leaderboard.',
      'gradient': [const Color(0xFF7C4DFF), const Color(0xFF5E35B1)],
      'bg': const Color(0xFF0D0020),
      'particles': ['👑', '🏆', '⭐', '✦', '🎯'],
    },
    {
      'emoji': '🚀',
      'headline': 'Start Your AI Journey',
      'sub': 'Everything is ready. Let\'s build amazing prompts together and change the world with AI.',
      'gradient': [const Color(0xFF00E5A0), const Color(0xFF00B37A)],
      'bg': const Color(0xFF001A0F),
      'particles': ['🚀', '✨', '🌟', '💎', '✦'],
    },
  ];

  final List<String> _langs = ['English', 'اردو', 'پښتو', 'العربية', 'فارسی'];
  final List<Map<String, dynamic>> _highlights = [
    {'icon': '🤖', 'label': 'AI Prompt Studio'},
    {'icon': '📚', 'label': 'Collections'},
    {'icon': '🌍', 'label': 'Community'},
    {'icon': '🏆', 'label': 'Leaderboard'},
    {'icon': '📊', 'label': 'Analytics'},
    {'icon': '👑', 'label': 'Premium'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) { setState(() => _currentPage = i); _animController.forward(from: 0); },
            itemCount: _pages.length,
            itemBuilder: (_, i) => _buildPage(_pages[i]),
          ),
          // Page indicators
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0, right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentPage == i ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.2),
              ),
            ))),
          ),
          // Skip
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))), child: Text('Skip', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54))),
            ),
          ),
          // Bottom panel
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel()),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    final gradient = page['gradient'] as List<Color>;
    final particles = page['particles'] as List<String>;
    return Container(
      color: page['bg'] as Color,
      child: Stack(
        children: [
          // Ambient glow
          Positioned(top: -80, right: -80, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [gradient[0].withValues(alpha: 0.15), Colors.transparent])))),
          Positioned(bottom: 100, left: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [gradient[1].withValues(alpha: 0.1), Colors.transparent])))),
          // Floating particles
          ...List.generate(5, (i) => Positioned(
            top: 100.0 + i * 80,
            left: i % 2 == 0 ? 30.0 + i * 20 : null,
            right: i % 2 != 0 ? 30.0 + i * 15 : null,
            child: AnimatedBuilder(animation: _floatAnim, builder: (_, __) => Transform.translate(
              offset: Offset(0, _floatAnim.value * (i % 2 == 0 ? 1 : -1)),
              child: Text(particles[i], style: TextStyle(fontSize: 18.0 + i * 3, color: Colors.white.withValues(alpha: 0.12))),
            )),
          )),
          // Main content
          SafeArea(
            child: Column(children: [
              const SizedBox(height: 60),
              // Emoji hero
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _floatAnim.value * 0.5),
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [gradient[0].withValues(alpha: 0.3), Colors.transparent])),
                    child: Center(child: Text(page['emoji'] as String, style: const TextStyle(fontSize: 60))),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Text
              FadeTransition(
                opacity: CurvedAnimation(parent: _animController, curve: Curves.easeOut),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(children: [
                    Text(page['headline'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(page['sub'] as String, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6), height: 1.6), textAlign: TextAlign.center),
                  ]),
                ),
              ),
              // Feature highlights on first page
              if (_currentPage == 0) ...[
                const SizedBox(height: 28),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: _highlights.map((h) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Text(h['icon'] as String, style: const TextStyle(fontSize: 14)), const SizedBox(width: 6), Text(h['label'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70))]),
                  )).toList()),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    final isLast = _currentPage == _pages.length - 1;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 20),
          color: const Color(0xCC06050C),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isLast) ...[
              // Language chips
              Text('Choose your language', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _langs.map((l) => GestureDetector(
                  onTap: () { setState(() => _selectedLang = l); HapticFeedback.selectionClick(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: _selectedLang == l ? AppTheme.brandOrange.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: _selectedLang == l ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.08))),
                    child: Text(l, style: GoogleFonts.inter(fontSize: 12, color: _selectedLang == l ? AppTheme.brandOrange : Colors.white54)),
                  ),
                )).toList()),
              ),
              const SizedBox(height: 14),
              AnzorButton(height: 52, onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())), child: Text('Create Account  →', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white))),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())),
                child: Text('Already have an account? Sign In', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.brandOrange, fontWeight: FontWeight.w600)),
              ),
            ] else ...[
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())),
                  child: Container(height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Center(child: Text('Sign In', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)))),
                )),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: AnzorButton(height: 48, onPressed: _nextPage, child: Text('Continue  →', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)))),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}
