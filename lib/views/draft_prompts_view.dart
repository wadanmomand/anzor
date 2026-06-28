import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class DraftPromptsView extends StatefulWidget {
  const DraftPromptsView({super.key});
  @override
  State<DraftPromptsView> createState() => _DraftPromptsViewState();
}

class _DraftPromptsViewState extends State<DraftPromptsView>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'All';
  bool _isMultiSelect = false;
  final Set<int> _selectedDrafts = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;

  final List<String> _filters = [
    'All', 'Recently Edited', 'Favorites', 'Ready to Publish',
    'Needs Review', 'Image', 'Video', 'Text', 'ChatGPT', 'Midjourney',
  ];

  final List<Map<String, dynamic>> _drafts = [
    {
      'title': 'Cyberpunk Neon Alley v2',
      'preview': 'A futuristic alley with neon reflections, rain, volumetric lights and...',
      'model': 'Midjourney v6',
      'category': 'Image',
      'lastEdited': '2 min ago',
      'wordCount': 142,
      'completion': 0.88,
      'status': 'Ready to Publish',
      'statusColor': const Color(0xFF00E5A0),
      'isFavorite': true,
      'autoSaved': true,
    },
    {
      'title': 'Galaxy Nebula Composition',
      'preview': 'Vast cosmic nebula with glowing star clusters, deep space atmosphere...',
      'model': 'Flux.1 Pro',
      'category': 'Image',
      'lastEdited': '1 hour ago',
      'wordCount': 98,
      'completion': 0.55,
      'status': 'In Progress',
      'statusColor': AppTheme.brandOrange,
      'isFavorite': false,
      'autoSaved': true,
    },
    {
      'title': 'Product Launch Email Template',
      'preview': 'Write a compelling product launch email for an AI startup that...',
      'model': 'GPT-4o',
      'category': 'Text',
      'lastEdited': '3 hours ago',
      'wordCount': 67,
      'completion': 0.3,
      'status': 'Needs Review',
      'statusColor': const Color(0xFFFFC107),
      'isFavorite': false,
      'autoSaved': false,
    },
    {
      'title': 'Cinematic Portrait Lighting',
      'preview': 'Ultra-realistic portrait with rembrandt lighting, studio setup...',
      'model': 'Midjourney v6',
      'category': 'Image',
      'lastEdited': 'Yesterday',
      'wordCount': 115,
      'completion': 0.72,
      'status': 'AI Review Pending',
      'statusColor': const Color(0xFF00D9FF),
      'isFavorite': true,
      'autoSaved': true,
    },
    {
      'title': 'Mobile App UI Redesign Brief',
      'preview': 'Design a modern dark-themed mobile application interface with...',
      'model': 'Claude 3.5 Sonnet',
      'category': 'Text',
      'lastEdited': '2 days ago',
      'wordCount': 203,
      'completion': 0.95,
      'status': 'Ready to Publish',
      'statusColor': const Color(0xFF00E5A0),
      'isFavorite': false,
      'autoSaved': true,
    },
  ];

  final List<Map<String, dynamic>> _aiSuggestions = [
    {'icon': Icons.auto_fix_high_rounded, 'title': 'Improve quality', 'text': '"Cyberpunk Neon Alley v2" is missing lighting specifics. Add: golden hour, f/1.4 aperture.', 'color': AppTheme.brandOrange},
    {'icon': Icons.model_training_rounded, 'title': 'Better model', 'text': 'Try Flux.1 Pro for "Galaxy Nebula" — 38% higher scores for space prompts.', 'color': const Color(0xFF00D9FF)},
    {'icon': Icons.score_rounded, 'title': 'Ready to Publish', 'text': '"Mobile App UI Brief" has a 95% readiness score. Publish now for best engagement.', 'color': const Color(0xFF00E5A0)},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() => _isSearchFocused = _searchFocus.hasFocus));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent]),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 110)),

              // ─── OVERVIEW HERO ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildOverviewCard(),
                ),
              ),

              // ─── AUTO SAVE STATUS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AnzorCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E5A0)),
                        ),
                        const SizedBox(width: 10),
                        Text('All changes auto-saved', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                        const Spacer(),
                        const Icon(Icons.cloud_done_rounded, color: Color(0xFF00E5A0), size: 16),
                        const SizedBox(width: 4),
                        Text('Synced', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF00E5A0))),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── AI DRAFT ASSISTANT ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13),
                    const SizedBox(width: 6),
                    Text('AI DRAFT ASSISTANT', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _aiSuggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final s = _aiSuggestions[i];
                      final color = s['color'] as Color;
                      return Container(
                        width: 260,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(s['icon'] as IconData, color: color, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(s['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
                                  Text(s['text'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), height: 1.3), maxLines: 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ─── DRAFT LIST ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Text('${_drafts.length} DRAFTS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                      const Spacer(),
                      if (_isMultiSelect)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedDrafts.length == _drafts.length) {
                                _selectedDrafts.clear();
                              } else {
                                _selectedDrafts.addAll(List.generate(_drafts.length, (i) => i));
                              }
                            });
                          },
                          child: Text('Select All', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.brandOrange, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, _isMultiSelect ? 100 : 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDraftCard(i, _drafts[i]),
                    ),
                    childCount: _drafts.length,
                  ),
                ),
              ),
            ],
          ),

          // Glass Header
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),

          // Multi-select bar
          if (_isMultiSelect && _selectedDrafts.isNotEmpty)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildMultiSelectBar()),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 10),
          color: const Color(0xD506050C),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Draft Prompts', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('Continue creating without losing your ideas.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isMultiSelect ? Icons.close_rounded : Icons.checklist_rounded, color: Colors.white70, size: 20),
                    onPressed: () { setState(() { _isMultiSelect = !_isMultiSelect; _selectedDrafts.clear(); }); },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _isSearchFocused ? AppTheme.brandOrange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search drafts...',
                    hintStyle: GoogleFonts.inter(fontSize: 12.5, color: Colors.white24),
                    prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Colors.white30),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    return AnzorChip(label: f, isSelected: _activeFilter == f, onTap: () { setState(() => _activeFilter = f); HapticFeedback.selectionClick(); });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final stats = [
      {'label': 'Total', 'value': '${_drafts.length}', 'color': AppTheme.brandOrange},
      {'label': 'Recent', 'value': '2', 'color': const Color(0xFF00D9FF)},
      {'label': 'Ready', 'value': '2', 'color': const Color(0xFF00E5A0)},
      {'label': 'In Progress', 'value': '1', 'color': const Color(0xFFFFC107)},
      {'label': 'AI Pending', 'value': '1', 'color': const Color(0xFF7C4DFF)},
    ];
    return AnzorCard(
      padding: const EdgeInsets.all(16),
      addGlow: true,
      glowColor: AppTheme.electricBlue,
      backgroundGradientColors: [AppTheme.electricBlue.withValues(alpha: 0.07), Colors.transparent],
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppTheme.electricBlue, size: 16),
              const SizedBox(width: 8),
              Text('DRAFT OVERVIEW', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.electricBlue, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: stats.map((s) {
              final color = s['color'] as Color;
              return Expanded(
                child: Column(
                  children: [
                    Text(s['value'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                    Text(s['label'] as String, style: GoogleFonts.inter(fontSize: 9, color: Colors.white30)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(int index, Map<String, dynamic> draft) {
    final isSelected = _selectedDrafts.contains(index);
    final completion = draft['completion'] as double;
    final statusColor = draft['statusColor'] as Color;

    return GestureDetector(
      onTap: () {
        if (_isMultiSelect) {
          setState(() { isSelected ? _selectedDrafts.remove(index) : _selectedDrafts.add(index); });
          HapticFeedback.selectionClick();
        }
      },
      onLongPress: () {
        if (!_isMultiSelect) {
          setState(() { _isMultiSelect = true; _selectedDrafts.add(index); });
          HapticFeedback.mediumImpact();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandOrange.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.4)) : null,
        ),
        child: AnzorCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isMultiSelect)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.brandOrange : Colors.transparent,
                          border: Border.all(color: isSelected ? AppTheme.brandOrange : Colors.white30),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                      ),
                    ),
                  Expanded(
                    child: Text(draft['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (draft['isFavorite'] == true)
                    const Icon(Icons.bookmark_rounded, color: AppTheme.brandOrange, size: 16),
                ],
              ),
              const SizedBox(height: 6),
              Text(draft['preview'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white38, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(
                children: [
                  _tag(draft['model'] as String, AppTheme.brandOrange),
                  const SizedBox(width: 6),
                  _tag(draft['category'] as String, AppTheme.electricBlue),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(draft['status'] as String, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${(completion * 100).round()}% complete', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
                            const Spacer(),
                            Text(draft['lastEdited'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: completion,
                            backgroundColor: Colors.white.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (draft['autoSaved'] == true) ...[
                    const Icon(Icons.cloud_done_rounded, color: Color(0xFF00E5A0), size: 12),
                    const SizedBox(width: 4),
                    Text('Auto-saved', style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF00E5A0))),
                    const SizedBox(width: 8),
                    Text('•', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.2))),
                    const SizedBox(width: 8),
                  ],
                  Text('${draft['wordCount']} words', style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
                  const Spacer(),
                  Row(
                    children: [
                      _iconAction(Icons.edit_rounded, () {}),
                      const SizedBox(width: 4),
                      _iconAction(Icons.copy_rounded, () {}),
                      const SizedBox(width: 4),
                      _iconAction(Icons.more_horiz_rounded, () => _showDraftActions(draft)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _iconAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)),
        child: Icon(icon, color: Colors.white38, size: 14),
      ),
    );
  }

  Widget _buildMultiSelectBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          color: const Color(0xEA06050C),
          child: Row(
            children: [
              Text('${_selectedDrafts.length} selected', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              const Spacer(),
              _multiAction(Icons.publish_rounded, 'Publish', AppTheme.brandOrange),
              const SizedBox(width: 8),
              _multiAction(Icons.drive_file_move_rounded, 'Move', AppTheme.electricBlue),
              const SizedBox(width: 8),
              _multiAction(Icons.delete_outline_rounded, 'Delete', const Color(0xFFFF4D6A)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _multiAction(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  void _showDraftActions(Map<String, dynamic> draft) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF0F0E1A), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(draft['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 16),
            ...[
              _sheetAction(Icons.edit_rounded, 'Continue Editing', Colors.white70, null),
              _sheetAction(Icons.remove_red_eye_rounded, 'Preview', Colors.white70, null),
              _sheetAction(Icons.copy_rounded, 'Duplicate', Colors.white70, null),
              _sheetAction(Icons.drive_file_move_rounded, 'Move to Collection', AppTheme.electricBlue, null),
              _sheetAction(Icons.download_rounded, 'Export', AppTheme.brandOrange, null),
              _sheetAction(Icons.delete_outline_rounded, 'Delete', const Color(0xFFFF4D6A), null),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sheetAction(IconData icon, String label, Color color, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
      dense: true,
      onTap: () { Navigator.pop(context); HapticFeedback.lightImpact(); },
    );
  }
}
