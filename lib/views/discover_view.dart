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
import 'notification_center_view.dart';
import 'leaderboard_view.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;
  String _activeCategory = 'Trending';
  String _searchFilter = 'All';

  final List<String> _categories = [
    'Trending', 'Featured', 'Newest', 'ChatGPT', 'Gemini', 'Claude',
    'Midjourney', 'Flux', 'Imagen', 'Video', 'Logo', 'Photography',
    'Marketing', 'Coding', 'Business'
  ];

  final List<String> _searchFilters = [
    'All', 'Prompts', 'Creators', 'Collections', 'Images', 'Videos'
  ];

  final List<String> _trendingSearches = [
    'ChatGPT', 'Gemini', 'Logo Design', 'YouTube', 'Marketing', 'Coding', 'Photography', 'Video Prompt'
  ];

  final List<String> _recentSearches = [
    'cyberpunk avatar', 'watercolor assets', 'marketing helper'
  ];

  final List<(String, String, IconData, Color)> _collectionsList = [
    ('AI Art', 'Midjourney, Flux, Stable Diffusion prompts', Icons.brush_rounded, Color(0xFFFF9800)),
    ('Marketing', 'Copywriting, SEO, strategy tools', Icons.trending_up_rounded, Color(0xFF00FF7F)),
    ('Coding', 'Algorithms, code generators, shell command tools', Icons.code_rounded, Color(0xFF00D9FF)),
    ('Education', 'Learning assistants, summarizers', Icons.school_rounded, Color(0xFF8A2BE2)),
    ('Business', 'Finance tools, pitch templates, emails', Icons.business_center_rounded, Color(0xFFFF1493)),
    ('Video Creation', 'Sora, Runway, Pika narrative scripts', Icons.movie_creation_rounded, Color(0xFFFF007F)),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus != _isSearchFocused) {
        setState(() {
          _isSearchFocused = _searchFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
      _isSearchFocused = true;
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _isSearchFocused = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _simulateVoiceSearch() {
    HapticFeedback.heavyImpact();
    _triggerSearch('Futuristic anime portrait');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice Search: "Futuristic anime portrait"',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
        backgroundColor: AppTheme.brandOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    // Search matches
    final matchedPrompts = appState.searchPrompts(_searchQuery);
    final matchedCreators = appState.searchCreators(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -90, left: -90,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120, right: -100,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          // Scrollable Workspace Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top padding spacer
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              if (!_isSearchFocused && _searchQuery.isEmpty) ...[
                // ── Discover Mode Hero Dashboard ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDiscoveryHero(appState),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Discover Categories Chips scrollbar
                SliverToBoxAdapter(child: _buildCategoryChips()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Featured Creators horizontal list
                SliverToBoxAdapter(child: _buildFeaturedCreatorsRow(appState)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Collections Grid Hub
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCollectionsGrid(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Trending Prompts list header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 16,
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trending AI Prompts',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Prompts lists
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final list = appState.communityPrompts;
                        if (list.isEmpty) return const SizedBox.shrink();
                        final prompt = list[index % list.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPromptListItem(prompt),
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                ),
              ] else ...[
                // ── Premium Fullscreen Search Workspace ─────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Search filters chips
                        _buildSearchFiltersRow(),
                        const SizedBox(height: 18),

                        if (_searchQuery.trim().isEmpty) ...[
                          // Recent Searches History
                          if (_recentSearches.isNotEmpty) _buildRecentSearchesSection(),
                          const SizedBox(height: 20),

                          // Trending Searches Keyword list
                          _buildTrendingSearchesSection(),
                        ] else ...[
                          // Matched list results
                          _buildSearchResultsList(matchedCreators, matchedPrompts),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),

          // Pinned Premium Glass Header Block (Frosted)
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildPremiumGlassHeader(topPad),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Glass Header Build
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPremiumGlassHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD206050C),
          child: Column(
            children: [
              Row(
                children: [
                  if (_isSearchFocused || _searchQuery.isNotEmpty) ...[
                    GestureDetector(
                      onTap: _clearSearch,
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
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSearchFocused || _searchQuery.isNotEmpty ? 'Search' : 'Discover',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white,
                        ),
                      ),
                      Text(
                        _isSearchFocused || _searchQuery.isNotEmpty
                            ? 'Find prompts, creators, and AI inspiration.'
                            : 'Explore the world\'s best AI prompts.',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!_isSearchFocused && _searchQuery.isEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 21),
                      onPressed: () {
                        _searchFocusNode.requestFocus();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_events_outlined, color: Colors.white70, size: 21),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LeaderboardView()),
                        );
                      },
                      tooltip: 'Leaderboard',
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 21),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationCenterView()),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar wrapper
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _searchFocusNode.hasFocus
                      ? [
                          BoxShadow(
                            color: AppTheme.brandOrange.withValues(alpha: 0.12),
                            blurRadius: 16, spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: AnzorInput(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search prompts, hashtags, creators...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Colors.white54),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, size: 16, color: Colors.white54),
                        onPressed: _simulateVoiceSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discovery Mode: Hero Promotional Banner Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDiscoveryHero(AppState appState) {
    return AnzorCard(
      padding: EdgeInsets.zero,
      borderColor: AppTheme.brandOrange.withValues(alpha: 0.25),
      addGlow: true,
      glowColor: AppTheme.brandOrange,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              AppTheme.brandOrange.withValues(alpha: 0.15),
              AppTheme.brandGold.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10, bottom: -10,
              child: Opacity(
                opacity: 0.25,
                child: Icon(Icons.auto_awesome_motion_rounded, size: 150, color: AppTheme.brandOrange),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.brandOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppTheme.brandOrange, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          'TRENDING TODAY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.brandOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock Premium AI Prompts',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore visual styles, code scripts, and chatbots curated by top engineers worldwide.',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.5), height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discover Categories Chips
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSel = _activeCategory == cat;
          return AnzorChip(
            label: cat,
            isSelected: isSel,
            onTap: () {
              setState(() {
                _activeCategory = cat;
              });
              HapticFeedback.selectionClick();
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Featured Creators Horizontal Row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFeaturedCreatorsRow(AppState appState) {
    final list = appState.creators;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4, height: 16,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Featured AI Architects',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final creator = list[index];
              final isFollowing = appState.currentUserProfile.following.contains(creator.username);
              return Container(
                width: 136,
                child: AnzorCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  radius: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreatorProfileView(username: creator.username)),
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(creator.avatar),
                              backgroundColor: const Color(0xFF131024),
                            ),
                            if (index % 2 == 0)
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00FF87)),
                                  child: const Icon(Icons.check, size: 8, color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        creator.username,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white,
                        ),
                      ),
                      Text(
                        'Global Rank #${index + 12}',
                        style: GoogleFonts.inter(
                          fontSize: 9, color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: AnzorButton(
                          onPressed: () {
                            appState.toggleFollow(creator.username);
                            HapticFeedback.mediumImpact();
                          },
                          radius: 8,
                          gradient: isFollowing
                              ? const LinearGradient(colors: [Color(0xFF222133), Color(0xFF222133)])
                              : AppTheme.brandGradient,
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: isFollowing ? Colors.white60 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Collections Grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCollectionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4, height: 16,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Explore AI Collections',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: _collectionsList.length,
          itemBuilder: (context, i) {
            final col = _collectionsList[i];
            return GestureDetector(
              onTap: () => _triggerSearch(col.$1),
              child: AnzorCard(
                padding: const EdgeInsets.all(12),
                radius: 18,
                borderColor: col.$4.withValues(alpha: 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: col.$4.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(col.$3, color: col.$4, size: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      col.$1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white,
                      ),
                    ),
                    Text(
                      col.$2,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9, color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Prompt List Card (Standard Premium Design)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPromptListItem(PromptItem prompt) {
    return AnzorCard(
      padding: const EdgeInsets.all(12),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundImage: NetworkImage(prompt.authorAvatar.isNotEmpty
                    ? prompt.authorAvatar
                    : 'https://api.dicebear.com/7.x/bottts/png?seed=${prompt.author}'),
              ),
              const SizedBox(width: 8),
              Text(
                prompt.author,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.brandOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  prompt.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.brandOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  prompt.image,
                  width: 76, height: 76, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 76, height: 76,
                    decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      prompt.prompt,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 13, color: Colors.white30),
                  const SizedBox(width: 4),
                  Text('${(prompt.likes * 7 + 124)} views', style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
                  const SizedBox(width: 12),
                  const Icon(Icons.favorite_border_rounded, size: 13, color: Colors.white30),
                  const SizedBox(width: 4),
                  Text('${prompt.likes}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
                ],
              ),
              SizedBox(
                height: 28,
                child: AnzorButton(
                  onPressed: () => _showPromptDetailDialog(context, prompt),
                  radius: 8,
                  gradient: AppTheme.brandGradient,
                  glowColor: AppTheme.brandOrange,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'View Prompt',
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Search Mode: Result Category Filters
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchFiltersRow() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _searchFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _searchFilters[index];
          final isSel = _searchFilter == filter;
          return AnzorChip(
            label: filter,
            isSelected: isSel,
            onTap: () {
              setState(() {
                _searchFilter = filter;
              });
              HapticFeedback.selectionClick();
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Search Mode: Recent Searches Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _recentSearches.clear());
                HapticFeedback.mediumImpact();
              },
              child: Text(
                'Clear all',
                style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.brandOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: _recentSearches.map((keyword) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_rounded, size: 18, color: Colors.white30),
            title: Text(
              keyword,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
            ),
            trailing: const Icon(Icons.arrow_outward_rounded, size: 14, color: Colors.white30),
            onTap: () => _triggerSearch(keyword),
          )).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Search Mode: Trending Searches Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTrendingSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Searches',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _trendingSearches.map((tag) => GestureDetector(
            onTap: () => _triggerSearch(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppTheme.brandOrange, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Premium Search Mode: Matching Results
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchResultsList(List<CreatorProfile> creators, List<PromptItem> prompts) {
    final filteredCreators = creators.where((c) => _searchFilter == 'All' || _searchFilter == 'Creators').toList();
    final filteredPrompts = prompts.where((p) {
      if (_searchFilter == 'All') return true;
      if (_searchFilter == 'Prompts') return true;
      if (_searchFilter == 'Images' && p.category.toLowerCase().contains('image')) return true;
      if (_searchFilter == 'Videos' && p.category.toLowerCase().contains('video')) return true;
      return false;
    }).toList();

    if (filteredCreators.isEmpty && filteredPrompts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.brandOrange.withValues(alpha: 0.12),
                  border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.search_off_rounded, size: 28, color: AppTheme.brandOrange),
              ),
              const SizedBox(height: 18),
              Text(
                'Start searching for amazing AI prompts',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try typing keywords like logo, cinematic, chatgpt...',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5, color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredCreators.isNotEmpty) ...[
          Text(
            'Creators Match',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: filteredCreators.map((creator) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(creator.avatar),
              ),
              title: Text(creator.username, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(
                creator.bio,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreatorProfileView(username: creator.username)),
                );
              },
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],

        if (filteredPrompts.isNotEmpty) ...[
          Text(
            'Prompts Match',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: filteredPrompts.map((prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPromptListItem(prompt),
            )).toList(),
          ),
        ],
      ],
    );
  }

  // Display prompt detail dialog with high aesthetics
  void _showPromptDetailDialog(BuildContext context, PromptItem prompt) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: AnzorCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                          child: Image.network(
                            prompt.image,
                            height: 200, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12, right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundImage: NetworkImage(prompt.authorAvatar.isNotEmpty
                                    ? prompt.authorAvatar
                                    : 'https://api.dicebear.com/7.x/bottts/png?seed=${prompt.author}'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                prompt.author,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                prompt.style,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.brandOrange,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            prompt.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prompt.prompt,
                            style: GoogleFonts.inter(
                              fontSize: 12.5, height: 1.5, color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnzorButton(
                                radius: 14, height: 38,
                                gradient: AppTheme.brandGradient,
                                glowColor: AppTheme.brandOrange,
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: prompt.prompt));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Prompt copied to clipboard!',
                                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                                      backgroundColor: AppTheme.brandOrange,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Copy Prompt',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}
