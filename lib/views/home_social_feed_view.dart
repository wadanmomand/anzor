import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/social_post_card.dart';
import '../widgets/anzor_brand_text.dart';
import '../widgets/avatar_header_button.dart';
import '../widgets/glass_widgets.dart';
import 'discover_view.dart';
import 'notification_center_view.dart';

class HomeSocialFeedView extends StatefulWidget {
  const HomeSocialFeedView({super.key});

  @override
  State<HomeSocialFeedView> createState() => _HomeSocialFeedViewState();
}

class _HomeSocialFeedViewState extends State<HomeSocialFeedView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isInfiniteLoading = false;
  List<PromptItem> _additionalSimulatedPrompts = [];
  String _activeCategory = 'All';
  bool _isScrolled = false;
  double _headerOpacity = 0.0;
  double _greetingOpacity = 1.0;
  late AnimationController _categoryAnimController;

  final List<String> _categories = [
    'All',
    'Trending',
    'Realistic',
    'Anime',
    'Fantasy',
    'Sci-Fi',
    'Portrait',
    'Logo',
    'Architecture',
    'Photography',
    '3D',
    'Food',
  ];

  @override
  void initState() {
    super.initState();
    _categoryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _categoryAnimController.forward();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _categoryAnimController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Scroll-aware header opacity (0 → 1 over first 80 pixels)
    final double offset = _scrollController.position.pixels;
    final double newOpacity = (offset / 80.0).clamp(0.0, 1.0);
    final double newGreetingOpacity = (1.0 - (offset / 60.0)).clamp(0.0, 1.0);

    if ((newOpacity - _headerOpacity).abs() > 0.01 || (newGreetingOpacity - _greetingOpacity).abs() > 0.01) {
      setState(() {
        _headerOpacity = newOpacity;
        _greetingOpacity = newGreetingOpacity;
        _isScrolled = offset > 10;
      });
    }

    // Infinite scroll trigger
    if (offset >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isInfiniteLoading) {
        _loadMoreSimulatedPosts();
      }
    }
  }

  Future<void> _loadMoreSimulatedPosts() async {
    setState(() => _isInfiniteLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final basePrompts = appState.communityPrompts;
    if (basePrompts.isNotEmpty) {
      final random = Random();
      final sourcePrompt = basePrompts[random.nextInt(basePrompts.length)];
      final newSimulated = sourcePrompt.copyWith(
        id: 'sim_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100)}',
        title: '${sourcePrompt.title} (AI Remix)',
        likes: sourcePrompt.likes + random.nextInt(20),
        createdAt: DateTime.now().toIso8601String(),
      );
      setState(() {
        _additionalSimulatedPrompts.add(newSimulated);
        _isInfiniteLoading = false;
      });
    } else {
      setState(() => _isInfiniteLoading = false);
    }
  }

  void _selectCategory(String cat, AppState appState) {
    setState(() => _activeCategory = cat);
    _categoryAnimController.forward(from: 0.0);
    appState.setCategoryFilter(cat == 'Trending' ? 'All' : cat);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    // Build merged, filtered list
    List<PromptItem> baseList;
    if (_activeCategory == 'Trending') {
      baseList = List<PromptItem>.from(appState.communityPrompts)
        ..sort((a, b) => b.likes.compareTo(a.likes));
    } else {
      baseList = List<PromptItem>.from(appState.communityPrompts)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    List<PromptItem> mergedPrompts = [...baseList, ..._additionalSimulatedPrompts];
    if (_activeCategory != 'All' && _activeCategory != 'Trending') {
      mergedPrompts = mergedPrompts
          .where((p) => p.category.toLowerCase() == _activeCategory.toLowerCase())
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // ── Main Scrollable Content ───────────────────────────────────────
          RefreshIndicator(
            color: AppTheme.brandOrange,
            backgroundColor: const Color(0xFF131024),
            onRefresh: () async {
              await appState.refreshCommunityFeed();
              setState(() => _additionalSimulatedPrompts.clear());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Top padding for the pinned header
                SliverToBoxAdapter(
                  child: SizedBox(height: topPad + 60),
                ),

                // ── Scrollable Greeting + Search + Category Section ───────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: _buildGreeting(appState),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSearchBar(context),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryChips(appState),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // ── Feed Cards ───────────────────────────────────────────
                mergedPrompts.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < mergedPrompts.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: SocialPostCard(
                                    prompt: mergedPrompts[index],
                                    animDelay: Duration(
                                        milliseconds: (index * 60).clamp(0, 400)),
                                  ),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.brandOrange,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                            },
                            childCount:
                                mergedPrompts.length + (_isInfiniteLoading ? 1 : 0),
                          ),
                        ),
                      ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // ── Pinned Frosted Glass Header ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildPinnedHeader(context, appState, topPad),
          ),
        ],
      ),
    );
  }

  // ── Pinned Header Widget ─────────────────────────────────────────────────
  Widget _buildPinnedHeader(BuildContext context, AppState appState, double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _headerOpacity * 20,
          sigmaY: _headerOpacity * 20,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(top: topPad),
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.transparent,
              const Color(0xD5060509),
              _headerOpacity,
            ),
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
                      // Left: Avatar button (Tapping -> Profile, Long Press -> Quick Actions)
                      const SizedBox(
                        width: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AvatarHeaderButton(),
                        ),
                      ),

                      // Centered brand: "Anzor" styled with premium brand gradient
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppTheme.brandGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Anzor',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: _isScrolled ? 21 : 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right: Notification button with orange badge
                      SizedBox(
                        width: 48,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildNotificationButton(context, appState),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Subtle transparent gradient divider
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: _headerOpacity * 0.06),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, AppState appState) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationCenterView(),
          ),
        );
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF131024),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandOrange.withValues(alpha: 0.2),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brandOrange.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 19,
                color: Colors.white70,
              ),
            ),
            if (appState.hasUnreadNotifications)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6A00).withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Greeting Widget ──────────────────────────────────────────────────────
  Widget _buildGreeting(AppState appState) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning 👋'
        : hour < 17
            ? 'Good Afternoon 👋'
            : 'Good Evening 👋';

    // Use username or fallback
    final rawUsername = appState.currentUserProfile.username;
    final username = rawUsername.isNotEmpty ? rawUsername : 'Muhammad';

    return Opacity(
      opacity: _greetingOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF8FAFC).withOpacity(0.90),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF8FAFC),
              letterSpacing: -1.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar Widget ────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return ScaleOnPress(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiscoverView()),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF131024),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.38),
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search creators, prompts, styles...',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.25),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 18,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => AppTheme.brandGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // ── Category Chips ───────────────────────────────────────────────────────
  Widget _buildCategoryChips(AppState appState) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _activeCategory == cat;

          return AnzorChip(
            label: cat,
            isSelected: isSelected,
            onTap: () => _selectCategory(cat, appState),
          );
        },
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
              ),
            ),
            child: Icon(
              Icons.photo_filter_rounded,
              color: Colors.white.withOpacity(0.25),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts in this category',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting a different filter',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
        ],
      ),
    );
  }
}
