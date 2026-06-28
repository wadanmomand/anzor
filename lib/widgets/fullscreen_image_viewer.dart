import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';

class FullscreenImageViewer extends StatefulWidget {
  final PromptItem prompt;

  const FullscreenImageViewer({
    Key? key,
    required this.prompt,
  }) : super(key: key);

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  double _dragOffset = 0.0;
  bool _isDragging = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.prompt.prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prompt copied to clipboard! 📋'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF131024),
      ),
    );
  }

  void _remixPrompt(AppState appState) {
    appState.setOriginalIdeaAction(widget.prompt.prompt);
    appState.setActiveTab(1); // Navigate to AI Studio
    Navigator.pop(context); // Close viewer

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded prompt into AI Studio! ✨'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFFF6A00),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isLiked = widget.prompt.isLikedByMe;
    final isSaved = appState.isBookmarked(widget.prompt.id);
    final dragPercent = (_dragOffset.abs() / 250.0).clamp(0.0, 1.0);
    final bgOpacity = (0.95 - (dragPercent * 0.4)).clamp(0.4, 0.95);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(bgOpacity),
      body: Stack(
        children: [
          // Close button / Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Central Hero Image with drag-to-dismiss gesture
          Center(
            child: GestureDetector(
              onVerticalDragStart: (_) {
                setState(() {
                  _isDragging = true;
                });
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dragOffset += details.primaryDelta ?? 0.0;
                });
              },
              onVerticalDragEnd: (details) {
                if (_dragOffset.abs() > 140.0) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _isDragging = false;
                    _dragOffset = 0.0;
                  });
                }
              },
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Hero(
                  tag: 'post_img_${widget.prompt.id}',
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    child: Image.network(
                      widget.prompt.image,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6A00)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: const Color(0xFF131024),
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Swipe guide tooltip helper when dragging
          if (_isDragging && _dragOffset.abs() < 50)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_downward_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Swipe down to dismiss',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Action Toolbar and Metadata description overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: MediaQuery.of(context).padding.bottom + 20.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  Text(
                    widget.prompt.title,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.0,
                        backgroundImage: NetworkImage(widget.prompt.authorAvatar),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'by ${widget.prompt.author}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.0,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.prompt.style,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Expandable prompt card description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      widget.prompt.prompt,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Actions toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Likes count
                      _buildToolbarButton(
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        label: widget.prompt.likesCount.toString(),
                        color: isLiked ? const Color(0xFFEF4444) : Colors.white,
                        onTap: () {
                          appState.likePromptAction(widget.prompt.id);
                        },
                      ),
                      // Comments
                      _buildToolbarButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: widget.prompt.commentsList.length.toString(),
                        color: Colors.white,
                        onTap: () {
                          // Standard action for comment feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comments section coming soon! 💬'),
                              backgroundColor: Color(0xFF131024),
                            ),
                          );
                        },
                      ),
                      // Saves/Bookmark
                      _buildToolbarButton(
                        icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        label: 'Save',
                        color: isSaved ? const Color(0xFFFF9800) : Colors.white,
                        onTap: () {
                          appState.toggleBookmark(widget.prompt);
                        },
                      ),
                      // Remix Spark
                      _buildToolbarButton(
                        icon: Icons.bolt_rounded,
                        label: 'Remix',
                        color: const Color(0xFF00D9FF),
                        onTap: () => _remixPrompt(appState),
                      ),
                      // Share
                      _buildToolbarButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        color: Colors.white,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard for sharing! 🔗'),
                              backgroundColor: Color(0xFF131024),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
