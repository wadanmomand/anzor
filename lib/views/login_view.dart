import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../localization/localization.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'dart:async';
import 'signup_view.dart';
import 'forgot_password_view.dart';
import 'app_shell.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _glowController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;
  int _messageIndex = 0;
  late Timer _messageTimer;

  final List<String> _messages = [
    'Welcome back! Let\'s create something amazing today.',
    'Great creators return every day. Ready to build?',
    'Your AI journey continues. Let\'s make it legendary.',
    'Trending prompts are waiting for you.',
  ];

  final List<Map<String, dynamic>> _socialProviders = [
    {'icon': Icons.g_mobiledata_rounded, 'label': 'Google', 'color': const Color(0xFFDB4437)},
    {'icon': Icons.apple_rounded, 'label': 'Apple', 'color': Colors.white},
    {'icon': Icons.code_rounded, 'label': 'GitHub', 'color': const Color(0xFF6E40C9)},
    {'icon': Icons.window_rounded, 'label': 'Microsoft', 'color': const Color(0xFF00A4EF)},
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _messageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _glowController.dispose();
    _messageTimer.cancel();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => Stack(children: [
              Positioned(
                top: -100 + math.sin(_bgController.value * math.pi * 2) * 30,
                right: -100,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.brandOrange.withValues(alpha: 0.12 + _glowController.value * 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100 + math.cos(_bgController.value * math.pi * 2) * 20,
                left: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.electricBlue.withValues(alpha: 0.07 + _glowController.value * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.brandOrange.withValues(alpha: 0.12),
                          border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandOrange.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(child: Text('🤖', style: TextStyle(fontSize: 34))),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue your AI creator journey.',
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // AI welcome prompt
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: AnzorCard(
                          key: ValueKey(_messageIndex),
                          padding: const EdgeInsets.all(14),
                          addGlow: true,
                          glowColor: AppTheme.brandOrange,
                          backgroundGradientColors: [AppTheme.brandOrange.withValues(alpha: 0.07), Colors.transparent],
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _messages[_messageIndex],
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Inputs
                      AnzorInput(
                        controller: _emailController,
                        hintText: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!val.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AnzorInput(
                        controller: _passController,
                        hintText: 'Enter password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.white38,
                            size: 18,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _rememberMe ? AppTheme.brandOrange : Colors.transparent,
                                    border: Border.all(color: _rememberMe ? AppTheme.brandOrange : Colors.white30),
                                  ),
                                  child: _rememberMe ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 8),
                                Text('Remember me', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordView())),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Sign In Button
                      AnzorButton(
                        isLoading: appState.isLoading,
                        gradient: AppTheme.brandGradient,
                        glowColor: AppTheme.brandOrange,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            await appState.loginUser(
                              _emailController.text,
                              _passController.text,
                              false,
                            );
                            if (mounted && appState.isAuthenticated) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const AppShell()),
                              );
                            }
                          }
                        },
                        child: Text(
                          localizations.translate('Sign In'),
                          style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tooltip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.electricBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.electricBlue.withValues(alpha: 0.25), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.electricBlue, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tip: Login with email "admin@anzor.ai" to unlock the Admin dashboard.',
                                style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.electricBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.06))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or continue with', style: GoogleFonts.inter(fontSize: 11, color: Colors.white30)),
                          ),
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.06))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Social Login Grid
                      Row(
                        children: _socialProviders.map((p) => Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (p['label'] == 'Google') {
                                await appState.loginGoogle();
                                if (mounted && appState.isAuthenticated) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AppShell()),
                                  );
                                }
                              } else {
                                HapticFeedback.selectionClick();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: _socialProviders.last == p ? 0 : 8),
                              height: 44,
                              decoration: BoxDecoration(
                                color: (p['color'] as Color).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: (p['color'] as Color).withValues(alpha: 0.2)),
                              ),
                              child: Center(child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 20)),
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 14),
                      // Guest Button
                      AnzorButton(
                        onPressed: () async {
                          await appState.loginGuest();
                          if (mounted && appState.isAuthenticated) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AppShell()),
                            );
                          }
                        },
                        gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.04), Colors.white.withValues(alpha: 0.04)]),
                        radius: 16,
                        height: 44,
                        child: Text(
                          localizations.translate('Guest Mode'),
                          style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Don't have an account?  ", style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
                            TextSpan(text: 'Create Account', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.brandOrange, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
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
}
