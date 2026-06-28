import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'home_social_feed_view.dart';
import 'prompt_generator_view.dart';
import 'following_feed_view.dart';
import 'profile_view.dart';
import 'notification_center_view.dart';
import 'publish_prompt_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Custom Notification Animation Controller
  late AnimationController _notificationController;
  late Animation<Offset> _notificationOffset;
  NotificationItem? _activeNotification;
  int _lastNotificationCount = 0;

  final List<Widget> _views = [
    const HomeSocialFeedView(),
    const PromptGeneratorView(),
    const FollowingFeedView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _notificationOffset = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.easeOutBack,
    ));

    // Listen to changes in notifications list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      _lastNotificationCount = appState.notifications.length;
      
      appState.addListener(_notificationListener);
    });
  }

  @override
  void dispose() {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.removeListener(_notificationListener);
    } catch (_) {}
    _notificationController.dispose();
    super.dispose();
  }

  void _notificationListener() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    
    // If a new notification is added, slide it down
    if (appState.notifications.length > _lastNotificationCount) {
      _lastNotificationCount = appState.notifications.length;
      final newNotif = appState.notifications.first;
      
      setState(() {
        _activeNotification = newNotif;
      });

      _notificationController.forward();
      
      // Auto dismiss after 4 seconds
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          _notificationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep, // Dark Navy (#06050C)
      body: Stack(
        children: [
          // Current View Body
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.of(context).padding.bottom,
              ),
              child: _views[appState.activeTab],
            ),
          ),

          // Floating Glass Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xE8100E1E),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                      _buildNavItem(1, Icons.add_box_rounded, Icons.add_box_outlined, 'Create'),
                      _buildNavItem(2, Icons.people_rounded, Icons.people_outlined, 'Following'),
                      _buildNavItem(3, Icons.person_rounded, Icons.person_outlined, 'Profile', showBadge: appState.hasUnreadNotifications),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sliding Push Notification Banner overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _notificationOffset,
              child: _activeNotification == null
                  ? const SizedBox.shrink()
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _notificationController.reverse();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationCenterView()),
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderColor: AppTheme.brandOrange.withOpacity(0.4),
                          addGlow: true,
                          glowColor: AppTheme.brandOrange,
                          radius: 14.0,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.pinkPurpleGradient,
                                ),
                                child: const Icon(
                                  Icons.bolt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _activeNotification!.senderName,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _activeNotification!.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _notificationController.reverse(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {bool showBadge = false}) {
    final appState = Provider.of<AppState>(context);
    final isSelected = appState.activeTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        appState.setActiveTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 0.94,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? AppTheme.brandOrange : AppTheme.textSecondaryDark,
                  size: 22,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: AppTheme.brandOrange.withOpacity(0.65),
                            blurRadius: 10.0,
                          ),
                          Shadow(
                            color: AppTheme.brandOrange.withOpacity(0.35),
                            blurRadius: 20.0,
                          ),
                        ]
                      : null,
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.brandOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.brandOrange : AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
