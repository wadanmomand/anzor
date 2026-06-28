import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/anzor_brand_text.dart';
import 'app_shell.dart';
import 'login_view.dart';

class AnzorSplashView extends StatefulWidget {
  const AnzorSplashView({super.key});

  @override
  State<AnzorSplashView> createState() => _AnzorSplashViewState();
}

class _AnzorSplashViewState extends State<AnzorSplashView> {
  @override
  void initState() {
    super.initState();
    _startTransitionTimer();
  }

  Future<void> _startTransitionTimer() async {
    // Show splash for a minimum of 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Guard in case app state initialization is still taking longer
    while (appState.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => appState.isAuthenticated ? const AppShell() : const LoginView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep, // Deep dark background (#06050C)
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Empty space to push logo down
              const SizedBox(height: 40),
              
              // Centered logo & brand strings
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing logo container
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow layer (behind)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandOrange.withOpacity(0.55),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: AppTheme.electricBlue.withOpacity(0.35),
                              blurRadius: 80,
                              spreadRadius: 14,
                            ),
                          ],
                        ),
                      ),
                      // Logo image — no clipping at all
                      Image.asset(
                        'assets/app_logo.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, _, __) => const Icon(
                          Icons.bolt,
                          color: Color(0xFFFF8A00),
                          size: 80,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Brand Name
                  const AnzorBrandText(fontSize: 34),
                  const SizedBox(height: 12),
                  
                  // Slogan
                  Text(
                    'Create. Share. Inspire.',
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Progress indicator at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFFF6B00).withOpacity(0.8), // Soft amber/orange accent
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
