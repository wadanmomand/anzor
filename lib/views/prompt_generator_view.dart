import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';
import 'admin_view.dart';
import 'history_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kBg = Color(0xFF06050C);
const _kCard = Color(0xFF131024);
const _kCardAlt = Color(0xFF0F0E1E);
const _kBorder = Color(0x10FFFFFF);

class _StudioMode {
  final String emoji;
  final String label;
  final String sublabel;
  const _StudioMode(this.emoji, this.label, this.sublabel);
}

const _modes = [
  _StudioMode('✍️', 'Text → Prompt', 'Write your idea'),
  _StudioMode('🖼️', 'Image → Prompt', 'Analyze & describe'),
  _StudioMode('🎥', 'Video → Prompt', 'Scene breakdown'),
];

const _promptCategories = [
  'All', 'Image Prompt', 'Video Prompt', 'Logo Prompt',
  'Cinematic', 'Realistic', 'Anime', 'Photography',
  'Portrait', 'Fantasy', 'Product', 'Architecture', 'Character',
];

const _compatibleTools = [
  ('ChatGPT', '🤖'), ('Gemini', '✨'), ('Claude', '🟣'),
  ('Midjourney', '🎨'), ('Flux', '⚡'), ('Imagen', '🖼️'),
  ('Veo', '🎥'), ('Runway', '🚀'), ('Kling', '🌀'),
  ('Leonardo', '🎭'),
];

const _randomIdeas = [
  'A futuristic cyberpunk city at dusk with neon reflections',
  'A realistic lion wearing golden battle armor in a forest',
  'A cinematic mountain landscape at golden hour with fog',
  'An underwater bioluminescent world with alien creatures',
  'A lone astronaut standing on an alien planet at sunset',
  'A fantasy dragon made entirely of stardust and galaxies',
  'Aerial view of a Japanese temple surrounded by cherry blossoms',
];

// ─────────────────────────────────────────────────────────────────────────────
// PromptGeneratorView — ✨ Prompt Studio
// ─────────────────────────────────────────────────────────────────────────────

class PromptGeneratorView extends StatefulWidget {
  const PromptGeneratorView({super.key});

  @override
  State<PromptGeneratorView> createState() => _PromptGeneratorViewState();
}

