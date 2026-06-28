import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/theme.dart';
import 'views/anzor_splash_view.dart';
import 'widgets/anzor_brand_text.dart';

void main() {
  // Ensure Flutter engine binds properly before initialization
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force edge-to-edge layout to allow background drawing behind status/navigation bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read state changes reactively
    final appState = Provider.of<AppState>(context);

    // Parse active locale
    final brightness = appState.themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (appState.themeMode == ThemeMode.light ? Brightness.light : Brightness.dark);
    final isDark = brightness == Brightness.dark;

    Locale activeLocale = const Locale('en');
    if (appState.locale == 'ur_roman') {
      activeLocale = const Locale('ur', 'PK');
    }

    return MaterialApp(
      title: 'Anzor AI',
      debugShowCheckedModeBanner: false,
      
      // Theme settings
      themeMode: appState.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Locale settings
      locale: activeLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ur', 'PK'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: child!,
        );
      },

      // Home routing
      home: const AnzorSplashView(),
    );
  }
}

// Splash loading page shown during local document database load
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPurple.withOpacity(0.25),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/anzor_ai_transparent.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AnzorBrandText(fontSize: 18),
            const Text(
              'Creative Studio Hub',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
