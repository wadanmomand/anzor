import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../views/history_view.dart';
import '../views/discover_view.dart';
import '../views/notification_center_view.dart';
import '../views/login_view.dart';
import 'glass_widgets.dart';

class QuickActionsMenu extends StatelessWidget {
  const QuickActionsMenu({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Quick Actions barrier',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const QuickActionsMenu();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeIn),
        );
        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  static void _showSettingsDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: const Color(0xFF131024),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppTheme.brandOrange),
                  title: const Text('Roman Urdu Language', style: TextStyle(color: Colors.white70)),
                  trailing: Switch(
                    value: appState.locale == 'ur_roman',
                    activeColor: AppTheme.brandOrange,
                    onChanged: (val) {
                      appState.toggleLocale();
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded, color: AppTheme.brandOrange),
                  title: const Text('Dark Theme', style: TextStyle(color: Colors.white70)),
                  trailing: Switch(
                    value: appState.themeMode == ThemeMode.dark,
                    activeColor: AppTheme.brandOrange,
                    onChanged: (val) {
                      appState.setThemeModeString(val ? 'dark' : 'light');
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            actions: [
              AnzorActionButton(
                icon: Icons.close_rounded,
                label: 'Close',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showProDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: const Color(0xFF131024),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700)),
                SizedBox(width: 8),
                Text('Anzor Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Gain access to unlimited prompt generations, ultra-detailed reverse image scanning, and premium badges!\n\nJust \$9.99/month.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            actions: [
              AnzorActionButton(
                icon: Icons.close_rounded,
                label: 'Close',
                onTap: () => Navigator.pop(context),
              ),
              AnzorActionButton(
                icon: Icons.workspace_premium_rounded,
                label: 'Upgrade',
                variant: AnzorActionButtonVariant.primary,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for upgrading to Anzor Pro!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  static Widget _buildUserAvatar(AppState appState, {double size = 48.0}) {
    final user = appState.currentUserProfile;
    final initials = _getInitials(user.username);
    final hasAvatar = user.avatar.isNotEmpty && (user.avatar.startsWith('http') || user.avatar.startsWith('https'));

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF131024),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: hasAvatar
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Hero(
                    tag: 'user_avatar_hero',
                    child: Image.network(
                      user.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => _buildInitialsContainer(initials),
                    ),
                  ),
                )
              : _buildInitialsContainer(initials),
        ),
      ),
    );
  }

  static Widget _buildInitialsContainer(String initials) {
    return Hero(
      tag: 'user_avatar_hero',
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6A00), Color(0xFFFF9800), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUserProfile;
    final isAdmin = appState.isAdmin;

    final List<_QuickActionItemData> actions = [
      _QuickActionItemData(
        icon: Icons.person_rounded,
        title: 'Profile',
        subtitle: 'View your space',
        color: const Color(0xFFC084FC),
        onTap: () {
          appState.setActiveTab(3);
          Navigator.pop(context);
        },
      ),
      _QuickActionItemData(
        icon: Icons.auto_awesome_rounded,
        title: 'Create Prompt',
        subtitle: 'AI Studio Hub',
        color: const Color(0xFFFF8A00),
        onTap: () {
          appState.setActiveTab(1);
          Navigator.pop(context);
        },
      ),
      _QuickActionItemData(
        icon: Icons.bookmark_rounded,
        title: 'Saved',
        subtitle: 'Collections tab',
        color: const Color(0xFF38BDF8),
        onTap: () {
          appState.setActiveTab(3); // Profile view shows collections
          Navigator.pop(context);
        },
      ),
      _QuickActionItemData(
        icon: Icons.history_rounded,
        title: 'History',
        subtitle: 'Generation logs',
        color: const Color(0xFF94A3B8),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryView()),
          );
        },
      ),
      _QuickActionItemData(
        icon: Icons.notifications_rounded,
        title: 'Notifications',
        subtitle: 'Unread alerts',
        color: const Color(0xFFF1F5F9),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationCenterView()),
          );
        },
      ),
      _QuickActionItemData(
        icon: Icons.settings_rounded,
        title: 'Settings',
        subtitle: 'App preferences',
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.pop(context);
          _showSettingsDialog(context, appState);
        },
      ),
      _QuickActionItemData(
        icon: Icons.workspace_premium_rounded,
        title: 'Anzor Pro',
        subtitle: 'Unlock features',
        color: const Color(0xFFFFD700),
        onTap: () {
          Navigator.pop(context);
          _showProDialog(context);
        },
      ),
      _QuickActionItemData(
        icon: Icons.help_outline_rounded,
        title: 'Help',
        subtitle: 'Tips and tutorials',
        color: const Color(0xFFFB923C),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Help Center docs are loading in background...'),
              backgroundColor: Color(0xFF131024),
            ),
          );
        },
      ),
      _QuickActionItemData(
        icon: Icons.logout_rounded,
        title: 'Logout',
        subtitle: 'Exit account',
        color: const Color(0xFFEF4444),
        onTap: () {
          Navigator.pop(context);
          appState.logout();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        },
      ),
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          constraints: const BoxConstraints(maxWidth: 420.0),
          decoration: BoxDecoration(
            color: const Color(0xCF0B0914), // Premium translucent dark purple/black
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 36.0,
                spreadRadius: 4.0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  Row(
                    children: [
                      _buildUserAvatar(appState),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              isAdmin ? 'System Admin' : 'Creator Member',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  const Divider(
                    color: Color(0xFF1E1B30),
                    height: 1.0,
                  ),
                  const SizedBox(height: 24.0),

                  // Actions grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final item = actions[index];
                      return _QuickActionCard(item: item);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _QuickActionItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatefulWidget {
  final _QuickActionItemData item;

  const _QuickActionCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered 
                ? const Color(0xFFFF6A00).withOpacity(0.08) 
                : const Color(0xFF131024).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFFFF6A00).withOpacity(0.4) 
                  : Colors.white.withOpacity(0.04),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.item.color.withOpacity(0.08),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 24.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  widget.item.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8.5,
                    color: Color(0xFF94A3B8),
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
