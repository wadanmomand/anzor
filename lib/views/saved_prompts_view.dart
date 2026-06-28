import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class SavedPromptsView extends StatefulWidget {
  const SavedPromptsView({super.key});

  @override
  State<SavedPromptsView> createState() => _SavedPromptsViewState();
}

class _SavedPromptsViewState extends State<SavedPromptsView> {
  bool _isSearching = false;
  String _searchQuery = '';
  String _activeFilter = 'All';
  String _sortBy = 'Date'; // Date, Title, Score
  bool _isMultiSelect = false;
  final Set<String> _selectedPromptIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<String> _filters = [
    'All', 'Favorites', 'Midjourney', 'ChatGPT', 'Flux', 'Image', 'Video', 'Coding', 'Marketing'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    // Filter list
    List<PromptItem> list = appState.savedPrompts;

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.prompt.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.author.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_activeFilter != 'All') {
      if (_activeFilter == 'Favorites') {
        // Assume prompts with likes > 50 or custom logic are favorites
        list = list.where((p) => p.likes > 40).toList();
      } else {
        list = list.where((p) =>
          p.style.toLowerCase().contains(_activeFilter.toLowerCase()) ||
          p.category.toLowerCase().contains(_activeFilter.toLowerCase())
        ).toList();
      }
    }

    // Sort list
    if (_sortBy == 'Title') {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'Score') {
      // Score represents likes count in this model context
      list.sort((a, b) => b.likes.compareTo(a.likes));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 200, height: 200,
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
              SliverToBoxAdapter(child: SizedBox(height: topPad + 120)),

              // Smart Summary Hero Card
              if (appState.savedPrompts.isNotEmpty && !_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildSmartSummaryCard(appState),
                  ),
                ),

              // Filter Chips Scrollbar
              if (appState.savedPrompts.isNotEmpty && !_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              setState(() => _activeFilter = filter);
                              HapticFeedback.selectionClick();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Prompt list or Empty state
              list.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = list[index];
                            final isSel = _selectedPromptIds.contains(item.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSavedPromptCard(item, isSel, appState),
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    ),
            ],
          ),

          // Glass Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildGlassHeader(topPad),
          ),

          // Sticky Bottom Multi-Select Actions panel
          if (_isMultiSelect && _selectedPromptIds.isNotEmpty)
            Positioned(
              bottom: 20, left: 16, right: 16,
              child: _buildMultiSelectBar(appState),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Glass Pinned Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassHeader(double topPad) {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Prompts',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                          ),
                        ),
                        Text(
                          'Your personal AI prompt library.',
                          style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
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
                  IconButton(
                    icon: Icon(_isMultiSelect ? Icons.library_add_check_rounded : Icons.checklist_rounded,
                        color: _isMultiSelect ? AppTheme.brandOrange : Colors.white60, size: 20),
                    onPressed: () {
                      setState(() {
                        _isMultiSelect = !_isMultiSelect;
                        _selectedPromptIds.clear();
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort_rounded, color: Colors.white60, size: 20),
                    color: const Color(0xFF131024),
                    onSelected: (val) {
                      setState(() => _sortBy = val);
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Date', child: Text('Sort by Saved Date', style: TextStyle(color: Colors.white, fontSize: 13))),
                      const PopupMenuItem(value: 'Title', child: Text('Sort by Title', style: TextStyle(color: Colors.white, fontSize: 13))),
                      const PopupMenuItem(value: 'Score', child: Text('Sort by Quality Score', style: TextStyle(color: Colors.white, fontSize: 13))),
                    ],
                  ),
                ],
              ),
              if (_isSearching) ...[
                const SizedBox(height: 10),
                AnzorInput(
                  controller: _searchController,
                  hintText: 'Search title, prompt keywords...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Smart Summary Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSmartSummaryCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandOrange.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryStat('Saved', '${appState.savedPrompts.length}', Icons.bookmark_outline_rounded),
          _summaryStat('Collections', '4', Icons.folder_open_rounded),
          _summaryStat('Top Tag', 'Midjourney', Icons.auto_awesome_rounded),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.brandOrange),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Saved Prompt Card Build
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSavedPromptCard(PromptItem item, bool isSel, AppState appState) {
    return GestureDetector(
      onTap: () {
        if (_isMultiSelect) {
          setState(() {
            if (isSel) {
              _selectedPromptIds.remove(item.id);
            } else {
              _selectedPromptIds.add(item.id);
            }
          });
        } else {
          // Open details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing prompt detail: ${item.title}')),
          );
        }
      },
      child: AnzorCard(
        padding: const EdgeInsets.all(12),
        borderColor: isSel ? AppTheme.brandOrange : const Color(0x1BFFFFFF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isMultiSelect) ...[
              Checkbox(
                value: isSel,
                activeColor: AppTheme.brandOrange,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedPromptIds.add(item.id);
                    } else {
                      _selectedPromptIds.remove(item.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 4),
            ],

            // Mini cover preview
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.image,
                width: 60, height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60, height: 60,
                  color: Colors.white.withValues(alpha: 0.05),
                  child: const Icon(Icons.image_outlined, color: Colors.white24, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.style,
                        style: GoogleFonts.inter(fontSize: 8.5, color: AppTheme.brandOrange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.prompt,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, height: 1.4),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'by ${item.author}',
                        style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: item.prompt));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Prompt copied!'), duration: Duration(seconds: 1)),
                              );
                              HapticFeedback.lightImpact();
                            },
                            child: const Icon(Icons.copy_rounded, size: 14, color: Colors.white54),
                          ),
                          GestureDetector(
                            onTap: () {
                              appState.toggleBookmark(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Removed from Saved Prompts.')),
                              );
                              HapticFeedback.mediumImpact();
                            },
                            child: const Icon(Icons.delete_outline_rounded, size: 15, color: Colors.redAccent),
                          ),
                        ],
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Floating Multi-Select Bottom Bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMultiSelectBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedPromptIds.length} Selected',
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: () {
                  final ids = List<String>.from(_selectedPromptIds);
                  for (final id in ids) {
                    appState.toggleBookmarkSocial(id);
                  }
                  setState(() {
                    _selectedPromptIds.clear();
                    _isMultiSelect = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selected prompts deleted.')),
                  );
                },
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 16),
                label: Text('Delete', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Simulate export
                  Clipboard.setData(ClipboardData(
                    text: appState.savedPrompts
                        .where((p) => _selectedPromptIds.contains(p.id))
                        .map((p) => '${p.title}:\n${p.prompt}')
                        .join('\n\n'),
                  ));
                  setState(() {
                    _selectedPromptIds.clear();
                    _isMultiSelect = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selected prompts copied to clipboard!')),
                  );
                },
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 14),
                label: Text('Export', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: AppTheme.brandOrange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'You haven\'t saved any prompts yet',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore the prompt marketplace to save outstanding prompts into your library workspace.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5, color: Colors.white.withValues(alpha: 0.4), height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
