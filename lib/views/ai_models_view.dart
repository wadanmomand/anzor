import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class AiModelsView extends StatefulWidget {
  const AiModelsView({super.key});
  @override
  State<AiModelsView> createState() => _AiModelsViewState();
}

class _AiModelsViewState extends State<AiModelsView>
    with SingleTickerProviderStateMixin {
  String _activeCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  final Set<String> _favorites = {'GPT-4o', 'Midjourney v6'};

  final List<String> _categories = [
    'All', 'Text', 'Image', 'Video', 'Audio', 'Code', 'Reasoning', '3D', 'Premium', 'Open Source', 'Newest',
  ];

  final List<Map<String, dynamic>> _featuredModels = [
    {'tag': '⭐ Recommended', 'name': 'Midjourney v6', 'provider': 'Midjourney', 'color': AppTheme.brandOrange, 'icon': Icons.image_rounded},
    {'tag': '🔥 Trending', 'name': 'GPT-4o', 'provider': 'OpenAI', 'color': const Color(0xFF00E5A0), 'icon': Icons.smart_toy_rounded},
    {'tag': '🚀 Newest', 'name': 'Flux Ultra', 'provider': 'Black Forest Labs', 'color': AppTheme.electricBlue, 'icon': Icons.bolt_rounded},
    {'tag': '💎 Premium', 'name': 'Claude 3.5 Sonnet', 'provider': 'Anthropic', 'color': const Color(0xFF7C4DFF), 'icon': Icons.psychology_rounded},
  ];

  final List<Map<String, dynamic>> _models = [
    {
      'name': 'GPT-4o',
      'provider': 'OpenAI',
      'version': 'v4o',
      'type': 'Text',
      'desc': 'OpenAI\'s flagship multimodal model for text, vision and reasoning tasks.',
      'speed': 4.2,
      'quality': 4.8,
      'creativity': 4.5,
      'cost': '💰💰💰',
      'context': '128K tokens',
      'updated': 'May 2024',
      'available': true,
      'premium': false,
      'color': const Color(0xFF00E5A0),
      'logo': '🤖',
    },
    {
      'name': 'Midjourney v6',
      'provider': 'Midjourney',
      'version': 'v6.1',
      'type': 'Image',
      'desc': 'State-of-the-art AI image generation with photorealistic and artistic quality.',
      'speed': 3.8,
      'quality': 4.9,
      'creativity': 4.8,
      'cost': '💰💰',
      'context': 'N/A',
      'updated': 'Jun 2024',
      'available': true,
      'premium': false,
      'color': AppTheme.brandOrange,
      'logo': '🎨',
    },
    {
      'name': 'Claude 3.5 Sonnet',
      'provider': 'Anthropic',
      'version': '3.5',
      'type': 'Text',
      'desc': 'Anthropic\'s most intelligent model — outstanding reasoning and code generation.',
      'speed': 4.5,
      'quality': 4.7,
      'creativity': 4.3,
      'cost': '💰💰',
      'context': '200K tokens',
      'updated': 'Jun 2024',
      'available': true,
      'premium': true,
      'color': const Color(0xFF7C4DFF),
      'logo': '🧠',
    },
    {
      'name': 'Flux.1 Pro',
      'provider': 'Black Forest Labs',
      'version': 'Pro',
      'type': 'Image',
      'desc': 'Ultra-high quality image generation with unmatched photorealism.',
      'speed': 3.5,
      'quality': 4.9,
      'creativity': 4.6,
      'cost': '💰💰',
      'context': 'N/A',
      'updated': 'Apr 2024',
      'available': true,
      'premium': false,
      'color': AppTheme.electricBlue,
      'logo': '⚡',
    },
    {
      'name': 'Gemini 1.5 Pro',
      'provider': 'Google',
      'version': '1.5',
      'type': 'Text',
      'desc': 'Google\'s most capable multimodal AI model with 1M token context window.',
      'speed': 4.0,
      'quality': 4.5,
      'creativity': 4.2,
      'cost': '💰',
      'context': '1M tokens',
      'updated': 'May 2024',
      'available': true,
      'premium': false,
      'color': const Color(0xFFFFC107),
      'logo': '💎',
    },
    {
      'name': 'DALL-E 3',
      'provider': 'OpenAI',
      'version': '3',
      'type': 'Image',
      'desc': 'Highly accurate image generation with prompt adherence and detail control.',
      'speed': 3.7,
      'quality': 4.4,
      'creativity': 4.3,
      'cost': '💰💰',
      'context': 'N/A',
      'updated': 'Nov 2023',
      'available': true,
      'premium': false,
      'color': const Color(0xFF00E5A0),
      'logo': '🖼',
    },
  ];

  final List<Map<String, dynamic>> _recommendations = [
    {'label': 'Best for Prompts', 'model': 'GPT-4o', 'icon': Icons.edit_rounded, 'color': const Color(0xFF00E5A0)},
    {'label': 'Best for Images', 'model': 'Midjourney v6', 'icon': Icons.image_rounded, 'color': AppTheme.brandOrange},
    {'label': 'Best for Code', 'model': 'Claude 3.5 Sonnet', 'icon': Icons.code_rounded, 'color': const Color(0xFF7C4DFF)},
    {'label': 'Best Free', 'model': 'Gemini 1.5 Pro', 'icon': Icons.money_off_rounded, 'color': const Color(0xFFFFC107)},
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

  List<Map<String, dynamic>> get _filteredModels {
    return _models.where((m) {
      final matchesCategory = _activeCategory == 'All' || m['type'] == _activeCategory || (_activeCategory == 'Premium' && m['premium'] == true);
      final matchesSearch = _searchQuery.isEmpty || (m['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.07), Colors.transparent]),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 110)),

              // ─── FEATURED CAROUSEL ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('FEATURED MODELS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _featuredModels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildFeaturedCard(_featuredModels[i]),
                ),
              )),

              // ─── SMART RECOMMENDATIONS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13),
                  const SizedBox(width: 6),
                  Text('SMART RECOMMENDATIONS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                ]),
              )),
              SliverToBoxAdapter(child: SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _recommendations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final r = _recommendations[i];
                    final color = r['color'] as Color;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(r['icon'] as IconData, color: color, size: 14),
                          const SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(r['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
                            Text(r['model'] as String, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70)),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
              )),

              // ─── ALL MODELS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('${_filteredModels.length} MODELS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildModelCard(_filteredModels[i])),
                    childCount: _filteredModels.length,
                  ),
                ),
              ),
            ],
          ),

          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),
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
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI Models', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Choose the perfect AI model for every task.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                  ])),
                  IconButton(icon: const Icon(Icons.compare_arrows_rounded, color: Colors.white70, size: 20), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.bookmark_outline_rounded, color: Colors.white70, size: 20), onPressed: () {}),
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
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search AI models...',
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
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final c = _categories[i];
                    return AnzorChip(label: c, isSelected: _activeCategory == c, onTap: () { setState(() => _activeCategory = c); HapticFeedback.selectionClick(); });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> model) {
    final color = model['color'] as Color;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(model['tag'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w800, color: color)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(model['icon'] as IconData, color: color, size: 20),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(model['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(model['provider'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final color = model['color'] as Color;
    final isFav = _favorites.contains(model['name']);

    return GestureDetector(
      onTap: () => _showModelDetails(model),
      child: AnzorCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
                  child: Center(child: Text(model['logo'] as String, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(model['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(width: 6),
                      if (model['premium'] == true)
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.brandGold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)), child: Text('PRO', style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.brandGold))),
                    ]),
                    Text('${model['provider']} • v${model['version']} • ${model['type']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() { isFav ? _favorites.remove(model['name']) : _favorites.add(model['name'] as String); });
                    HapticFeedback.selectionClick();
                  },
                  child: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: isFav ? AppTheme.brandOrange : Colors.white30, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(model['desc'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.5), height: 1.4), maxLines: 2),
            const SizedBox(height: 12),
            // Ratings
            Row(children: [
              _ratingBar('Speed', model['speed'] as double, AppTheme.electricBlue),
              const SizedBox(width: 8),
              _ratingBar('Quality', model['quality'] as double, AppTheme.brandOrange),
              const SizedBox(width: 8),
              _ratingBar('Creative', model['creativity'] as double, const Color(0xFF7C4DFF)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _tag('Context: ${model['context']}', Colors.white24, Colors.white38),
              const SizedBox(width: 8),
              _tag(model['cost'] as String, Colors.white10, Colors.white30),
              const Spacer(),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: model['available'] == true ? const Color(0xFF00E5A0) : Colors.red),
              ),
              const SizedBox(width: 4),
              Text(model['available'] == true ? 'Available' : 'Offline', style: GoogleFonts.inter(fontSize: 9.5, color: model['available'] == true ? const Color(0xFF00E5A0) : Colors.red)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _ratingBar(String label, double value, Color color) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white30)),
          const Spacer(),
          Text(value.toStringAsFixed(1), style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value / 5.0,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ),
      ]),
    );
  }

  Widget _tag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: text)),
    );
  }

  void _showModelDetails(Map<String, dynamic> model) {
    final color = model['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0E1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(children: [
                Text(model['logo'] as String, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(model['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('${model['provider']} • ${model['type']}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ]),
              ]),
              const SizedBox(height: 16),
              Text(model['desc'] as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.5)),
              const SizedBox(height: 16),
              _detailRow('Context Length', model['context'] as String),
              _detailRow('Last Updated', model['updated'] as String),
              _detailRow('Cost', model['cost'] as String),
              const SizedBox(height: 20),
              AnzorButton(
                height: 48,
                onPressed: () { Navigator.pop(context); HapticFeedback.mediumImpact(); },
                child: Text('Select This Model', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38))),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
      ]),
    );
  }
}
