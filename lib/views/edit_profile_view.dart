import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;

  // Socials
  late TextEditingController _xController;
  late TextEditingController _githubController;

  // Chip options
  final List<String> _models = ['Midjourney v6', 'Flux.1 Pro', 'GPT-4o', 'Claude 3.5 Sonnet', 'SDXL'];
  final Set<String> _selectedModels = {'Midjourney v6', 'GPT-4o'};

  final List<String> _expertise = ['Text-to-Image', 'UI Design', 'Copywriting', 'Coding', 'Marketing'];
  final Set<String> _selectedExpertise = {'Text-to-Image', 'UI Design'};

  // Privacy toggles
  bool _isPublic = true;
  bool _showEmail = false;
  bool _showFollowers = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final myProfile = appState.currentUserProfile;

    _nameController = TextEditingController(text: myProfile.username);
    _usernameController = TextEditingController(text: myProfile.username);
    _bioController = TextEditingController(text: myProfile.bio);
    _websiteController = TextEditingController(text: 'https://anzor.ai/${myProfile.username}');
    _locationController = TextEditingController(text: 'San Francisco, CA');
    _emailController = TextEditingController(text: 'creator@anzor.ai');

    _xController = TextEditingController(text: 'https://x.com/${myProfile.username}');
    _githubController = TextEditingController(text: 'https://github.com/${myProfile.username}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _xController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  void _saveChanges(AppState appState) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Simulate network save latency
    await Future.delayed(const Duration(milliseconds: 1500));

    appState.updateUserProfile(
      username: _usernameController.text,
      bio: _bioController.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Creator Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient backdrops
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          Form(
            key: _formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: topPad + 70)),

                // ─── 1. LIVE PREVIEW HEADER CARD ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIVE VISUAL PROFILE PREVIEW',
                          style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        _buildLivePreviewCard(appState),
                      ],
                    ),
                  ),
                ),

                // ─── 2. PERSONAL INFO FIELDS ───
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _sectionTitle('PERSONAL PROFILE DATA'),
                      const SizedBox(height: 10),
                      AnzorCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInput('Display Name', _nameController, Icons.face_rounded),
                            const SizedBox(height: 14),
                            _buildInput('Username Handle', _usernameController, Icons.alternate_email_rounded),
                            const SizedBox(height: 14),
                            _buildInput('Creator Biography', _bioController, Icons.history_edu_rounded, maxLines: 3),
                            const SizedBox(height: 14),
                            _buildInput('Contact Email address', _emailController, Icons.email_outlined),
                            const SizedBox(height: 14),
                            _buildInput('Location', _locationController, Icons.location_on_outlined),
                            const SizedBox(height: 14),
                            _buildInput('Creator Website', _websiteController, Icons.link_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── 3. AI CONFIGURATION CHIPS ───
                      _sectionTitle('AI MODEL & TOOLSET EXPERTISE'),
                      const SizedBox(height: 10),
                      AnzorCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Primary AI Models',
                              style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: _models.map((model) {
                                final isSel = _selectedModels.contains(model);
                                return ChoiceChip(
                                  label: Text(model, style: GoogleFonts.inter(fontSize: 11, color: isSel ? Colors.white : Colors.white60)),
                                  selected: isSel,
                                  selectedColor: AppTheme.brandOrange.withValues(alpha: 0.25),
                                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                                  checkmarkColor: AppTheme.brandOrange,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _selectedModels.add(model);
                                      } else {
                                        _selectedModels.remove(model);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const Divider(color: Color(0x1BFFFFFF), height: 32),
                            Text(
                              'Core AI Specialties',
                              style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: _expertise.map((exp) {
                                final isSel = _selectedExpertise.contains(exp);
                                return ChoiceChip(
                                  label: Text(exp, style: GoogleFonts.inter(fontSize: 11, color: isSel ? Colors.white : Colors.white60)),
                                  selected: isSel,
                                  selectedColor: AppTheme.electricBlue.withValues(alpha: 0.25),
                                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                                  checkmarkColor: AppTheme.electricBlue,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _selectedExpertise.add(exp);
                                      } else {
                                        _selectedExpertise.remove(exp);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── 4. SOCIAL CONNECTIONS ───
                      _sectionTitle('SOCIAL NETWORK PROFILES'),
                      const SizedBox(height: 10),
                      AnzorCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInput('X (Twitter) Link', _xController, Icons.chat_bubble_outline_rounded),
                            const SizedBox(height: 14),
                            _buildInput('GitHub Repository Profile', _githubController, Icons.code_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── 5. PRIVACY PROFILE CONTROLS ───
                      _sectionTitle('PRIVACY PREFERENCES'),
                      const SizedBox(height: 10),
                      AnzorCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _switchTile('Public Profile Discovery', 'Allow non-members to view and copy prompts', _isPublic, (val) => setState(() => _isPublic = val)),
                            const Divider(color: Color(0x1BFFFFFF), height: 1),
                            _switchTile('Show Email Address', 'Display contact email on creator profile', _showEmail, (val) => setState(() => _showEmail = val)),
                            const Divider(color: Color(0x1BFFFFFF), height: 1),
                            _switchTile('Show Followers Lists', 'Make followers counts and tags public', _showFollowers, (val) => setState(() => _showFollowers = val)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Glass Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildFrostedHeader(topPad, appState),
          ),

          // Bottom Action Drawer
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomActions(appState),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Component Builders
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFrostedHeader(double topPad, AppState appState) {
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
                    'Creator Studio Editor',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  Text(
                    'Build your professional AI creator identity.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard(AppState appState) {
    final myProfile = appState.currentUserProfile;
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
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(myProfile.avatar),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _nameController.text.isEmpty ? myProfile.username : _nameController.text,
                      style: GoogleFonts.spaceGrotesk(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded, color: AppTheme.brandOrange, size: 13),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _bioController.text.isEmpty ? 'No biography set' : _bioController.text,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: _selectedModels.map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                    child: Text(m, style: GoogleFonts.inter(fontSize: 7.5, color: Colors.white54)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white),
      validator: (val) => val == null || val.trim().isEmpty ? 'Field cannot be empty' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 12),
        floatingLabelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.brandOrange, fontWeight: FontWeight.bold, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white30, size: 16),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.brandOrange, width: 1.2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0,
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      value: val,
      onChanged: onChanged,
      activeColor: AppTheme.brandOrange,
      title: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white30)),
    );
  }

  Widget _buildBottomActions(AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnzorButton(
              onPressed: () => _saveChanges(appState),
              radius: 12,
              height: 48,
              gradient: AppTheme.brandGradient,
              glowColor: AppTheme.brandOrange,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Studio Details', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
