import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class PremiumSubscriptionView extends StatefulWidget {
  const PremiumSubscriptionView({super.key});
  @override
  State<PremiumSubscriptionView> createState() => _PremiumSubscriptionViewState();
}

class _PremiumSubscriptionViewState extends State<PremiumSubscriptionView>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _glowController;
  int _selectedPlan = 1; // 0=Free, 1=Yearly, 2=Monthly, 3=Lifetime
  bool _isPurchasing = false;
  bool _showSuccess = false;
  int _expandedFaq = -1;

  final List<Map<String, dynamic>> _plans = [
    {'label': 'Free', 'price': '\$0', 'period': 'forever', 'badge': null, 'savings': null, 'color': Colors.white38},
    {'label': 'Yearly', 'price': '\$5.99', 'period': '/month', 'badge': '🔥 Best Value', 'savings': 'Save 50%', 'color': AppTheme.brandOrange},
    {'label': 'Monthly', 'price': '\$11.99', 'period': '/month', 'badge': null, 'savings': null, 'color': AppTheme.electricBlue},
    {'label': 'Lifetime', 'price': '\$149', 'period': 'one time', 'badge': '💎 Forever', 'savings': 'Best Deal', 'color': const Color(0xFFFFD700)},
  ];

  final List<Map<String, dynamic>> _benefits = [
    {'icon': '🚀', 'title': 'Unlimited Prompt Generation', 'desc': 'No daily caps — create as many prompts as you need'},
    {'icon': '🧠', 'title': 'Advanced AI Models', 'desc': 'Access GPT-4o, Claude 3.5, Flux Ultra, Midjourney v7'},
    {'icon': '☁️', 'title': 'Secure Cloud Backup', 'desc': 'All prompts and collections synced across devices'},
    {'icon': '📊', 'title': 'Advanced Creator Analytics', 'desc': 'Full dashboard with audience insights and trends'},
    {'icon': '📚', 'title': 'Unlimited Collections', 'desc': 'Organize unlimited prompt libraries with smart filters'},
    {'icon': '⭐', 'title': 'Exclusive Badges', 'desc': 'Premium-only achievements and profile badges'},
    {'icon': '🎯', 'title': 'Premium Templates', 'desc': 'Access 500+ curated expert-crafted prompt templates'},
    {'icon': '⚡', 'title': 'Priority Processing', 'desc': 'Faster AI responses and priority queue access'},
  ];

  final List<Map<String, dynamic>> _comparison = [
    {'feature': 'Daily Prompt Limit', 'free': '10/day', 'premium': 'Unlimited'},
    {'feature': 'AI Models', 'free': '3 Basic', 'premium': '15+ Advanced'},
    {'feature': 'Prompt History', 'free': '7 Days', 'premium': 'Forever'},
    {'feature': 'Collections', 'free': '3 Max', 'premium': 'Unlimited'},
    {'feature': 'Analytics', 'free': 'Basic', 'premium': 'Full Dashboard'},
    {'feature': 'Cloud Backup', 'free': false, 'premium': true},
    {'feature': 'Export Options', 'free': 'PDF Only', 'premium': 'PDF, CSV, JSON'},
    {'feature': 'Priority Support', 'free': false, 'premium': true},
  ];

  final List<Map<String, dynamic>> _faqs = [
    {'q': 'What happens after upgrading?', 'a': 'All Premium features activate instantly after purchase. You\'ll also receive a welcome badge.'},
    {'q': 'Can I cancel anytime?', 'a': 'Yes, you can cancel your subscription anytime from Settings. No questions asked.'},
    {'q': 'Will my data be safe?', 'a': 'Absolutely. All your prompts and collections are securely stored with enterprise-grade encryption.'},
    {'q': 'Do I keep my prompts if I cancel?', 'a': 'Yes! Your prompts remain available. You\'ll only lose access to Premium-only features.'},
    {'q': 'Is there a free trial?', 'a': 'Yes — new users get a 7-day Premium trial completely free, no card required.'},
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPurchasing = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    setState(() { _isPurchasing = false; _showSuccess = true; });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    if (_showSuccess) return _buildSuccess();

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Animated ambient glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: -80, right: -80,
                  child: Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppTheme.brandOrange.withValues(alpha: 0.10 + _glowController.value * 0.06),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 300, left: -60,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppTheme.brandGold.withValues(alpha: 0.06 + _glowController.value * 0.04),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 80)),

              // ─── PREMIUM HERO ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildPremiumHero(),
              )),

              // ─── PLAN SELECTOR ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildPlanSelector(),
              )),

              // ─── BENEFITS GRID ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('PREMIUM BENEFITS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildBenefitCard(_benefits[i]),
                    childCount: _benefits.length,
                  ),
                ),
              ),

              // ─── COMPARISON TABLE ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text('FREE VS PREMIUM', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildComparisonTable(),
              )),

              // ─── SOCIAL PROOF ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text('TRUSTED BY CREATORS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _buildSocialProof(),
              )),

              // ─── FAQ ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text('FREQUENTLY ASKED', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildFaqCard(i)),
                    childCount: _faqs.length,
                  ),
                ),
              ),
            ],
          ),

          // Glass Header
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),

          // Sticky CTA
          Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyBar()),
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
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Anzor Premium', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Unlock the full power of AI prompt creation.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                ]),
              ),
              TextButton(onPressed: () {}, child: Text('Restore', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange))),
              IconButton(icon: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 20), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHero() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.brandOrange.withValues(alpha: 0.18 + _glowController.value * 0.06), AppTheme.brandGold.withValues(alpha: 0.08)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: AppTheme.brandOrange.withValues(alpha: 0.15 + _glowController.value * 0.1), blurRadius: 28, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👑', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ANZOR PREMIUM', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Everything you need to create at scale', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _heroPill('Unlimited AI', Icons.all_inclusive_rounded),
                const SizedBox(width: 8),
                _heroPill('Cloud Sync', Icons.cloud_rounded),
                const SizedBox(width: 8),
                _heroPill('Priority', Icons.bolt_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPill(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.brandGold, size: 16),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      children: [
        Row(
          children: _plans.asMap().entries.map((e) {
            final i = e.key; final plan = e.value;
            final isSel = _selectedPlan == i;
            final color = plan['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () { setState(() => _selectedPlan = i); HapticFeedback.selectionClick(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSel ? color.withValues(alpha: 0.12) : const Color(0xFF0F0E1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSel ? color : Colors.white.withValues(alpha: 0.06), width: isSel ? 1.4 : 1.0),
                    boxShadow: isSel ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12)] : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (plan['badge'] != null) Text(plan['badge'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center),
                      Text(plan['price'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: isSel ? color : Colors.white54)),
                      Text(plan['period'] as String, style: GoogleFonts.inter(fontSize: 9, color: Colors.white30)),
                      Text(plan['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: isSel ? color : Colors.white38)),
                      if (plan['savings'] != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(plan['savings'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(benefit['icon'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(benefit['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1),
          const SizedBox(height: 2),
          Text(benefit['desc'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38, height: 1.3), maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            const Expanded(flex: 3, child: SizedBox()),
            Expanded(flex: 2, child: Text('Free', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Premium', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandOrange), textAlign: TextAlign.center)),
          ]),
          const SizedBox(height: 10),
          ..._comparison.map((c) => _comparisonRow(c)).toList(),
        ],
      ),
    );
  }

  Widget _comparisonRow(Map<String, dynamic> row) {
    Widget freeVal = row['free'] is bool
        ? Icon(row['free'] == true ? Icons.check_rounded : Icons.close_rounded, color: row['free'] == true ? const Color(0xFF00E5A0) : Colors.white.withValues(alpha: 0.2), size: 14)
        : Text(row['free'] as String, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38), textAlign: TextAlign.center);
    Widget premiumVal = row['premium'] is bool
        ? Icon(row['premium'] == true ? Icons.check_rounded : Icons.close_rounded, color: row['premium'] == true ? const Color(0xFF00E5A0) : Colors.white.withValues(alpha: 0.2), size: 14)
        : Text(row['premium'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.brandOrange), textAlign: TextAlign.center);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Expanded(flex: 3, child: Text(row['feature'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60))),
        Expanded(flex: 2, child: Center(child: freeVal)),
        Expanded(flex: 2, child: Center(child: premiumVal)),
      ]),
    );
  }

  Widget _buildSocialProof() {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      addGlow: true,
      glowColor: AppTheme.brandGold,
      backgroundGradientColors: [AppTheme.brandGold.withValues(alpha: 0.05), Colors.transparent],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _proofStat('12,400+', 'Premium Creators', AppTheme.brandOrange),
              _proofStat('4.9 ★', 'Average Rating', AppTheme.brandGold),
              _proofStat('98%', 'Satisfaction', const Color(0xFF00E5A0)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://api.dicebear.com/7.x/bottts/png?seed=sarah')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('"Anzor Premium transformed how I create AI prompts. The unlimited models alone are worth every penny!"', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60, height: 1.4)),
                    const SizedBox(height: 6),
                    Text('Sarah Jennings • Verified Premium Creator', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.brandOrange)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proofStat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
    ]);
  }

  Widget _buildFaqCard(int index) {
    final faq = _faqs[index];
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
            Row(
              children: [
                Expanded(child: Text(faq['q'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: isOpen ? Colors.white : Colors.white70))),
                Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isOpen ? AppTheme.brandOrange : Colors.white30, size: 20),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 10),
              Text(faq['a'] as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: const Color(0xEA06050C),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_rounded, color: Colors.white30, size: 12),
                const SizedBox(width: 4),
                Text('Secure payment • Cancel anytime', style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
              ]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Center(child: Text('Free Trial', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: AnzorButton(
                      height: 50,
                      onPressed: _purchase,
                      isLoading: _isPurchasing,
                      child: Text('Upgrade Now ✦', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👑', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 24),
                Text('Welcome to Premium!', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                Text('All Premium features are now unlocked.', style: GoogleFonts.inter(fontSize: 14, color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                AnzorCard(
                  padding: const EdgeInsets.all(20),
                  addGlow: true,
                  glowColor: AppTheme.brandOrange,
                  child: Column(children: [
                    const Text('⭐', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text('Premium Badge Unlocked!', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.brandGold)),
                    Text('+200 XP Bonus', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                  ]),
                ),
                const SizedBox(height: 28),
                AnzorButton(
                  height: 50,
                  onPressed: () => Navigator.pop(context),
                  child: Text('Start Exploring', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
