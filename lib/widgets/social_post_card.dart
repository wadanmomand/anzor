import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../views/creator_profile_view.dart';
import '../views/replies_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'glass_widgets.dart';
import 'creator_level_badge.dart';
import 'fullscreen_image_viewer.dart';

class SocialPostCard extends StatefulWidget {
  final PromptItem prompt;
  final Duration animDelay;

  const SocialPostCard({
    super.key,
    required this.prompt,
    this.animDelay = Duration.zero,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;
  bool _showHeartOverlay = false;
  bool _showInsights = false;
  String _activeCommentFilter = 'All';

  // Staggered entry animation controller and animations
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    
    // Double tap heart anim
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartAnimController, curve: Curves.easeInOut));

    // Entry slide and fade animations
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Trigger entry animation after staggered delay
    if (widget.animDelay == Duration.zero) {
      _entryController.forward();
    } else {
      Future.delayed(widget.animDelay, () {
        if (mounted) _entryController.forward();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _heartAnimController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _openCommentsBottomSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final latestPrompt = appState.communityPrompts.firstWhere(
              (p) => p.id == widget.prompt.id,
              orElse: () => widget.prompt,
            );

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                margin: const EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  color: const Color(0xEB0C0A15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pull indicator
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Discussion Hub',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white,
                                ),
                              ),
                              Text(
                                '${latestPrompt.commentsList.length} comments active',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5, color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0x1BFFFFFF), height: 1),

                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Compact Prompt Preview Header Card
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: AnzorCard(
                                padding: const EdgeInsets.all(10),
                                radius: 14,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        latestPrompt.image,
                                        width: 48, height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 48, height: 48,
                                          color: Colors.white10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            latestPrompt.title,
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'by ${latestPrompt.author} • ${latestPrompt.style}',
                                            style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.star_rounded, color: AppTheme.brandOrange, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      '98%',
                                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Community Insights Toggle block
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _showInsights = !_showInsights;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brandOrange.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.12)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppTheme.brandOrange),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'AI-Generated Feed Feedback Summary',
                                          style: GoogleFonts.spaceGrotesk(fontSize: 11.5, color: AppTheme.brandOrange, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Icon(
                                        _showInsights ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                        size: 16, color: AppTheme.brandOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (_showInsights)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: AnzorCard(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Key Feedback highlights:',
                                        style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '• 84% of reviews praise the camera aspect lighting setup.\n• Suggestions relate to volumetric render enhancements.',
                                        style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white54, height: 1.45),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // 3. FiltersChips row
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: SizedBox(
                                height: 32,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 4,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final filters = ['All', 'Feedback', 'Questions', 'Pinned'];
                                    final label = filters[idx];
                                    final isSel = _activeCommentFilter == label;
                                    return AnzorChip(
                                      label: label,
                                      isSelected: isSel,
                                      onTap: () {
                                        setModalState(() {
                                          _activeCommentFilter = label;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                            // 4. Comments list implementation
                            latestPrompt.commentsList.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.brandOrange.withValues(alpha: 0.5), size: 36),
                                          const SizedBox(height: 12),
                                          Text('No comments yet', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Be the first to share your thoughts!',
                                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16),
                                    itemCount: latestPrompt.commentsList.length,
                                    itemBuilder: (context, index) {
                                      final comment = latestPrompt.commentsList[index];
                                      final isPinned = index == 0; // Simulate first comment as pinned

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isPinned ? AppTheme.brandOrange.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.02),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: isPinned ? AppTheme.brandOrange.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundImage: NetworkImage(comment.authorAvatar.isNotEmpty
                                                    ? comment.authorAvatar
                                                    : 'https://api.dicebear.com/7.x/bottts/png?seed=${comment.author}'),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          comment.author,
                                                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                                        ),
                                                        if (isPinned) ...[
                                                          const SizedBox(width: 6),
                                                          const Icon(Icons.pin_drop_rounded, color: AppTheme.brandOrange, size: 10),
                                                          const SizedBox(width: 2),
                                                          Text('PINNED', style: GoogleFonts.inter(fontSize: 7.5, color: AppTheme.brandOrange, fontWeight: FontWeight.bold)),
                                                        ],
                                                        const Spacer(),
                                                        Text(
                                                          comment.timestamp,
                                                          style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      comment.content,
                                                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: const Color(0xDEFFFFFF)),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.favorite_border_rounded, size: 12, color: Colors.white38),
                                                        const SizedBox(width: 4),
                                                        Text('12', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
                                                        const SizedBox(width: 16),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) => RepliesView(
                                                                  parentComment: comment,
                                                                  promptId: latestPrompt.id,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.reply_rounded, size: 12, color: Colors.white38),
                                                              const SizedBox(width: 4),
                                                              Text('Reply', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
                                                            ],
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
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),

                    // 5. Sticky composer with AI-Suggestion bar
                    const Divider(color: Color(0x1BFFFFFF), height: 1),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF0C0A15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(appState.currentUserProfile.avatar),
                              ),
                              const SizedBox(width: 10),
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
                                          controller: _commentController,
                                          style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                                          decoration: const InputDecoration(
                                            hintText: 'Add a comment...',
                                            hintStyle: TextStyle(color: Colors.white30),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 16),
                                        onPressed: () {
                                          setModalState(() {
                                            _commentController.text = 'The volumetric lighting composition is beautiful. Suggest scaling the focal depth aspect!';
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                        tooltip: 'AI Suggest Reply',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: AppTheme.brandOrange, size: 18),
                                onPressed: () {
                                  final text = _commentController.text.trim();
                                  if (text.isNotEmpty) {
                                    appState.addCommentAction(latestPrompt.id, text);
                                    _commentController.clear();
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showViewPromptBottomSheet(BuildContext context, PromptItem prompt, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            margin: const EdgeInsets.only(top: 80),
            decoration: BoxDecoration(
              color: const Color(0xEB0C0A15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category and actions row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.brandOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.2), width: 0.8),
                        ),
                        child: Text(
                          prompt.category.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 8.5, color: AppTheme.brandOrange, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white60, size: 20),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prompt saved to collection!')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white60, size: 20),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share link generated!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Prompt Title
                  Text(
                    prompt.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metrics Row
                  Row(
                    children: [
                      Text(
                        'by ${prompt.author}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      if (prompt.author == 'usman' || prompt.author == 'NeonKitten')
                        const Icon(Icons.verified_rounded, color: Color(0xFF00D9FF), size: 13),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: AppTheme.brandOrange, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '98.7% Quality Score',
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white54, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Monospace Prompt Container
                  Text(
                    'PROMPT WORKSPACE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
                    ),
                    child: SelectableText(
                      prompt.prompt,
                      style: GoogleFonts.firaCode(
                        fontSize: 12.5, height: 1.5, color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  if (prompt.negativePrompt.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'NEGATIVE PROMPT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.8),
                      ),
                      child: SelectableText(
                        prompt.negativePrompt,
                        style: GoogleFonts.firaCode(
                          fontSize: 11.5, height: 1.45, color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // AI Parameter Badges Grid
                  Text(
                    'AI MODEL SPECIFICATIONS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.3,
                    children: [
                      _buildParamGridTile('Compatible Models', prompt.style),
                      _buildParamGridTile('Camera Layout', prompt.cameraAngle.isNotEmpty ? prompt.cameraAngle : 'Frontal Portrait'),
                      _buildParamGridTile('Lighting Design', prompt.lighting.isNotEmpty ? prompt.lighting : 'Studio Soft Glow'),
                      _buildParamGridTile('Estimated Tokens', '~145 tokens'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Creator Section Card
                  AnzorCard(
                    padding: const EdgeInsets.all(12),
                    radius: 18,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CreatorProfileView(username: prompt.author)),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(prompt.authorAvatar.isNotEmpty
                                ? prompt.authorAvatar
                                : 'https://api.dicebear.com/7.x/bottts/png?seed=${prompt.author}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prompt.author,
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                'AI Prompt Specialization Architect',
                                style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 28,
                          child: AnzorButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CreatorProfileView(username: prompt.author)),
                              );
                            },
                            radius: 8,
                            gradient: const LinearGradient(colors: [Color(0xFF222133), Color(0xFF222133)]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'View',
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: AnzorButton(
                          height: 48,
                          radius: 14,
                          glowColor: AppTheme.brandOrange,
                          gradient: AppTheme.brandGradient,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: prompt.prompt));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Prompt copied to clipboard!')),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Copy Prompt',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandGold, size: 16),
                          label: Text(
                            'Remix Prompt',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: () {
                            appState.setOriginalIdeaAction(prompt.prompt);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Loaded into Studio for Remix!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildParamGridTile(String label, String val) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 360;

    final prompt = appState.communityPrompts.firstWhere(
      (p) => p.id == widget.prompt.id,
      orElse: () => widget.prompt,
    );

    final currentUser = appState.currentUserProfile;
    final creatorStats = appState.getCreatorStats(prompt.author);
    final isMe = prompt.author == currentUser.username;
    final isFollowing = currentUser.following.contains(prompt.author);
    final isLiked = prompt.likesList.contains(currentUser.username);
    final isSaved = prompt.savesList.contains(currentUser.username);

    final int viewsCount = prompt.likes * 12 + 45;
    final int savesCount = prompt.savesList.length + (prompt.likes * 0.15).round();

    final bool isTrending = prompt.likes > 200;
    final bool isMostSaved = savesCount > 30;

    // Apple Fade-In-Up Entry animation wrapper
    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: AnzorCard(
          padding: EdgeInsets.zero,
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatorProfileView(username: prompt.author),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 19,
                        backgroundImage: NetworkImage(prompt.authorAvatar.isNotEmpty
                            ? prompt.authorAvatar
                            : 'https://api.dicebear.com/7.x/bottts/png?seed=${prompt.author}'),
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreatorProfileView(username: prompt.author),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    prompt.author == 'usman' ? 'Usman Ahmed' : prompt.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isCompact ? 12.0 : 13.5,
                                      color: const Color(0xFFF8FAFC),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ),
                              if (prompt.author == 'usman' || prompt.author == 'NeonKitten') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: Color(0xFF00D9FF), size: 14),
                              ],
                              const SizedBox(width: 6),
                              CreatorLevelBadge(
                                level: creatorStats.level,
                                showLabel: false,
                                iconSize: 10.0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '@${prompt.author.toLowerCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMe)
                      ScaleOnPress(
                        onTap: () => appState.toggleFollow(prompt.author),
                        child: Container(
                          height: isCompact ? 26 : 28,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
                          decoration: BoxDecoration(
                            gradient: isFollowing
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFFFF6A00), Color(0xFFFF9800), Color(0xFFFFC107)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: isFollowing ? Colors.white.withOpacity(0.06) : null,
                            borderRadius: BorderRadius.circular(24),
                            border: isFollowing
                                ? Border.all(color: Colors.white.withOpacity(0.12), width: 0.8)
                                : null,
                            boxShadow: isFollowing
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFFF6A00).withOpacity(0.2),
                                      blurRadius: 8.0,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                          ),
                          child: Text(
                            isFollowing ? 'Following ✓' : 'Follow',
                            style: TextStyle(
                              fontSize: isCompact ? 10 : 11,
                              fontWeight: FontWeight.bold,
                              color: isFollowing ? const Color(0xFF94A3B8) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Image Area: 4:5 dominant visual container (Padded for floating design)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenImageViewer(prompt: prompt),
                      ),
                    );
                  },
                  onDoubleTap: () {
                    if (!isLiked) {
                      appState.toggleLikePromptAction(prompt.id);
                    }
                    setState(() {
                      _showHeartOverlay = true;
                    });
                    _heartAnimController.forward(from: 0.0).then((_) {
                      setState(() {
                        _showHeartOverlay = false;
                      });
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        tag: 'post_img_${prompt.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 0.8, // 4:5 aspect ratio
                            child: CachedNetworkImage(
                              imageUrl: prompt.image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: const Color(0xFF131024),
                                highlightColor: const Color(0xFF1D1B36),
                                child: Container(
                                  color: const Color(0xFF131024),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.brandGradient,
                                ),
                                child: const Center(
                                  child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Subtle vertical gradient overlay for image depth
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.4),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Cleaner & smaller overlay badges
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Builder(
                          builder: (context) {
                            final List<Widget> activeBadges = [];
                            if (isTrending) {
                              activeBadges.add(_buildCleanerBadge('Trending', const Color(0xFFFF6A00)));
                            }
                            if (prompt.likes > 150) {
                              activeBadges.add(_buildCleanerBadge('Featured', const Color(0xFF00D9FF)));
                            }
                            if (isMostSaved) {
                              activeBadges.add(_buildCleanerBadge('Most Saved', const Color(0xFFFFC107)));
                            }
                            if (prompt.author == 'usman' || prompt.author == 'NeonKitten') {
                              activeBadges.add(_buildCleanerBadge('Verified Creator', const Color(0xFF00D9FF)));
                            }
                            if ((creatorStats.level == CreatorLevel.pro ||
                                creatorStats.level == CreatorLevel.elite ||
                                creatorStats.level == CreatorLevel.legend) &&
                                !(prompt.author == 'usman' || prompt.author == 'NeonKitten')) {
                              activeBadges.add(_buildCleanerBadge('Pro Creator', const Color(0xFFFF007F)));
                            }

                            final List<Widget> visibleBadges = [];
                            if (activeBadges.length <= 2) {
                              visibleBadges.addAll(activeBadges);
                            } else {
                              visibleBadges.add(activeBadges[0]);
                              final remainingCount = activeBadges.length - 1;
                              visibleBadges.add(_buildCleanerBadge('+$remainingCount', const Color(0xFF94A3B8)));
                            }

                            return Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children: visibleBadges,
                            );
                          }
                        ),
                      ),
                      
                      if (_showHeartOverlay)
                        AnimatedBuilder(
                          animation: _heartScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _heartScale.value,
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 80,
                                shadows: [
                                  Shadow(color: Colors.black38, blurRadius: 16),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Title, description & tags
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 14 : 15,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prompt.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: isCompact ? 11 : 12,
                        height: 1.4,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: prompt.tagsList.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF00D9FF), fontWeight: FontWeight.bold),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Bottom Actions Row: Sleek outline icons, right-side gradient CTA
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 8.0 : 12.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // outline Like
                    ScaleOnPress(
                      onTap: () => appState.toggleLikePromptAction(prompt.id),
                      child: _buildOutlineAction(
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? Colors.redAccent : Colors.white60,
                        count: prompt.likes,
                        isCompact: isCompact,
                      ),
                    ),

                    // outline Comment
                    ScaleOnPress(
                      onTap: () => _openCommentsBottomSheet(context, appState),
                      child: _buildOutlineAction(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: Colors.white60,
                        count: prompt.commentsList.length,
                        isCompact: isCompact,
                      ),
                    ),

                    // outline Views
                    _buildOutlineAction(
                      icon: Icons.remove_red_eye_outlined,
                      color: Colors.white60,
                      count: viewsCount,
                      isCompact: isCompact,
                    ),

                    // outline Save
                    ScaleOnPress(
                      onTap: () => appState.toggleBookmarkSocial(prompt.id),
                      child: _buildOutlineAction(
                        icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? const Color(0xFFFFC107) : Colors.white60,
                        count: savesCount,
                        isCompact: isCompact,
                      ),
                    ),

                     // Remix — AnzorActionButton (icon-only for compact feed rows)
                    AnzorActionButton(
                      icon: Icons.auto_awesome_outlined,
                      label: '',
                      onTap: () {
                        appState.setOriginalIdeaAction(prompt.prompt);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loaded into Studio for Remix!')),
                        );
                      },
                    ),

                    // Share — AnzorActionButton (icon-only for compact feed rows)
                    AnzorActionButton(
                      icon: Icons.ios_share_rounded,
                      label: '',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: prompt.prompt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Prompt copied to share!')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: AnzorButton(
                  height: 46,
                  radius: 16,
                  onPressed: () => _showViewPromptBottomSheet(context, prompt, appState),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'View Prompt',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildOutlineAction({
    required IconData icon,
    required Color color,
    required int count,
    bool isCompact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 2.0 : 4.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: isCompact ? 17 : 19),
          const SizedBox(width: 4),
          Text(
            count > 999 ? '${(count / 1000).toStringAsFixed(1)}K' : count.toString(),
            style: GoogleFonts.inter(fontSize: isCompact ? 9.5 : 10.5, color: Colors.white.withOpacity(0.55), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanerBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
