import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'email_verification_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isCheckingUsername = false;
  bool _usernameAvailable = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _isSubmitting = false;

  final List<String> _interests = [
    'ChatGPT', 'Gemini', 'Claude', 'Image Generation', 'Video Generation', 'Coding', 'Marketing', 'Business', 'Photography', '3D Art'
  ];
  final Set<String> _selectedInterests = {};
  String _selectedLang = 'English';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _checkUsername(String val) async {
    if (val.isEmpty) { setState(() => _usernameAvailable = false); return; }
    setState(() => _isCheckingUsername = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isCheckingUsername = false;
      _usernameAvailable = val.toLowerCase() != 'admin' && val.toLowerCase() != 'anzor';
    });
  }

  double _getPasswordStrength() {
    String p = _passCtrl.text;
    if (p.isEmpty) return 0.0;
    double score = 0.0;
    if (p.length >= 8) score += 0.2;
    if (p.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (p.contains(RegExp(r'[a-z]'))) score += 0.2;
    if (p.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (p.contains(RegExp(r'[!@#\$&*~]'))) score += 0.2;
    return score;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_agreeTerms || !_agreePrivacy) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    setState(() => _isSubmitting = false);
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailVerificationView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final strength = _getPasswordStrength();

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient Glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Stack(children: [
              Positioned(top: -80, right: -60, child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.08 + _glowController.value * 0.04), Colors.transparent])))),
              Positioned(bottom: 120, left: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent])))),
            ]),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 30)),

              // Welcome Hero
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  Text('Create Your Account', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Join thousands of AI creators building the future with Anzor.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.45))),
                ]),
              )),

              // Forms & Credentials
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnzorInput(controller: _nameCtrl, hintText: 'Full Name', prefixIcon: Icons.person_outline_rounded),
                        const SizedBox(height: 12),
                        // Username field with availability check
                        _buildUsernameField(),
                        const SizedBox(height: 12),
                        AnzorInput(controller: _emailCtrl, hintText: 'Email Address', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        AnzorInput(
                          controller: _passCtrl,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: GestureDetector(onTap: () => setState(() => _obscurePass = !_obscurePass), child: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18)),
                        ),
                        if (_passCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildPasswordStrengthBar(strength),
                        ],
                        const SizedBox(height: 12),
                        AnzorInput(
                          controller: _confirmPassCtrl,
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          suffixIcon: GestureDetector(onTap: () => setState(() => _obscureConfirm = !_obscureConfirm), child: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18)),
                          validator: (val) {
                            if (val != _passCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )),

              // Preferences Section
              _sectionHeader('⚙️ CHOOSE PREFERENCES'),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preferred Language', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['English', 'اردو', 'العربية'].map((l) => GestureDetector(
                          onTap: () => setState(() => _selectedLang = l),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(color: _selectedLang == l ? AppTheme.brandOrange.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: _selectedLang == l ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.08))),
                            child: Text(l, style: GoogleFonts.inter(fontSize: 12, color: _selectedLang == l ? AppTheme.brandOrange : Colors.white54)),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Choose AI Interests', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _interests.map((i) {
                          final isSel = _selectedInterests.contains(i);
                          return GestureDetector(
                            onTap: () {
                              setState(() { isSel ? _selectedInterests.remove(i) : _selectedInterests.add(i); });
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.electricBlue.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? AppTheme.electricBlue : Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Text(i, style: GoogleFonts.inter(fontSize: 11.5, color: isSel ? AppTheme.electricBlue : Colors.white54)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )),

              // Terms & Privacy Agree
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(children: [
                  _agreementRow('I agree to the Terms of Service', _agreeTerms, (v) => setState(() => _agreeTerms = v ?? false)),
                  _agreementRow('I agree to the Privacy Policy', _agreePrivacy, (v) => setState(() => _agreePrivacy = v ?? false)),
                ]),
              )),

              SliverToBoxAdapter(child: const SizedBox(height: 120)),
            ],
          ),

          // Bottom Bar & Sign Up Button
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
                        onPressed: (_agreeTerms && _agreePrivacy) ? _submit : null,
                        isLoading: _isSubmitting,
                        child: Text('Create Account', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Already have an account? Sign In', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange, fontWeight: FontWeight.w600)),
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

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnzorInput(
          controller: _usernameCtrl,
          hintText: 'Username',
          prefixIcon: Icons.alternate_email_rounded,
          onChanged: _checkUsername,
          suffixIcon: _isCheckingUsername
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.brandOrange)))
              : _usernameCtrl.text.isEmpty
                  ? null
                  : Icon(_usernameAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _usernameAvailable ? const Color(0xFF00E5A0) : const Color(0xFFFF4D6A), size: 18),
        ),
        if (_usernameCtrl.text.isNotEmpty && !_isCheckingUsername) ...[
          const SizedBox(height: 4),
          Text(
            _usernameAvailable ? 'Username is available' : 'Username is already taken',
            style: GoogleFonts.inter(fontSize: 10.5, color: _usernameAvailable ? const Color(0xFF00E5A0) : const Color(0xFFFF4D6A)),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthBar(double strength) {
    Color color = strength >= 0.8 ? const Color(0xFF00E5A0) : strength >= 0.4 ? AppTheme.brandOrange : const Color(0xFFFF4D6A);
    String text = strength >= 0.8 ? 'Strong' : strength >= 0.4 ? 'Medium' : 'Weak';
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: strength, minHeight: 4, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(color)),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, color: color, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _agreementRow(String label, bool val, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: val, onChanged: onChanged, activeColor: AppTheme.brandOrange, side: const BorderSide(color: Colors.white30)),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54))),
      ],
    );
  }

  SliverToBoxAdapter _sectionHeader(String label) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4))));
}
