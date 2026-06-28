import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'success_completion_view.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});
  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocuses = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  int _secondsLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() async {
    for (int i = 60; i >= 0; i--) {
      if (!mounted) return;
      setState(() { _secondsLeft = i; });
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => _canResend = true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    for (var f in _otpFocuses) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int idx, String val) {
    if (val.length == 1 && idx < 5) {
      _otpFocuses[idx + 1].requestFocus();
    } else if (val.isEmpty && idx > 0) {
      _otpFocuses[idx - 1].requestFocus();
    }

    // Check if OTP is fully entered
    String otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length == 6) {
      _verify(otp);
    }
  }

  Future<void> _verify(String otp) async {
    HapticFeedback.mediumImpact();
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() => _isVerifying = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessCompletionView(
            event: 'Email Verified',
            title: 'Account Verified!',
            desc: 'Your email has been successfully verified. Welcome to Anzor.',
            details: {
              'Email': 'user***@gmail.com',
              'Action': 'Registration Complete',
              'Status': 'Success',
              'Date': 'June 28, 2026',
            },
            rewardXp: 150,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

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
                  Text('Verify Your Email', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('We have sent a verification code to user***@gmail.com', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.45))),
                ]),
              )),

              // Code Verification OTP Fields
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) => SizedBox(
                          width: 44,
                          child: TextField(
                            controller: _otpCtrls[i],
                            focusNode: _otpFocuses[i],
                            style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (v) => _onOtpChanged(i, v),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.03),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.brandOrange, width: 1.5)),
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 20),
                      if (_isVerifying)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.brandOrange)))
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white30, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _canResend ? 'You can resend the code now' : 'Resend code in $_secondsLeft seconds',
                              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white30),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )),

              // Resend / Help options
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _helpActionRow('Open Email App', Icons.mail_outline_rounded, () {}),
                    _divider(),
                    _helpActionRow('Resend Verification Email', Icons.refresh_rounded, _canResend ? () {
                      setState(() { _canResend = false; _startTimer(); });
                    } : null),
                    _divider(),
                    _helpActionRow('Change Email Address', Icons.edit_outlined, () => Navigator.pop(context)),
                  ]),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _helpActionRow(String label, IconData icon, VoidCallback? onTap) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: active ? AppTheme.brandOrange : Colors.white24, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: active ? Colors.white.withValues(alpha: 0.75) : Colors.white24))),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.1), size: 18),
        ]),
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 8), color: Colors.white.withValues(alpha: 0.04));
}
