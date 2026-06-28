import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Anzor AI Brand Palette ──────────────────────────────────────────────
  // Deep dark futuristic navy backgrounds
  static const Color bgDeep    = Color(0xFF06050C); // Deepest scaffold bg
  static const Color bgMid     = Color(0xFF101522); // Surface / nav bar
  static const Color bgCard    = Color(0xFF141A2E); // Card fill base

  // Legacy aliases (kept so existing references don't break)
  static const Color darkBackground = bgDeep;
  static const Color darkSurface    = bgMid;
  static const Color darkCardBg     = bgCard;

  static const Color lightBackground = Color(0xFFF0F4FF);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCardBg     = Color(0xFFE4EAF8);

  // ─── Brand Colors ─────────────────────────────────────────────────────────
  static const Color brandOrange  = Color(0xFFFF7A00); // Primary CTA / active
  static const Color brandGold    = Color(0xFFFFC107); // Gradient endpoint
  static const Color electricBlue = Color(0xFF00D9FF); // Accent / secondary glow

  // Legacy aliases
  static const Color neonPurple  = brandOrange;   // was purple — now orange brand
  static const Color neonPink    = Color(0xFFFF4D6A); // kept for error states
  static const Color neonGreen   = Color(0xFF00E5A0); // kept for success states

  // ─── Typography ───────────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFF0F4FF);
  static const Color textSecondaryDark = Color(0xFF7A8BAD);
  static const Color textPrimaryLight  = Color(0xFF0D1B3E);
  static const Color textSecondaryLight= Color(0xFF4A5980);

  // ─── Brand Gradients ──────────────────────────────────────────────────────
  /// Primary CTA gradient — orange → gold (horizontal)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandOrange, brandGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Cinematic accent — orange → electric blue (diagonal)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [brandOrange, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Legacy alias — kept so app_shell FAB doesn't break
  static const LinearGradient purpleBlueGradient = brandGradient;

  /// Deep background gradient
  static const LinearGradient cosmicBackgroundGradient = LinearGradient(
    colors: [bgDeep, Color(0xFF0D1528)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Warm sunset: orange → pink — kept for legacy card usage
  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [brandOrange, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glassmorphism Decoration ─────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double radius = 16.0,
    Color borderColor = const Color(0x17FFFFFF),
    bool addGlow = false,
    Color glowColor = brandOrange,
  }) {
    return BoxDecoration(
      color: const Color(0x0EFFFFFF),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor,
        width: 1.2,
      ),
      boxShadow: [
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          spreadRadius: 0,
          offset: Offset(0, 4),
        ),
        if (addGlow)
          BoxShadow(
            color: glowColor.withOpacity(0.22),
            blurRadius: 24,
            spreadRadius: 2,
          ),
      ],
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        background: bgDeep,
        surface: bgMid,
        primary: brandOrange,
        secondary: electricBlue,
        tertiary: neonPink,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDeep,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: brandOrange),
        actionsIconTheme: IconThemeData(color: brandOrange),
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:  GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimaryDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold,  color: textPrimaryDark),
        displaySmall:  GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold,  color: textPrimaryDark),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold,  color: textPrimaryDark),
        headlineMedium:GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600,  color: textPrimaryDark),
        titleLarge:    GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600,  color: textPrimaryDark),
        bodyLarge:     GoogleFonts.inter(fontSize: 15, color: textPrimaryDark, height: 1.5),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, color: textSecondaryDark, height: 1.5),
        bodySmall:     GoogleFonts.inter(fontSize: 12, color: textSecondaryDark),
        labelLarge:    GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0FFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x17FFFFFF), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x17FFFFFF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brandOrange, width: 1.8),
        ),
        hintStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondaryDark),
        floatingLabelStyle: const TextStyle(color: brandOrange),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgMid,
        selectedItemColor: brandOrange,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x0FFFFFFF),
        selectedColor: brandOrange.withOpacity(0.22),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: textPrimaryDark),
        side: const BorderSide(color: Color(0x17FFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerColor: const Color(0x14FFFFFF),
      splashColor: brandOrange.withOpacity(0.08),
      highlightColor: brandOrange.withOpacity(0.04),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        background: lightBackground,
        surface: lightSurface,
        primary: brandOrange,
        secondary: electricBlue,
        tertiary: neonPink,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: brandOrange),
        actionsIconTheme: IconThemeData(color: brandOrange),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:  GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimaryLight, letterSpacing: -0.5),
        displayMedium: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold,  color: textPrimaryLight),
        displaySmall:  GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold,  color: textPrimaryLight),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold,  color: textPrimaryLight),
        headlineMedium:GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600,  color: textPrimaryLight),
        titleLarge:    GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600,  color: textPrimaryLight),
        bodyLarge:     GoogleFonts.inter(fontSize: 15, color: textPrimaryLight, height: 1.5),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, color: textSecondaryLight, height: 1.5),
        bodySmall:     GoogleFonts.inter(fontSize: 12, color: textSecondaryLight),
        labelLarge:    GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE2F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE2F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brandOrange, width: 1.8),
        ),
        hintStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondaryLight),
        floatingLabelStyle: const TextStyle(color: brandOrange),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: brandOrange,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dividerColor: const Color(0xFFDDE2F0),
      splashColor: brandOrange.withOpacity(0.06),
      highlightColor: brandOrange.withOpacity(0.03),
    );
  }
}
