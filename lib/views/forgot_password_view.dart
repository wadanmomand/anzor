import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSent = false;

  final List<Map<String, dynamic>> _recoveryTips = [
    {'icon': Icons.mail_outline_rounded, 'title': 'Check Spam Folder', 'desc': 'Sometimes verification emails land in spam.'},
    {'icon': Icons.spellcheck_rounded, 'title': 'Double Check Spelling', 'desc': 'Ensure the email matches your account email.'},
    {'icon': Icons.timer_rounded, 'title': 'Resend Timer', 'desc': 'You can request a new link after 60 seconds.'},
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (_emailController.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() {
      _isSubmitting = false;
      _isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    if (_isSent) return _buildSentSuccess();

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Stack(children: [
              Positioned(top: -80, right: -60, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.08 + _glowController.value * 0.04), Colors.transparent])))),
              Positioned(bottom: 200, left: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.05), Colors.transparent])))),
            ]),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 30)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                  Text('Forgot Password?', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('No worries. Enter your email and we\'ll send a recovery link.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.45))),
                ]),
              )),

              // Email input card
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnzorInput(
                        controller: _emailController,
                        hintText: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              )),

              // Help cards / recovery tips
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('RESET TIPS & HELP', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final t = _recoveryTips[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnzorCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Icon(t['icon'] as IconData, color: AppTheme.brandOrange, size: 18),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(t['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text(t['desc'] as String, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
                            ])),
                          ]),
                        ),
                      );
                    },
                    childCount: _recoveryTips.length,
                  ),
                ),
              ),
            ],
          ),

          // Bottom sticky action bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                  decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnzorButton(
                        height: 50,
                        onPressed: _sendLink,
                        isLoading: _isSubmitting,
                        child: Text('Send Reset Link ✦', style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Back to Login', style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white54, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentSuccess() {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.3), Colors.transparent])),
                  child: const Icon(Icons.mark_email_read_outlined, color: AppTheme.brandOrange, size: 50),
                ),
                const SizedBox(height: 24),
                Text('Recovery Email Sent!', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                Text('We have sent a password reset link to your email. Please check your inbox.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                AnzorCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text('Didn\'t receive the email?', style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(color: AppTheme.brandOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3))),
                              child: Center(child: Text('Resend (60s)', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandOrange))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSent = false),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                              child: Center(child: Text('Change Email', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 28),
                AnzorButton(
                  height: 50,
                  onPressed: () { Navigator.pop(context); },
                  child: Text('Return to Login', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
