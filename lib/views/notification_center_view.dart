import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'creator_profile_view.dart';

class NotificationCenterView extends StatefulWidget {
  const NotificationCenterView({super.key});

  @override
  State<NotificationCenterView> createState() => _NotificationCenterViewState();
}

class _NotificationCenterViewState extends State<NotificationCenterView> {
  String _activeFilter = 'All';

  final List<String> _filters = [
    'All', 'Unread', 'Likes', 'Comments', 'Followers', 'Mentions', 'Achievements', 'System'
  ];

  @override
  void initState() {
    super.initState();
    // Mark all read on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.hasUnreadNotifications) {
        appState.markNotificationsRead();
      }
    });
  }

  // Group notifications into Today, Yesterday, This Week, Earlier
  Map<String, List<NotificationItem>> _groupNotifications(List<NotificationItem> list) {
    final Map<String, List<NotificationItem>> groups = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    final now = DateTime.now();
    for (final item in list) {
      final text = item.timestamp.toLowerCase();
      if (text.contains('m ago') || text.contains('h ago') || text.contains('today') || text.contains('just now')) {
        groups['Today']!.add(item);
      } else if (text.contains('yesterday') || text.contains('1d ago')) {
        groups['Yesterday']!.add(item);
      } else if (text.contains('days ago') || text.contains('2d ago') || text.contains('3d ago') || text.contains('4d ago') || text.contains('5d ago')) {
        groups['This Week']!.add(item);
      } else {
        groups['Earlier']!.add(item);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    // Filter notifications list
    List<NotificationItem> filteredList = appState.notifications;
    if (_activeFilter != 'All') {
      if (_activeFilter == 'Unread') {
        filteredList = filteredList.where((n) => !n.read).toList();
      } else if (_activeFilter == 'Likes') {
        filteredList = filteredList.where((n) => n.type == 'like').toList();
      } else if (_activeFilter == 'Comments') {
        filteredList = filteredList.where((n) => n.type == 'comment').toList();
      } else if (_activeFilter == 'Followers') {
        filteredList = filteredList.where((n) => n.type == 'follow').toList();
      } else if (_activeFilter == 'Mentions') {
        filteredList = filteredList.where((n) => n.message.toLowerCase().contains('@')).toList();
      } else if (_activeFilter == 'Achievements') {
        filteredList = filteredList.where((n) => n.type == 'achievement' || n.message.toLowerCase().contains('unlocked')).toList();
      } else if (_activeFilter == 'System') {
        filteredList = filteredList.where((n) => n.type == 'system' || n.senderName.toLowerCase().contains('anzor')).toList();
      }
    }

    final grouped = _groupNotifications(filteredList);

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60, left: -60,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          // Scrollable Timeline
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top padding spacer
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _buildEmptyState(),
                  ),
                )
              else ...[
                // List grouped notifications
                ...grouped.entries.map((entry) {
                  final groupTitle = entry.key;
                  final items = entry.value;
                  if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                            child: Text(
                              groupTitle.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppTheme.brandOrange,
                              ),
                            ),
                          );
                        }

                        final item = items[index - 1];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            ),
                            onDismissed: (_) {
                              // Perform delete in AppState if available or simulate dismiss
                              setState(() {
                                appState.notifications.removeWhere((n) => n.id == item.id);
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: _buildNotificationCard(item, appState),
                          ),
                        );
                      },
                      childCount: items.length + 1,
                    ),
                  );
                }).toList(),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          ),

          // Frosted Glass Pinned Header Block
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildFrostedHeader(topPad, appState),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Frosted Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFrostedHeader(double topPad, AppState appState) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD206050C),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white,
                        ),
                      ),
                      Text(
                        'Stay updated with your AI community.',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (appState.notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        appState.markNotificationsRead();
                        HapticFeedback.mediumImpact();
                      },
                      icon: const Icon(Icons.done_all_rounded, size: 15, color: AppTheme.brandOrange),
                      label: Text(
                        'Mark all read',
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandOrange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Smart Filters scrollbar
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSel = _activeFilter == filter;
                    return AnzorChip(
                      label: filter,
                      isSelected: isSel,
                      onTap: () {
                        setState(() {
                          _activeFilter = filter;
                        });
                        HapticFeedback.selectionClick();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notification Premium Card Build
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNotificationCard(NotificationItem item, AppState appState) {
    IconData typeIcon;
    Color iconColor;
    Color glowColor;

    switch (item.type) {
      case 'follow':
        typeIcon = Icons.person_add_rounded;
        iconColor = AppTheme.electricBlue;
        glowColor = AppTheme.electricBlue;
        break;
      case 'like':
        typeIcon = Icons.favorite_rounded;
        iconColor = AppTheme.neonPink;
        glowColor = AppTheme.neonPink;
        break;
      case 'comment':
        typeIcon = Icons.chat_bubble_rounded;
        iconColor = AppTheme.neonPurple;
        glowColor = AppTheme.neonPurple;
        break;
      case 'save':
        typeIcon = Icons.bookmark_rounded;
        iconColor = const Color(0xFF00FF7F);
        glowColor = const Color(0xFF00FF7F);
        break;
      default:
        typeIcon = Icons.star_rounded;
        iconColor = AppTheme.brandOrange;
        glowColor = AppTheme.brandOrange;
    }

    return AnzorCard(
      padding: const EdgeInsets.all(12),
      borderColor: item.read ? const Color(0x1BFFFFFF) : iconColor.withValues(alpha: 0.3),
      addGlow: !item.read,
      glowColor: glowColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator avatar with overlaid icon type badge
          Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreatorProfileView(username: item.senderName)),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(item.senderAvatar),
                  backgroundColor: const Color(0xFF131024),
                ),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF131024),
                  ),
                  child: Icon(typeIcon, size: 8, color: iconColor),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Content body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                    children: [
                      TextSpan(
                        text: item.senderName,
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: item.message,
                        style: GoogleFonts.inter(color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.timestamp,
                      style: GoogleFonts.inter(
                        fontSize: 9.5, color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    if (!item.read)
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor),
                      ),
                  ],
                ),
                if (item.type == 'follow') ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 28,
                    child: AnzorButton(
                      onPressed: () {
                        appState.toggleFollow(item.senderName);
                        HapticFeedback.mediumImpact();
                      },
                      radius: 8,
                      gradient: AppTheme.brandGradient,
                      glowColor: AppTheme.brandOrange,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Follow Back',
                          style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty State Build
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AnzorCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandOrange.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: AppTheme.brandOrange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'re all caught up!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When other creators follow you, interact, or publish items you\'ll get notifications immediately.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5, color: Colors.white.withValues(alpha: 0.4), height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
