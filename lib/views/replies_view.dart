import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class RepliesView extends StatefulWidget {
  final CommentItem parentComment;
  final String promptId;

  const RepliesView({
    super.key,
    required this.parentComment,
    required this.promptId,
  });

  @override
  State<RepliesView> createState() => _RepliesViewState();
}

class _RepliesViewState extends State<RepliesView> {
  final TextEditingController _replyController = TextEditingController();
  String _activeFilter = 'All';
  bool _showAISummary = true;
  final List<Map<String, dynamic>> _simulatedReplies = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with a couple of realistic nested replies for simulation
    _simulatedReplies.addAll([
      {
        'id': 'rep_1',
        'author': 'usman',
        'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=usman',
        'content': 'Volumetric fog in Midjourney is highly dependent on combining "depth of field" with "dust particles in air". Try using a lower aspect ratio too.',
        'timestamp': '45m ago',
        'likes': 8,
        'isHelpful': true,
        'level': 'Elite Creator',
        'replies': [
          {
            'id': 'rep_1_1',
            'author': 'RetroRider',
            'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=RetroRider',
            'content': 'That worked perfectly! Thanks for the tip usman.',
            'timestamp': '30m ago',
            'likes': 2,
            'isHelpful': false,
            'level': 'Creator',
          }
        ]
      },
      {
        'id': 'rep_2',
        'author': 'NeonKitten',
        'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=NeonKitten',
        'content': 'I also recommend adding a quality scale constraint like "--q 2". Keeps details clean.',
        'timestamp': '20m ago',
        'likes': 5,
        'isHelpful': false,
        'level': 'Elite Creator',
        'replies': []
      }
    ]);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _addReply(String content) {
    if (content.trim().isEmpty) return;
    setState(() {
      _simulatedReplies.add({
        'id': 'rep_user_${DateTime.now().millisecondsSinceEpoch}',
        'author': 'you',
        'avatar': 'https://api.dicebear.com/7.x/bottts/png?seed=you',
        'content': content.trim(),
        'timestamp': 'Just now',
        'likes': 0,
        'isHelpful': false,
        'level': 'Creator',
        'replies': []
      });
      _replyController.clear();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

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

          // Scrollable Thread list
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 70)),

              // ─── 1. PARENT COMMENT CARD ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORIGINAL DISCUSSION ROOT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnzorCard(
                        padding: const EdgeInsets.all(14),
                        radius: 18,
                        borderColor: AppTheme.brandOrange.withValues(alpha: 0.25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(widget.parentComment.authorAvatar.isNotEmpty
                                  ? widget.parentComment.authorAvatar
                                  : 'https://api.dicebear.com/7.x/bottts/png?seed=${widget.parentComment.author}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.parentComment.author,
                                        style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        widget.parentComment.timestamp,
                                        style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.parentComment.content,
                                    style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── 2. AI CONVERSATION SUMMARY ───
              if (_showAISummary)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AnzorCard(
                      padding: const EdgeInsets.all(12),
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.brandGold),
                              const SizedBox(width: 6),
                              Text(
                                'AI Thread Insights',
                                style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.brandGold),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _showAISummary = false),
                                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white30),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Community consensus recommends lower aspect ratios and adding volumetric parameters. usman provided the most helpful layout tip below.',
                            style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white54, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── 3. SMART FILTERS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final filters = ['All Replies', 'Top Rated', 'Creator Only'];
                        final label = filters[idx];
                        final isSel = _activeFilter == label;
                        return AnzorChip(
                          label: label,
                          isSelected: isSel,
                          onTap: () {
                            setState(() => _activeFilter = label);
                            HapticFeedback.selectionClick();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ─── 4. REPLIES THREAD ───
              _simulatedReplies.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reply = _simulatedReplies[index];
                            return _buildReplyThreadBlock(reply);
                          },
                          childCount: _simulatedReplies.length,
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

          // Sticky composer
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildStickyComposer(),
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
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD206050C),
          child: Row(
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
                    'Replies',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  Text(
                    'Continue the discussion thread.',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white60, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thread link copied!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Indented Reply Thread Blocks
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReplyThreadBlock(Map<String, dynamic> reply) {
    final nested = reply['replies'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReplyCard(reply, false),
        if (nested.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connecting thread line indicator
                Container(
                  width: 1.5,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12, top: 4),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: Column(
                    children: nested.map((subReply) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildReplyCard(subReply, true),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> reply, bool isNested) {
    final isHelpful = reply['isHelpful'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isHelpful ? AppTheme.brandOrange.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHelpful ? AppTheme.brandOrange.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(reply['avatar']!),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply['author']!,
                        style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (isHelpful) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(color: const Color(0xFF00FF7F).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text('AI HELPFUL', style: GoogleFonts.inter(fontSize: 7, color: const Color(0xFF00FF7F), fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const Spacer(),
                      Text(reply['timestamp']!, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reply['content']!,
                    style: GoogleFonts.inter(fontSize: 11.5, height: 1.4, color: const Color(0xDEFFFFFF)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border_rounded, size: 11, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text('${reply['likes']}', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
                      const SizedBox(width: 16),
                      Text('Reply', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
                    ],
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
  // Sticky Composer
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStickyComposer() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF0C0A15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Add a reply...',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 16),
                        onPressed: () {
                          setState(() {
                            _replyController.text = 'Interesting perspective. Suggest scaling focal elements!';
                          });
                          HapticFeedback.lightImpact();
                        },
                        tooltip: 'AI Reply Assistant',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppTheme.brandOrange, size: 18),
                onPressed: () => _addReply(_replyController.text),
              ),
            ],
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
              child: const Icon(Icons.forum_outlined, size: 36, color: AppTheme.brandOrange),
            ),
            const SizedBox(height: 16),
            Text(
              'No replies yet',
              style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to continue this discussion thread!',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white30),
            ),
          ],
        ),
      ),
    );
  }
}
