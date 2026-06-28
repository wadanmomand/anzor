import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../localization/localization.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'admin_view.dart';
import 'creator_profile_view.dart';
import 'settings_view.dart';
import 'saved_prompts_view.dart';
import 'followers_following_view.dart';
import 'edit_profile_view.dart';
import 'creator_analytics_view.dart';
import '../widgets/creator_level_badge.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedGridTab = 0; // 0: My Creations, 1: Saved, 2: Liked

  Widget _buildPromptImage(String imgPath, double height, double width) {
    if (imgPath.startsWith('data:image') || !imgPath.startsWith('http')) {
      try {
        final decodedBytes = base64Decode(imgPath.split(',').last);
        return Image.memory(
          decodedBytes,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => _buildImageError(height, width),
        );
      } catch (_) {
        return _buildImageError(height, width);
      }
    }
    return CachedNetworkImage(
      imageUrl: imgPath,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: Container(
          color: Colors.grey.shade800,
          height: height,
          width: width,
        ),
      ),
      errorWidget: (context, url, error) => _buildImageError(height, width),
    );
  }

  Widget _buildImageError(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        gradient: AppTheme.pinkPurpleGradient,
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final myProfile = appState.currentUserProfile;
    final creatorStats = appState.getCreatorStats(myProfile.username);
    final myCreations = appState.userCreations;
    final savedPrompts = appState.savedPrompts;
    
    // Liked prompts are community prompts liked by the user
    final likedPrompts = appState.communityPrompts.where(
      (p) => p.likesList.contains(myProfile.username)
    ).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Background glows
          if (isDark) ...[
            Positioned(
              top: 100,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.15),
                      AppTheme.neonPurple.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.electricBlue.withOpacity(0.12),
                      AppTheme.electricBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],

          CustomScrollView(
            slivers: [
              // Cover Banner & Profile Picture Stack (Guarantees avatar paints on top of cover image)
              // Combined Header & Profile Details (Guarantees no clipping/overlap issues)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200, // Hard-coded background cover image container height to a maximum of 200 logical pixels
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Cover Banner Image
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildPromptImage(myProfile.coverBanner, 200, double.infinity),
                          ),
                          // 2. Cover Banner Gradient Overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    isDark ? const Color(0xFF131324) : Colors.white,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          // 3. Change Cover Button
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context, appState, myProfile.username, myProfile.avatar),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                radius: 20,
                                borderColor: Colors.white24,
                                child: const Row(
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white, size: 13),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change Cover',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 4. Overlapping Avatar Picture (sits exactly halfway overlapping: bottom: -40, left: 20)
                          Positioned(
                            left: 20,
                            bottom: -40,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context, appState, myProfile.username, myProfile.avatar),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(myProfile.avatar),
                                    backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                                    child: const Icon(Icons.person, size: 40),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.neonPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 5. Edit Button on the right (aligned with avatar: bottom: -40, right: 16)
                          Positioned(
                            right: 16,
                            bottom: -40,
                            child: IconButton(
                              icon: const Icon(Icons.edit_note, color: AppTheme.electricBlue, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EditProfileView()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
 
                    // Profile description and stats (properly separated from header with 50px top offset)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Username & Bio Info
                          Row(
                            children: [
                              Text(
                                myProfile.username,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              CreatorLevelBadge(level: creatorStats.level),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            myProfile.bio,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.date_range_rounded, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Joined ${myProfile.joinDate}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // XP Progress bar
                          XpProgressBar(xp: creatorStats.xp, level: creatorStats.level),
                          const SizedBox(height: 20),

                          AnzorCard(
                            padding: const EdgeInsets.all(16.0),
                            radius: 22,
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: CircularProgressIndicator(
                                        value: creatorStats.reputationScore / 100.0,
                                        strokeWidth: 4.5,
                                        backgroundColor: const Color(0xFF1E293B),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandOrange),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${creatorStats.reputationScore}',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Rep',
                                          style: GoogleFonts.inter(
                                            fontSize: 7.5,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reputation Status: ${creatorStats.reputationScore >= 80 ? "Exemplary" : (creatorStats.reputationScore >= 60 ? "Renowned" : "Standard")}',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.brandOrange,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Calculated from likes, collections, and overall user trust.',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Achievements list
                          const Text(
                            'Earned Achievements',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 85,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: creatorStats.achievements.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final badge = creatorStats.achievements[index];
                                IconData badgeIcon;
                                switch (badge.icon) {
                                  case 'verified_user': badgeIcon = Icons.verified_user_rounded; break;
                                  case 'wb_incandescent': badgeIcon = Icons.wb_incandescent_rounded; break;
                                  case 'trending_up': badgeIcon = Icons.trending_up_rounded; break;
                                  case 'stars': badgeIcon = Icons.stars_rounded; break;
                                  case 'bookmark': badgeIcon = Icons.bookmark_rounded; break;
                                  default: badgeIcon = Icons.military_tech_rounded;
                                }

                                return AnzorCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                  radius: 16,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(badgeIcon, color: AppTheme.brandOrange, size: 20),
                                      const SizedBox(height: 4),
                                      Text(
                                        badge.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        badge.dateEarned,
                                        style: GoogleFonts.inter(
                                          fontSize: 7.0,
                                          color: Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Enhanced Stats Grid: 8 elements
                          const Text(
                            'Creator Statistics',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.0,
                            children: [
                              _buildStatCard(context, 'Creations', creatorStats.totalPosts.toString(), isDark),
                              _buildStatCard(context, 'Likes', creatorStats.totalLikes.toString(), isDark),
                              _buildStatCard(context, 'Views', creatorStats.totalViews.toString(), isDark),
                              _buildStatCard(context, 'Saves', creatorStats.totalSaves.toString(), isDark),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FollowersFollowingView(initialTab: 'Followers'),
                                    ),
                                  );
                                },
                                child: _buildStatCard(context, 'Followers', myProfile.followers.length.toString(), isDark),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FollowersFollowingView(initialTab: 'Following'),
                                    ),
                                  );
                                },
                                child: _buildStatCard(context, 'Following', myProfile.following.length.toString(), isDark),
                              ),
                              _buildStatCard(context, 'Remixes', (creatorStats.totalPosts * 0.4).round().toString(), isDark),
                              _buildStatCard(context, 'Score', ((creatorStats.reputationScore * 10) + (creatorStats.xp * 0.1)).round().toString(), isDark),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Profile Grids Tab Switcher
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0x0EFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x1BFFFFFF)),
                            ),
                            child: Row(
                              children: [
                                _buildGridTabButton(0, 'My Prompts', myCreations.length),
                                _buildGridTabButton(1, 'Saved', savedPrompts.length),
                                _buildGridTabButton(2, 'Liked', likedPrompts.length),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Render Tab Grid content
                          _buildActiveGridContent(context, myCreations, savedPrompts, likedPrompts, isDark),
                          
                          const SizedBox(height: 24),
                          const Divider(color: Color(0x1BFFFFFF)),
                          const SizedBox(height: 16),

                          // Creator Analytics Button Tile
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreatorAnalyticsView()),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnzorCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.brandOrange.withValues(alpha: 0.12),
                                    ),
                                    child: const Icon(
                                      Icons.analytics_rounded,
                                      color: AppTheme.brandOrange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Creator Intelligence Dashboard',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Analyze reach metrics, daily copies, views and audience trends.',
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white30),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Preferences & Settings Area
                          _buildPreferencesSection(context, appState, localizations),
                          
                          const SizedBox(height: 20),

                          // Secure Admin Panel
                          if (appState.isAdmin) ...[
                            _buildAdminConsoleTile(context, appState, localizations),
                            const SizedBox(height: 25),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridTabButton(int index, String title, int count) {
    final isSelected = _selectedGridTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGridTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.neonPurple.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.neonPurple.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 8,
                  color: isSelected ? AppTheme.electricBlue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGridContent(
    BuildContext context,
    List<PromptItem> myCreations,
    List<PromptItem> savedPrompts,
    List<PromptItem> likedPrompts,
    bool isDark,
  ) {
    List<PromptItem> activeList = [];
    String emptyMessage = '';
    
    if (_selectedGridTab == 0) {
      activeList = myCreations;
      emptyMessage = 'You haven\'t published any prompts yet.';
    } else if (_selectedGridTab == 1) {
      activeList = savedPrompts;
      emptyMessage = 'No saved bookmarks yet.';
    } else {
      activeList = likedPrompts;
      emptyMessage = 'No liked prompts yet.';
    }

    if (activeList.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bubble_chart_outlined, color: Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: activeList.length,
      itemBuilder: (context, index) {
        final item = activeList[index];
        return GestureDetector(
          onTap: () => _showPromptDetailDialog(context, item, isDark),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade800,
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPromptImage(item.image, 100, 100),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xB3100E1E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFFFF9800), size: 10),
                        const SizedBox(width: 1),
                        Text(
                          '${85 + (item.title.hashCode % 15)}',
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xCC000000), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, bool isDark) {
    return AnzorCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      radius: 16,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.brandOrange),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Preferences Section
  Widget _buildPreferencesSection(BuildContext context, AppState appState, AppLocalizations localizations) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsView()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: AnzorCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandOrange.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: AppTheme.brandOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Control Center',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Adjust default models, creativity levels, and preferences.',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white30),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedPromptsView()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: AnzorCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.electricBlue.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.bookmark_added_rounded,
                    color: AppTheme.electricBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal AI Prompt Vault',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Access and manage saved prompts library collection.',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white30),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Unified Admin Console Dashboard Tile
  Widget _buildAdminConsoleTile(BuildContext context, AppState appState, AppLocalizations localizations) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminView()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        borderColor: AppTheme.brandOrange.withOpacity(0.3),
        addGlow: true,
        glowColor: AppTheme.brandOrange,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandOrange.withOpacity(0.12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.brandOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Telemetry Console',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandOrange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Access live system metrics, moderation requests, and logs.',
                    style: TextStyle(fontSize: 9.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.neonPink),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 12.5)),
            ],
          ),
          trailing,
        ],
      ),
    );
  }

  void _showUsersListModal(BuildContext context, String title, List<String> usernames, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: GlassCard(
              padding: const EdgeInsets.all(16),
              borderColor: AppTheme.neonPurple.withOpacity(0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$title (${usernames.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0x1BFFFFFF)),
                  const SizedBox(height: 6),
                  usernames.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No users found in this list.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          width: 250,
                          child: ListView.builder(
                            itemCount: usernames.length,
                            itemBuilder: (context, index) {
                              final user = usernames[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage('https://api.dicebear.com/7.x/bottts/png?seed=$user'),
                                ),
                                title: Text(user, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreatorProfileView(username: user),
                                    ),
                                  );
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
      },
    );
  }

  void _showPromptDetailDialog(BuildContext context, PromptItem prompt, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            prompt.image,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Container(
                              height: 180,
                              decoration: const BoxDecoration(
                                gradient: AppTheme.pinkPurpleGradient,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(prompt.authorAvatar.isNotEmpty 
                                    ? prompt.authorAvatar 
                                    : 'https://api.dicebear.com/7.x/bottts/png?seed=${prompt.author}'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                prompt.author,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const Spacer(),
                              Text(
                                prompt.style,
                                style: const TextStyle(fontSize: 10, color: AppTheme.electricBlue),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            prompt.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prompt.prompt,
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.copy, size: 14),
                                label: const Text('Copy Prompt', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: prompt.prompt));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Prompt copied!')),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState appState, String currentName, String currentAvatar) {
    final nameController = TextEditingController(text: currentName);
    final bioController = TextEditingController(text: appState.currentUserProfile.bio);
    Uint8List? selectedImageBytes;
    String? base64Avatar;
    Uint8List? selectedCoverBytes;
    String? base64Cover;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            Future<void> pickAvatar() async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setDialogState(() {
                  selectedImageBytes = bytes;
                  base64Avatar = 'data:image/jpeg;base64,' + base64Encode(bytes);
                });
              }
            }

            Future<void> pickCover() async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setDialogState(() {
                  selectedCoverBytes = bytes;
                  base64Cover = 'data:image/jpeg;base64,' + base64Encode(bytes);
                });
              }
            }

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF13141A) : Colors.white,
              title: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cover Banner Picker Preview
                    GestureDetector(
                      onTap: pickCover,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 100,
                              width: 300,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0x0EFFFFFF) : Colors.grey.shade200,
                                border: Border.all(
                                  color: isDark ? const Color(0x1BFFFFFF) : Colors.grey.shade300,
                                ),
                              ),
                              child: selectedCoverBytes != null
                                  ? Image.memory(selectedCoverBytes!, height: 100, width: 300, fit: BoxFit.cover)
                                  : (base64Cover != null
                                      ? _buildPromptImage(base64Cover!, 100, 300)
                                      : _buildPromptImage(appState.currentUserProfile.coverBanner, 100, 300)),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.neonPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Cover Image',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.neonPurple.withOpacity(0.1),
                            child: ClipOval(
                              child: selectedImageBytes != null
                                  ? Image.memory(selectedImageBytes!, width: 80, height: 80, fit: BoxFit.cover)
                                  : (base64Avatar != null
                                      ? _buildPromptImage(base64Avatar!, 80, 80)
                                      : _buildPromptImage(currentAvatar, 80, 80)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.neonPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnzorInput(
                      controller: nameController,
                      hintText: 'Display Name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    AnzorInput(
                      controller: bioController,
                      maxLines: 2,
                      hintText: 'Bio / Description',
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Or choose a preset avatar:',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        'Aiden',
                        'Sophia',
                        'Leo',
                        'Luna',
                        'Max',
                      ].map((seed) {
                        final avatarUrl = 'https://api.dicebear.com/7.x/bottts/png?seed=$seed';
                        final isSelected = (base64Avatar == null && currentAvatar == avatarUrl) || base64Avatar == avatarUrl;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedImageBytes = null;
                              base64Avatar = avatarUrl;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? AppTheme.brandOrange : Colors.transparent,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade900,
                              child: ClipOval(
                                child: Image.network(avatarUrl, width: 40, height: 40),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      await appState.updateUserProfile(
                        username: nameController.text.trim(),
                        avatarBase64: base64Avatar,
                        coverBase64: base64Cover,
                        bio: bioController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Save', style: GoogleFonts.inter(color: AppTheme.brandOrange, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
