import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnzorBrandText extends StatelessWidget {
  final double fontSize;

  const AnzorBrandText({
    super.key,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = GoogleFonts.spaceGrotesk(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800, // Bold weight (800)
        letterSpacing: fontSize * -0.01, // Tight spacing (-1%)
        fontStyle: FontStyle.normal,
        fontFamilyFallback: const [
          'Outfit',
          'Sora',
          'Inter',
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // "Anzor" - Pure White, Matte Finish, Soft White Glow & Grey Depth Shadow
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Shadow layer for "Anzor"
            Text(
              'Anzor',
              style: baseTextStyle.copyWith(
                color: Colors.transparent,
                shadows: [
                  // Soft white glow (12% opacity)
                  Shadow(
                    color: Colors.white.withOpacity(0.12),
                    blurRadius: 8.0,
                    offset: Offset.zero,
                  ),
                  // Subtle grey shadow for depth
                  Shadow(
                    color: const Color(0xFF1E2230).withOpacity(0.35),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // Matte white text layer
            Text(
              'Anzor',
              style: baseTextStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        // Horizontal spacing scaled with font size
        SizedBox(width: fontSize * 0.22),
        
        // "AI" - Premium Orange Gradient, Glossy Metallic Finish, Soft Orange Glow, 3D Depth Shadow
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Shadow/Glow layer for "AI"
            Text(
              'AI',
              style: baseTextStyle.copyWith(
                color: Colors.transparent,
                shadows: [
                  // Soft orange outer glow
                  Shadow(
                    color: const Color(0xFFFF6A00).withOpacity(0.35),
                    blurRadius: 10.0,
                    offset: Offset.zero,
                  ),
                  // Depth shadow: 0 8px 24px rgba(255, 140, 0, 0.25)
                  Shadow(
                    color: const Color(0xFFFF6A00).withOpacity(0.25),
                    blurRadius: 24.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            // Metallic gradient text on top
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFF6A00), // #FF6A00
                  Color(0xFFFF9800), // #FF9800
                  Color(0xFFFFC107), // #FFC107
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                'AI',
                style: baseTextStyle.copyWith(
                  color: Colors.white, // Critical for ShaderMask
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
