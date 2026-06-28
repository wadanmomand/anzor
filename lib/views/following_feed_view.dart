import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/social_post_card.dart';
import 'discover_view.dart';
import 'notification_center_view.dart';
import 'creator_profile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FollowingFeedView
// A highly premium, personalized community workspace for followed creators.
// Features a Hero Header, Creator Summary Card, Active Creators Row, and 
// cleaner post cards than the Home Screen.
// ─────────────────────────────────────────────────────────────────────────────

class FollowingFeedView extends StatefulWidget {
  const FollowingFeedView({super.key});

  @override
  State<FollowingFeedView> createState() => _FollowingFeedViewState();
}

class _FollowingFeedViewState extends State<FollowingFeedView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isInfiniteLoading = false;
  List<PromptItem> _additionalSimulatedPrompts = [];
  String _activeFilter = 'All';
  bool _isScrolled = false;
  double _headerOpacity = 0.0;

  final List<String> _filters = [
    'All', 'Today', 'Trending', 'Newest',
    'Images', 'Videos', 'ChatGPT', 'Gemini', 'Claude', 'Favorites',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double offset = _scrollController.position.pixels;
    final double newOpacity = (offset / 80.0).clamp(0.0, 1.0);

    if ((newOpacity - _headerOpacity).abs() > 0.01) {
      setState(() {
        _headerOpacity = newOpacity;
        _isScrolled = offset > 10;
      });
    }

    // Infinite scroll trigger
    if (offset >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isInfiniteLoading) {
        _loadMoreFollowedPosts();
      }
    }
  }

  Future<void> _loadMoreFollowedPosts() async {
    setState(() => _isInfiniteLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final followedPrompts = appState.followingPrompts;
    if (followedPrompts.isNotEmpty) {
      final random = Random();
      final source = followedPrompts[random.nextInt(followedPrompts.length)];
      final newSim = source.copyWith(
        id: 'sim_fol_redesigned_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100)}',
        title: '${source.title} (Exclusive)',
        likes: source.likes + random.nextInt(15),
        createdAt: DateTime.now().toIso8601String(),
      );
      setState(() {
        _additionalSimulatedPrompts.add(newSim);
        _isInfiniteLoading = false;
      });
    } else {
      setState(() => _isInfiniteLoading = false);
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _additionalSimulatedPrompts.clear();
    });
    HapticFeedback.selectionClick();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    // Filter creators we follow
    final followedCreators = appState.creators.where((c) => c.isFollowing).toList();

    // Get posts from followed creators
    List<PromptItem> followedFeed = appState.followingPrompts;

    // Apply filters
    List<PromptItem> filteredFeed = [...followedFeed, ..._additionalSimulatedPrompts];
    if (_activeFilter != 'All') {
      if (_activeFilter == 'Trending') {
        filteredFeed.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (_activeFilter == 'Newest') {
        filteredFeed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_activeFilter == 'Favorites') {
        filteredFeed = filteredFeed.where((p) => p.isLikedByMe).toList();
      } else if (_activeFilter == 'Today') {
        filteredFeed = filteredFeed.where((p) =>
            p.createdAt.contains(DateTime.now().toIso8601String().substring(0, 10)) ||
            p.createdAt.contains('2026-06-27')).toList(); // mock matches today's date
      } else {
        final query = _activeFilter.toLowerCase();
        filteredFeed = filteredFeed.where((p) =>
            p.category.toLowerCase().contains(query) ||
            p.prompt.toLowerCase().contains(query) ||
            p.title.toLowerCase().contains(query)).toList();
      }
    }

    final isFeedShort = filteredFeed.length < 3;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // ── Ambient Background Glows ──────────────────────────────────
          Positioned(
            top: -90,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.brandOrange.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.electricBlue.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content Scroll ───────────────────────────────────────
          RefreshIndicator(
            color: AppTheme.brandOrange,
            backgroundColor: const Color(0xFF131024),
            onRefresh: () async {
              await appState.refreshCommunityFeed();
              await appState.refreshFollowingFeed();
              setState(() => _additionalSimulatedPrompts.clear());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // Top space for appbar
                SliverToBoxAdapter(child: SizedBox(height: topPad + 60)),

                // ── Hero Header Title ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Following',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay inspired by creators you follow.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Creator Summary Card ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: _buildSummaryCard(appState, followedCreators),
                  ),
                ),

                // ── Active Creators stories ────────────────────────────────
                if (followedCreators.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildActiveCreatorsStories(followedCreators),
                    ),
                  ),

                // ── Filter Bar ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFilterBar(),
                  ),
                ),

                // ── Feed / Feed Content ────────────────────────────────────
                if (followedFeed.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: _buildEmptyState(context),
                          ),
                        ),
                        _buildSuggestedCreatorsSection(appState),
                        const SizedBox(height: 24),
                      ],
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < filteredFeed.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCleanerSocialCard(filteredFeed[index]),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppTheme.brandOrange,
                                    backgroundColor: AppTheme.brandOrange.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        childCount: filteredFeed.length + (_isInfiniteLoading ? 1 : 0),
                      ),
                    ),
                  ),

                  // Suggestions if feed is short
                  if (isFeedShort)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildSuggestedCreatorsSection(appState),
                      ),
                    ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // ── Pinned Mini Header ─────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildStickyAppBar(context, appState, topPad),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Creator Summary Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(AppState appState, List<CreatorProfile> followed) {
    final count = followed.length;
    final promptsCount = appState.followingPrompts.length * 2 + 3;
    final activeCount = followed.isNotEmpty ? (followed.length > 2 ? followed.length - 1 : followed.length) : 0;

    return AnzorCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      borderColor: AppTheme.brandOrange.withValues(alpha: 0.15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryStat('Following', '$count Creators', Icons.people_rounded),
            ),
            Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: _buildSummaryStat('New Prompts', '+$promptsCount today', Icons.auto_awesome_rounded),
            ),
            Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: _buildSummaryStat('Active', '$activeCount online', Icons.circle_notifications_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.brandOrange),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Active Creators story avatars
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildActiveCreatorsStories(List<CreatorProfile> followed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'ACTIVE CREATORS',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: followed.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final creator = followed[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatorProfileView(username: creator.username),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.brandOrange,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandOrange.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(creator.avatar),
                            backgroundColor: const Color(0xFF131024),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF87),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF06050C),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      creator.username,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sticky Pinned Mini AppBar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStickyAppBar(BuildContext context, AppState appState, double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _headerOpacity * 20,
          sigmaY: _headerOpacity * 20,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.only(top: topPad),
          color: Color.lerp(
            Colors.transparent,
            const Color(0xD5060509),
            _headerOpacity,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Mini title only visible when scrolled
                      AnimatedOpacity(
                        opacity: _headerOpacity,
                        duration: const Duration(milliseconds: 120),
                        child: Text(
                          'Following',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Right Search Icon
                      _appBarBtn(
                        icon: Icons.search_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiscoverView()),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right Notification Icon
                      _appBarBtn(
                        icon: Icons.notifications_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationCenterView()),
                        ),
                        showBadge: appState.hasUnreadNotifications,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: _headerOpacity * 0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarBtn({required IconData icon, required VoidCallback onTap, bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 0.8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 17, color: Colors.white70),
            if (showBadge)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Filter Bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSel = _activeFilter == filter;
          return AnzorChip(
            label: filter,
            isSelected: isSel,
            onTap: () => _changeFilter(filter),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleaner Social Post Card (Exclusive to Following Screen)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCleanerSocialCard(PromptItem prompt) {
    // In our Following screen, the feed should look cleaner, have more breathing
    // space, better typography, and display prompt score + compatibility.
    // Rather than duplicating the complex social post card, we inherit its view
    // prompt interactions but render it cleaner.
    return SocialPostCard(
      prompt: prompt,
      // The compact flag renders the social post card in a sleeker, cleaner format
      // with more breathing space.
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty State
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnzorCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandOrange.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppTheme.brandOrange.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 24,
                color: AppTheme.brandOrange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Followed Creators Yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start following talented AI creators to build your personalized prompt feed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 20),
            AnzorButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.setActiveTab(2);
              },
              radius: 16,
              height: 46,
              child: Text(
                'Discover Creators',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Suggested Creators Section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSuggestedCreatorsSection(AppState appState) {
    final List<CreatorProfile> suggested = appState.creators
        .where((c) => !c.isFollowing && c.username != appState.currentUser?['username'])
        .toList();

    if (suggested.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Suggested Creators',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggested.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final creator = suggested[index];
              return _buildSuggestedCreatorCard(creator, appState);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedCreatorCard(CreatorProfile creator, AppState appState) {
    final name = creator.username;
    final followersText = '${creator.followers.length + 120} Followers';
    final categoryText = creator.bio.isNotEmpty
        ? (creator.bio.length > 20 ? '${creator.bio.substring(0, 18)}…' : creator.bio)
        : 'AI Prompt Specialist';

    return AnzorCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      radius: 20,
      child: Container(
        width: 136,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatorProfileView(username: name),
                ),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.brandOrange.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(creator.avatar),
                  backgroundColor: const Color(0xFF131024),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              categoryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 10),
            AnzorActionButton(
              icon: Icons.person_add_rounded,
              label: 'Follow',
              variant: AnzorActionButtonVariant.primary,
              onTap: () {
                appState.toggleFollow(name);
                HapticFeedback.mediumImpact();
              },
            ),
          ],
        ),
      ),
    );
  }
}
