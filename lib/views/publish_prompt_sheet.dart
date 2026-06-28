import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class PublishPromptSheet extends StatefulWidget {
  const PublishPromptSheet({super.key});

  @override
  State<PublishPromptSheet> createState() => _PublishPromptSheetState();
}

class _PublishPromptSheetState extends State<PublishPromptSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _promptController = TextEditingController();

  String _selectedCategory = 'Sci-Fi';
  String _selectedStyle = 'Cyberpunk';
  String _selectedModel = 'Midjourney v6';
  String _selectedVisibility = 'Public';
  String _selectedLicense = 'Free';
  Uint8List? _selectedImageBytes;
  bool _isSubmitting = false;
  bool _showSuccessState = false;

  final List<String> _categories = [
    'Sci-Fi', 'Fantasy', 'Anime', 'Nature', 'Realistic', 'Portrait', 'Architecture', 'Animals'
  ];

  final List<String> _styles = [
    'Cyberpunk', 'Watercolor', 'Vintage Film', '3D Render', 'Painterly', 'Cinematic', 'Realistic', 'Anime & Manga'
  ];

  final List<String> _models = [
    'Midjourney v6', 'DALL-E 3', 'Stable Diffusion XL', 'Flux.1', 'GPT-4 Vision', 'Gemini 1.5 Pro'
  ];

  final List<String> _tags = [
    '8k', 'cinematic', 'photorealistic', 'octane render', 'cyberpunk', 'masterpiece'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final success = await appState.submitPromptAction(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        promptText: _promptController.text.trim(),
        category: _selectedCategory,
        style: _selectedStyle,
        author: appState.currentUserProfile.username,
        imageBytes: _selectedImageBytes,
      );

      if (success) {
        await appState.refreshCommunityFeed();
        if (mounted) {
          setState(() {
            _showSuccessState = true;
            _isSubmitting = false;
          });
        }
      } else {
        throw Exception('Server rejected prompt submission.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppTheme.neonPink,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccessState) {
      return _buildSuccessScreen();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.brandOrange.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar indicator
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publish Prompt',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                        ),
                      ),
                      Text(
                        'Share your best AI prompt with the world.',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.help_outline_rounded, color: Colors.white.withValues(alpha: 0.45), size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anzor Marketplace supports Midjourney, Stable Diffusion, and GPT formats.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Prompt Title
              _inputLabel('PROMPT TITLE'),
              AnzorInput(
                controller: _titleController,
                hintText: 'e.g. Cyberpunk Neon Warrior, Mystic Forest...',
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              _inputLabel('PROMPT DESCRIPTION'),
              AnzorInput(
                controller: _descController,
                hintText: 'Describe the style, setting, composition, or output mood...',
                maxLines: 2,
                validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // AI Prompt content
              _inputLabel('AI PROMPT TEXT'),
              AnzorInput(
                controller: _promptController,
                hintText: 'Paste the exact keywords used to generate the image or output...',
                maxLines: 4,
                validator: (val) => val == null || val.trim().isEmpty ? 'Prompt text is required' : null,
              ),
              const SizedBox(height: 16),

              // Specifications selector row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('CATEGORY'),
                        _buildDropdown(_selectedCategory, _categories, (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('STYLE'),
                        _buildDropdown(_selectedStyle, _styles, (val) {
                          if (val != null) setState(() => _selectedStyle = val);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('COMPATIBILITY'),
                        _buildDropdown(_selectedModel, _models, (val) {
                          if (val != null) setState(() => _selectedModel = val);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputLabel('VISIBILITY'),
                        _buildDropdown(_selectedVisibility, ['Public', 'Unlisted', 'Private'], (val) {
                          if (val != null) setState(() => _selectedVisibility = val);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Showcase Image Upload card
              _inputLabel('SHOWCASE IMAGE'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: AnzorCard(
                  padding: EdgeInsets.zero,
                  radius: 18,
                  borderColor: AppTheme.brandOrange.withValues(alpha: 0.15),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppTheme.brandOrange,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select high-quality preview image',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // AI Analysis preview
              Text(
                'AI PROMPT ANALYSIS CHECKPOINT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              AnzorCard(
                padding: const EdgeInsets.all(12),
                radius: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _analysisStat('Prompt Score', '98.7%'),
                    _analysisStat('Creativity', 'High'),
                    _analysisStat('Validation', 'Passed'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Suggested Tags Chips
              _inputLabel('SUGGESTED TAGS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
                  ),
                  child: Text(
                    '#$tag',
                    style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 28),

              // License options
              _inputLabel('LICENSE TIER'),
              const SizedBox(height: 8),
              Row(
                children: ['Free', 'Personal', 'Commercial'].map((license) {
                  final isSel = _selectedLicense == license;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLicense = license),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.brandOrange.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          license,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: isSel ? AppTheme.brandOrange : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit Action
              AnzorButton(
                onPressed: _submitForm,
                radius: 16, height: 50,
                isLoading: _isSubmitting,
                gradient: AppTheme.brandGradient,
                glowColor: AppTheme.brandOrange,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Publish to Marketplace',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _analysisStat(String title, String val) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF131024),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white30, size: 18),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF0C0A15),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00FF87).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFF00FF87).withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 52,
              color: Color(0xFF00FF87),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Published Successfully!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your prompt has been shared with the Anzor community and is now live on the discover marketplace feed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.45), height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: AnzorButton(
              onPressed: () => Navigator.pop(context),
              radius: 12,
              gradient: AppTheme.brandGradient,
              glowColor: AppTheme.brandOrange,
              child: Text(
                'Return to Workspace',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
