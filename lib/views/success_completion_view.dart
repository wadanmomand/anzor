import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class SuccessCompletionView extends StatelessWidget {
  final String event;
  final String title;
  final String desc;
  final Map<String, String> details;
  final int? rewardXp;
  final String? badgeEarned;

  const SuccessCompletionView({
    super.key,
    required this.event,
    required this.title,
    required this.desc,
    required this.details,
    this.rewardXp,
    this.badgeEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Dynamic gradient background ambient
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.brandOrange.withValues(alpha: 0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -50, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.electricBlue.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sparkle success emblem
                    _buildAnimatedEmblem(),
                    const SizedBox(height: 24),

                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white.withValues(alpha: 0.5), height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Event details summary card
                    _buildSummaryCard(),
                    const SizedBox(height: 20),

                    // Rewards section
                    if (rewardXp != null || badgeEarned != null) ...[
                      _buildRewardSection(),
                      const SizedBox(height: 20),
                    ],

                    // Next actions recommendation
                    _buildRecommendations(),
                    const SizedBox(height: 32),

                    // Return Button
                    AnzorButton(
                      height: 50,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: Text('Continue', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmblem() {
    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.brandOrange.withValues(alpha: 0.12),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandOrange.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(child: Text('🎉', style: TextStyle(fontSize: 48))),
    );
  }

  Widget _buildSummaryCard() {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: details.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            SizedBox(width: 100, child: Text(e.key, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38))),
            Expanded(child: Text(e.value, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white70), textAlign: Alignment.centerRight == Alignment.centerRight ? TextAlign.right : TextAlign.left)),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildRewardSection() {
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      addGlow: true,
      glowColor: AppTheme.brandGold,
      backgroundGradientColors: [AppTheme.brandGold.withValues(alpha: 0.05), Colors.transparent],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (rewardXp != null)
            Column(children: [
              Text('+$rewardXp XP', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.brandGold)),
              Text('XP Bonus Earned', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
            ]),
          if (badgeEarned != null)
            Column(children: [
              const Text('👑', style: TextStyle(fontSize: 18)),
              Text(badgeEarned!, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('Badge Unlocked', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
            ]),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('AI RECOMMENDS NEXT', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 16),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Another Prompt', style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Keep your momentum going! Try different templates.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.25), size: 14),
          ]),
        ),
      ],
    );
  }
}
