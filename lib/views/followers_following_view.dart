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

class FollowersFollowingView extends StatefulWidget {
  final String initialTab; // 'Followers' or 'Following'
  const FollowersFollowingView({super.key, this.initialTab = 'Followers'});

  @override
  State<FollowersFollowingView> createState() => _FollowersFollowingViewState();
}

class _FollowersFollowingViewState extends State<FollowersFollowingView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  String _searchQuery = '';
  String _activeChip = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _chips = ['All', 'Verified', 'Top Creators', 'AI Experts', 'Online'];

  final List<Map<String, dynamic>> _allCreators = [
    {
      'username': 'NeonKitten',
      'displayName': 'Sarah Jennings',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
      'rank': '#45',
      'reputation': '98.5%',
      'followers': '1.2K',
      'tags': ['Midjourney', 'Flux'],
      'isVerified': true,
      'isFollowing': true,
      'isFollower': true,
      'active': 'Active 5m ago'
    },
    {
      'username': 'usman',
      'displayName': 'Usman Al-Farsi',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
      'rank': '#12',
      'reputation': '99.4%',
      'followers': '3.4K',
      'tags': ['Claude', 'GPT-4'],
      'isVerified': true,
      'isFollowing': true,
      'isFollower': false,
      'active': 'Active 2h ago'
    },
    {
      'username': 'RetroRider',
      'displayName': 'Derrick Vance',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
      'rank': '#102',
      'reputation': '92.1%',
      'followers': '820',
      'tags': ['Stable Diffusion'],
      'isVerified': false,
      'isFollowing': false,
      'isFollower': true,
      'active': 'Active 1d ago'
    },
    {
      'username': 'CyberBard',
      'displayName': 'Evelyn Gray',
      'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=CyberBard',
      'rank': '#89',
      'reputation': '96.2%',
      'followers': '1.5K',
      'tags': ['Marketing', 'Copywriting'],
      'isVerified': true,
      'isFollowing': false,
      'isFollower': false,
      'active': 'Active 10m ago'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab == 'Following' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;
    final myProfile = appState.currentUserProfile;

    // Filter creators based on tabs and chips
    List<Map<String, dynamic>> displayed = [];
    if (_tabController.index == 0) {
      displayed = _allCreators.where((c) => c['isFollower'] == true).toList();
    } else if (_tabController.index == 1) {
      displayed = _allCreators.where((c) => c['isFollowing'] == true).toList();
    } else {
      displayed = _allCreators.where((c) => c['isFollower'] == true && c['isFollowing'] == true).toList();
    }

    if (_searchQuery.isNotEmpty) {
      displayed = displayed.where((c) =>
        c['username'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c['displayName'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_activeChip != 'All') {
      if (_activeChip == 'Verified') {
        displayed = displayed.where((c) => c['isVerified'] == true).toList();
      } else if (_activeChip == 'Top Creators') {
        displayed = displayed.where((c) => c['rank'].toString().startsWith('#1') || c['rank'].toString().startsWith('#2')).toList();
      } else if (_activeChip == 'AI Experts') {
        displayed = displayed.where((c) => (c['tags'] as List).contains('Midjourney') || (c['tags'] as List).contains('Claude')).toList();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              // ─── 1. PROFILE SUMMARY CARD ───
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppTheme.brandOrange.withValues(alpha: 0.15),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(myProfile.avatar),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myProfile.username,
                                  style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  'Global Rank: #456  •  Elite Tier',
                                  style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _statSummary('Followers', '${myProfile.followers.length}'),
                              const SizedBox(width: 14),
                              _statSummary('Following', '${myProfile.following.length}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── 2. SUGGESTED CREATORS CAROUSEL ───
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'SUGGESTED CREATORS FOR YOU',
                            style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 105,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _allCreators.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final item = _allCreators[index];
                              return _buildSuggestedCard(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── 3. SMART CHIP FILTERS ───
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _chips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final label = _chips[index];
                          final isSel = _activeChip == label;
                          return AnzorChip(
                            label: label,
                            isSelected: isSel,
                            onTap: () {
                              setState(() => _activeChip = label);
                              HapticFeedback.selectionClick();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // ─── 4. USERS GRID / LIST ───
              displayed.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final creator = displayed[index];
                            return _buildUserCard(creator);
                          },
                          childCount: displayed.length,
                        ),
                      ),
                    ),
            ],
          ),

          // Glass Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildFrostedHeader(topPad),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Frosted Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFrostedHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 8),
          color: const Color(0xD206050C),
          child: Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Creator Network',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                          ),
                        ),
                        Text(
                          'Grow your AI connection network.',
                          style: GoogleFonts.inter(
                            fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: Colors.white60, size: 20),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
              if (_isSearching) ...[
                const SizedBox(height: 10),
                AnzorInput(
                  controller: _searchController,
                  hintText: 'Search username or display name...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
              const SizedBox(height: 8),

              // Animated Segmented controls
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.brandOrange,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.white30,
                labelColor: AppTheme.brandOrange,
                onTap: (index) {
                  setState(() {});
                  HapticFeedback.selectionClick();
                },
                tabs: const [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                  Tab(text: 'Mutual'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Creator card widgets
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSuggestedCard(Map<String, dynamic> item) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(item['avatar']!),
          ),
          const SizedBox(height: 6),
          Text(
            item['username']!,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            item['tags'].first,
            style: GoogleFonts.inter(fontSize: 8.5, color: Colors.white30),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 22,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandOrange,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                setState(() => item['isFollowing'] = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Following ${item['username']}')),
                );
              },
              child: Text('Follow', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> creator) {
    final isFollowing = creator['isFollowing'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatorProfileView(username: creator['username']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnzorCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(creator['avatar']!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          creator['displayName']!,
                          style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (creator['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, color: AppTheme.brandOrange, size: 12),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${creator['username']}  •  Rank: ${creator['rank']}',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: (creator['tags'] as List).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(4)),
                        child: Text(tag, style: GoogleFonts.inter(fontSize: 7.5, color: Colors.white54)),
                      )).toList(),
                    ),
                  ],
                ),
              ),

              // Follow/Following Action Button
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isFollowing ? Colors.white24 : AppTheme.brandOrange, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      creator['isFollowing'] = !isFollowing;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isFollowing ? Colors.white70 : AppTheme.brandOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statSummary(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white38)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandOrange.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.people_outline_rounded, size: 36, color: AppTheme.brandOrange),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your filters or search keywords.',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white30),
            ),
          ],
        ),
      ),
    );
  }
}
