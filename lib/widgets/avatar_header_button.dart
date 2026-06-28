import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'quick_actions_menu.dart';

class AvatarHeaderButton extends StatefulWidget {
  const AvatarHeaderButton({Key? key}) : super(key: key);

  @override
  State<AvatarHeaderButton> createState() => _AvatarHeaderButtonState();
}

class _AvatarHeaderButtonState extends State<AvatarHeaderButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = getInitials(name);
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
            fontSize: 13,
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
    final hasUnread = appState.hasUnreadNotifications;

    return GestureDetector(
      onTap: () {
        appState.setActiveTab(3); // Navigate to Profile
      },
      onLongPress: () {
        HapticFeedback.vibrate();
        QuickActionsMenu.show(context);
      },
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedScale(
        scale: _isTapped ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse outer glow when there are unread notifications
            if (hasUnread)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 44.0 * _pulseAnimation.value,
                    height: 44.0 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6A00).withOpacity(0.12 * (2.0 - _pulseAnimation.value)),
                    ),
                  );
                },
              ),

            // Base border ring with orange/gold gradient
            Container(
              width: 40.0,
              height: 40.0,
              padding: const EdgeInsets.all(1.8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: hasUnread 
                      ? [const Color(0xFFFF6A00), const Color(0xFFFF007F)] // Red-orange gradient for notification attention
                      : [const Color(0xFFFF6A00), const Color(0xFFFFC107)], // Standard orange-gold gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasUnread ? const Color(0xFFFF6A00) : const Color(0xFFFF6A00)).withOpacity(0.25),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF06050C),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: user.avatar.isNotEmpty && (user.avatar.startsWith('http') || user.avatar.startsWith('https'))
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Hero(
                            tag: 'user_avatar_hero',
                            child: Image.network(
                              user.avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => _buildInitialsAvatar(user.username),
                            ),
                          ),
                        )
                      : _buildInitialsAvatar(user.username),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