class _PromptGeneratorViewState extends State<PromptGeneratorView>
    with TickerProviderStateMixin {

  // Controllers
  final _ideaController = TextEditingController();
  final _scrollController = ScrollController();
  final _ideaFocus = FocusNode();
  final _picker = ImagePicker();

  // Mode
  int _modeIndex = 0;                     // 0=Text, 1=Image, 2=Video
  late AnimationController _modeAnimController;
  late Animation<double> _modeFade;

  // State
  bool _ideaFocused = false;
  String _selectedCategory = 'All';
  String? _pickedImagePath;
  String? _pickedVideoPath;
  bool _isGenerating = false;
  String _generatedPrompt = '';
  String _promptTitle = '';
  bool _isEditing = false;
  final _editController = TextEditingController();

  // Generate button pulse
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  // ─── Init ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _ideaFocus.addListener(() {
      setState(() => _ideaFocused = _ideaFocus.hasFocus);
    });

    _modeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _modeFade = CurvedAnimation(parent: _modeAnimController, curve: Curves.easeOutCubic);
    _modeAnimController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ideaController.dispose();
    _editController.dispose();
    _scrollController.dispose();
    _ideaFocus.dispose();
    _modeAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Mode switch ────────────────────────────────────────────────────────

  void _switchMode(int index) {
    if (_modeIndex == index) return;
    _modeAnimController.reverse().then((_) {
      setState(() => _modeIndex = index);
      _modeAnimController.forward();
    });
    HapticFeedback.selectionClick();
  }

  // ─── Random ─────────────────────────────────────────────────────────────

  void _fillRandom() {
    final r = Random();
    final idea = _randomIdeas[r.nextInt(_randomIdeas.length)];
    _ideaController.text = idea;
    _ideaController.selection = TextSelection.collapsed(offset: idea.length);
    setState(() {});
    HapticFeedback.mediumImpact();
  }

  // ─── Generate ───────────────────────────────────────────────────────────

  Future<void> _generate(AppState appState) async {
    String input = '';
    if (_modeIndex == 0) {
      input = _ideaController.text.trim();
      if (input.isEmpty) {
        _showSnack('Please describe your idea first.');
        return;
      }
    } else if (_modeIndex == 1) {
      if (_pickedImagePath == null) {
        _showSnack('Please upload an image to analyze.');
        return;
      }
      input = 'Analyze this image and generate a professional prompt';
    } else {
      if (_pickedVideoPath == null) {
        _showSnack('Please upload a video to analyze.');
        return;
      }
      input = 'Analyze this video scene and generate a professional prompt';
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isGenerating = true;
      _generatedPrompt = '';
      _isEditing = false;
    });
    HapticFeedback.heavyImpact();

    await appState.generatePromptAction(input);

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generatedPrompt = appState.expandedPrompt;
        _promptTitle = input.length > 40 ? '${input.substring(0, 40)}...' : input;
        _editController.text = _generatedPrompt;
      });

      // Scroll to output
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  // ─── Image pick ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final f = await _picker.pickImage(
        source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );
      if (f != null) setState(() => _pickedImagePath = f.path);
    } catch (_) {}
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final f = await _picker.pickVideo(source: source);
      if (f != null) setState(() => _pickedVideoPath = f.path);
    } catch (_) {}
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _kCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;
    final isLoading = _isGenerating || appState.isStudioLoading || appState.isVisionLoading;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Ambient Glows ────────────────────────────────────────────
          _buildAmbientGlow(top: -80, right: -60, color: AppTheme.brandOrange, opacity: 0.10, size: 260),
          _buildAmbientGlow(bottom: 220, left: -90, color: AppTheme.electricBlue, opacity: 0.07, size: 220),
          _buildAmbientGlow(bottom: 80, right: -40, color: AppTheme.neonPurple, opacity: 0.06, size: 180),

          // ── Scrollable Body ──────────────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 68)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 6),

                    // Mode Selector
                    _buildModeSelector(),
                    const SizedBox(height: 20),

                    // Category Chips
                    _buildCategoryChips(),
                    const SizedBox(height: 20),

                    // Active Mode Panel
                    FadeTransition(
                      opacity: _modeFade,
                      child: _buildModePanel(appState, isLoading),
                    ),
                    const SizedBox(height: 16),

                    // Generate Button
                    _buildGenerateButton(appState, isLoading),
                    const SizedBox(height: 24),

                    // Output / Result
                    if (_generatedPrompt.isNotEmpty || isLoading)
                      _buildOutputSection(appState, isLoading),

                    // Prompt Quality (only when result available)
                    if (_generatedPrompt.isNotEmpty && !isLoading) ...[
                      const SizedBox(height: 20),
                      _buildPromptQuality(),
                    ],

                    // Recent Prompts
                    if (appState.historyList.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildRecentPromptsSection(appState),
                    ],

                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          ),

          // ── Pinned Header ────────────────────────────────────────────
          _buildHeader(context, appState, topPad),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ambient Glow
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAmbientGlow({
    double? top, double? bottom, double? left, double? right,
    required Color color, required double opacity, required double size,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: IgnorePointer(
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppState appState, double topPad) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(top: topPad),
            color: const Color(0xCC06050C),
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Left: Admin button (if admin) or spacer
                    SizedBox(
                      width: 44,
                      child: appState.isAdmin
                          ? _iconBtn(
                              icon: Icons.admin_panel_settings_outlined,
                              color: AppTheme.neonPink,
                              bg: AppTheme.neonPink.withValues(alpha: 0.1),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const AdminView())),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Center title
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => AppTheme.brandGradient.createShader(
                                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                              ),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                '✨ Prompt Studio',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            Text(
                              'by Anzor AI',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right: History
                    SizedBox(
                      width: 44,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _iconBtn(
                          icon: Icons.history_rounded,
                          color: Colors.white70,
                          bg: Colors.white.withValues(alpha: 0.05),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoryView())),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode Selector
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Row(
        children: List.generate(_modes.length, (i) {
          final isSelected = _modeIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.brandGradient : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.transparent,
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(
                          color: AppTheme.brandOrange.withValues(alpha: 0.45),
                          blurRadius: 14, offset: const Offset(0, 3),
                        )]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _modes[i].emoji,
                      style: TextStyle(fontSize: isSelected ? 18 : 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _modes[i].label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category Chips
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _promptCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final cat = _promptCategories[i];
          final isSel = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 0),
              decoration: BoxDecoration(
                gradient: isSel ? AppTheme.brandGradient : null,
                color: isSel ? null : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
                boxShadow: isSel
                    ? [BoxShadow(
                        color: AppTheme.brandOrange.withValues(alpha: 0.3),
                        blurRadius: 8, offset: const Offset(0, 1),
                      )]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode Panel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildModePanel(AppState appState, bool isLoading) {
    switch (_modeIndex) {
      case 0: return _buildTextMode(isLoading);
      case 1: return _buildImageMode(appState, isLoading);
      case 2: return _buildVideoMode(isLoading);
      default: return const SizedBox.shrink();
    }
  }

  // ── Mode 0: Text → Prompt ─────────────────────────────────────────────

  Widget _buildTextMode(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Your Idea'),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _ideaFocused
                  ? AppTheme.brandOrange.withValues(alpha: 0.55)
                  : _kBorder,
              width: _ideaFocused ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _ideaFocused
                    ? AppTheme.brandOrange.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: _ideaFocused ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input
                TextField(
                  controller: _ideaController,
                  focusNode: _ideaFocus,
                  enabled: !isLoading,
                  maxLines: 5,
                  minLines: 4,
                  maxLength: 600,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      const SizedBox.shrink(),
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(
                    fontSize: 14.5, height: 1.55,
                    color: const Color(0xFFF0F4FF),
                  ),
                  cursorColor: AppTheme.brandOrange,
                  decoration: InputDecoration(
                    hintText: 'Describe your idea…\n\nExamples:\n"A futuristic city at sunset"\n"A lion wearing golden armor"',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5, height: 1.6,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),

                // Action Row
                Row(
                  children: [
                    // Clear
                    if (_ideaController.text.isNotEmpty)
                      _promptActionBtn(
                        icon: Icons.clear_rounded,
                        label: 'Clear',
                        onTap: () { _ideaController.clear(); setState(() {}); },
                      ),
                    // Paste
                    _promptActionBtn(
                      icon: Icons.content_paste_rounded,
                      label: 'Paste',
                      onTap: () async {
                        final d = await Clipboard.getData('text/plain');
                        if (d?.text != null) {
                          _ideaController.text = d!.text!;
                          setState(() {});
                        }
                      },
                    ),
                    // Random
                    _promptActionBtn(
                      icon: Icons.shuffle_rounded,
                      label: 'Random',
                      onTap: _fillRandom,
                    ),
                    const Spacer(),

                    // Character count
                    Text(
                      '${_ideaController.text.length}/600',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Example Prompts
        _sectionLabel('Quick Examples'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Futuristic city at dusk',
            'Cinematic mountain lake',
            'Fantasy dragon portrait',
            'Realistic lion armor',
          ].map((ex) {
            final isSel = _ideaController.text == ex;
            return AnzorChip(
              label: ex,
              isSelected: isSel,
              onTap: () {
                _ideaController.text = ex;
                setState(() {});
                _ideaFocus.requestFocus();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _promptActionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.45)),
            const SizedBox(width: 4),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode 1: Image → Prompt ────────────────────────────────────────────

  Widget _buildImageMode(AppState appState, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Upload Image'),
        const SizedBox(height: 10),
        if (_pickedImagePath == null)
          _buildUploadCard(
            icon: Icons.image_search_rounded,
            title: 'Analyze Image',
            subtitle: 'Upload from Gallery or Camera',
            actions: [
              _uploadOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              _uploadOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          )
        else
          _buildImagePreview(),

        const SizedBox(height: 12),
        _buildInfoBanner(
          icon: Icons.auto_awesome_rounded,
          text: 'AI will analyze the image and generate a professional prompt describing every detail — style, lighting, composition, colors, and mood.',
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.35), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandOrange.withValues(alpha: 0.1),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandOrange.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.image_rounded,
                    color: AppTheme.brandOrange, size: 26),
                ),
                const SizedBox(height: 10),
                Text('Image Selected ✓',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppTheme.brandOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Ready to analyze',
                  style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _pickedImagePath = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode 2: Video → Prompt ────────────────────────────────────────────

  Widget _buildVideoMode(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Upload Video'),
        const SizedBox(height: 10),
        if (_pickedVideoPath == null)
          _buildUploadCard(
            icon: Icons.video_camera_back_rounded,
            title: 'Analyze Video',
            subtitle: 'Upload video or record a scene',
            actions: [
              _uploadOption(
                icon: Icons.video_library_rounded,
                label: 'Gallery',
                onTap: () => _pickVideo(ImageSource.gallery),
              ),
              _uploadOption(
                icon: Icons.videocam_rounded,
                label: 'Record',
                onTap: () => _pickVideo(ImageSource.camera),
              ),
            ],
          )
        else
          _buildVideoPreview(),

        const SizedBox(height: 12),
        _buildInfoBanner(
          icon: Icons.movie_creation_outlined,
          text: 'AI will analyze the video and generate a full prompt covering scene, lighting, camera angle, characters, objects, mood, style, movement, and composition.',
        ),
        const SizedBox(height: 12),

        // What gets analyzed
        _sectionLabel('Analyzed Elements'),
        const SizedBox(height: 10),
        _buildVideoElements(),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.electricBlue.withValues(alpha: 0.4), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.1),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.electricBlue.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.videocam_rounded,
                    color: AppTheme.electricBlue, size: 24),
                ),
                const SizedBox(height: 8),
                Text('Video Selected ✓',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppTheme.electricBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text('Ready to analyze',
                  style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _pickedVideoPath = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoElements() {
    const elements = [
      ('🎬', 'Scene'), ('💡', 'Lighting'), ('📷', 'Camera Angle'),
      ('👤', 'Characters'), ('📦', 'Objects'), ('🌍', 'Environment'),
      ('🎭', 'Mood'), ('🖌️', 'Style'), ('🎞️', 'Movement'), ('🖼️', 'Composition'),
    ];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: elements.map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.$1, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 5),
            Text(e.$2,
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ── Shared upload card ────────────────────────────────────────────────

  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.brandOrange.withValues(alpha: 0.15),
                        AppTheme.brandGold.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.brandOrange.withValues(alpha: 0.2), width: 1.0,
                    ),
                  ),
                  child: Icon(icon, color: AppTheme.brandOrange, size: 24),
                ),
                const SizedBox(height: 12),
                Text(title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5, color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          IntrinsicHeight(
            child: Row(
              children: actions.map((a) => Expanded(child: a)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.45), size: 22),
            const SizedBox(height: 5),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Generate Button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGenerateButton(AppState appState, bool isLoading) {
    const labels = [
      '✨ Generate Prompt',
      '🖼️ Analyze & Generate',
      '🎥 Analyze & Generate',
    ];
    return Column(
      children: [
        AnzorButton(
          isLoading: isLoading,
          gradient: AppTheme.brandGradient,
          glowColor: AppTheme.brandOrange,
          radius: 18,
          height: 58,
          onPressed: isLoading ? () {} : () => _generate(appState),
          child: Text(
            labels[_modeIndex],
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),
        Text(
          'Powered by Anzor AI · Prompt Engineering',
          style: GoogleFonts.inter(
            fontSize: 10.5,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Output Section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOutputSection(AppState appState, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Generated Prompt',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (!isLoading && _generatedPrompt.isNotEmpty) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.brandOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.brandOrange.withValues(alpha: 0.25), width: 0.8,
                  ),
                ),
                child: Text('Ready to use',
                  style: GoogleFonts.inter(
                    fontSize: 9.5, fontWeight: FontWeight.w700,
                    color: AppTheme.brandOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isLoading
                  ? AppTheme.brandOrange.withValues(alpha: 0.3)
                  : AppTheme.brandOrange.withValues(alpha: 0.2),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandOrange.withValues(alpha: 0.08),
                blurRadius: 16, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isLoading
              ? _buildOutputLoading()
              : _buildOutputContent(),
        ),
      ],
    );
  }

  Widget _buildOutputLoading() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 36, height: 36,
            child: CircularProgressIndicator(
              color: AppTheme.brandOrange,
              strokeWidth: 2.5,
              backgroundColor: AppTheme.brandOrange.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 14),
          Text('AI is crafting your prompt…',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text('Analyzing your input and building a professional prompt',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.4), height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt text (editable or read-only)
          _isEditing
              ? TextField(
                  controller: _editController,
                  maxLines: null,
                  autofocus: true,
                  style: GoogleFonts.inter(
                    fontSize: 13.5, height: 1.6,
                    color: const Color(0xFFF0F4FF),
                  ),
                  cursorColor: AppTheme.brandOrange,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    fillColor: AppTheme.brandOrange.withValues(alpha: 0.04),
                    filled: true,
                  ),
                )
              : Text(
                  _generatedPrompt,
                  style: GoogleFonts.inter(
                    fontSize: 13.5, height: 1.6,
                    color: const Color(0xFFF0F4FF),
                  ),
                ),

          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 12),

          // Action buttons — all using AnzorActionButton for identical behavior
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              AnzorActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                variant: AnzorActionButtonVariant.primary,
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: _isEditing ? _editController.text : _generatedPrompt,
                  ));
                  _showSnack('Prompt copied to clipboard!');
                },
              ),
              AnzorActionButton(
                icon: _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                label: _isEditing ? 'Save Edit' : 'Edit',
                onTap: () {
                  if (_isEditing) {
                    setState(() {
                      _generatedPrompt = _editController.text;
                      _isEditing = false;
                    });
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
              AnzorActionButton(
                icon: Icons.auto_fix_high_rounded,
                label: 'Improve',
                onTap: () async {
                  final appState = Provider.of<AppState>(context, listen: false);
                  final current = _isEditing ? _editController.text : _generatedPrompt;
                  if (current.isNotEmpty) await _generate(appState);
                },
              ),
              AnzorActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Save',
                onTap: () => _showSnack('Prompt saved to your collection!'),
              ),
              AnzorActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () => _showSnack('Share coming soon!'),
              ),
              AnzorActionButton(
                icon: Icons.ios_share_rounded,
                label: 'Export',
                onTap: () => _showSnack('Export coming soon!'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _outputActionBtn removed — use AnzorActionButton from glass_widgets.dart instead

  // ─────────────────────────────────────────────────────────────────────────
  // Prompt Quality
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPromptQuality() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.brandOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star_rounded, color: AppTheme.brandOrange, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Prompt Quality',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
              const Spacer(),
              ShaderMask(
                shaderCallback: (b) => AppTheme.brandGradient.createShader(
                  Rect.fromLTWH(0, 0, b.width, b.height),
                ),
                blendMode: BlendMode.srcIn,
                child: Text('96%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22, fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stars
          Row(
            children: List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                color: AppTheme.brandOrange, size: 20,
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text('Excellent quality prompt',
            style: GoogleFonts.inter(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),

          // Quality metrics
          Row(
            children: [
              _qualityMetric('Length', '${_generatedPrompt.split(' ').length} words'),
              const SizedBox(width: 12),
              _qualityMetric('Chars', '${_generatedPrompt.length}'),
              const SizedBox(width: 12),
              _qualityMetric('Score', 'Professional'),
            ],
          ),
          const SizedBox(height: 16),

          // Compatible with
          Text('Compatible With',
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7, runSpacing: 7,
            children: _compatibleTools.map((tool) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07), width: 0.7,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tool.$2, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(tool.$1,
                    style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _qualityMetric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 9.5, color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 3),
            Text(value,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Recent Prompts
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRecentPromptsSection(AppState appState) {
    final recent = appState.historyList.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent Prompts',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HistoryView()),
              ),
              child: Text('View All',
                style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w600,
                  color: AppTheme.brandOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recent.map((item) => _buildRecentPromptCard(item)),
      ],
    );
  }

  Widget _buildRecentPromptCard(dynamic item) {
    final dateStr = item.date.toString().length > 10
        ? item.date.toString().substring(0, 10)
        : item.date.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandOrange.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
              color: AppTheme.brandOrange, size: 16),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.rawIdea.length > 55
                      ? '${item.rawIdea.substring(0, 55)}…'
                      : item.rawIdea,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5, fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.brandOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(item.style,
                        style: GoogleFonts.inter(
                          fontSize: 9.5, fontWeight: FontWeight.w700,
                          color: AppTheme.brandOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cardIconAction(
                icon: Icons.copy_rounded,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.expandedPrompt));
                  _showSnack('Prompt copied!');
                },
              ),
              const SizedBox(width: 4),
              _cardIconAction(
                icon: Icons.open_in_new_rounded,
                onTap: () {
                  _ideaController.text = item.rawIdea;
                  setState(() {});
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardIconAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.7),
        ),
        child: Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 9.5, fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildInfoBanner({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.brandOrange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.brandOrange.withValues(alpha: 0.15), width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.brandOrange, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: GoogleFonts.inter(
                fontSize: 11, height: 1.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
