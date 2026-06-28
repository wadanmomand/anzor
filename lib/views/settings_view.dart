import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _twoFactor = false;
  String _selectedModel = 'Midjourney v6';
  String _promptType = 'Text-to-Image';
  double _creativityLevel = 0.8;
  double _cacheSizeMB = 24.5;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;
    final myProfile = appState.currentUserProfile;

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

          // Scrollable Settings List
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 70)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ─── 1. ACCOUNT ───
                    _sectionHeader('ACCOUNT'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
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
                                          myProfile.username,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.brandOrange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'ELITE CREATOR',
                                            style: GoogleFonts.inter(
                                              fontSize: 7.5, color: AppTheme.brandOrange, fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'creator@anzor.ai',
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0x1BFFFFFF), height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white24, width: 0.8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Edit profile settings accessed.')),
                                    );
                                  },
                                  child: Text('Edit Profile', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AnzorButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Subscription management portal opened.')),
                                    );
                                  },
                                  radius: 10,
                                  gradient: AppTheme.brandGradient,
                                  glowColor: AppTheme.brandOrange,
                                  child: Text('Manage Plan', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 2. PREFERENCES ───
                    _sectionHeader('APPLICATION PREFERENCES'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _switchTile(
                            'Dark Mode Theme',
                            'Enable AMOLED deep dark visual profiles',
                            _darkMode,
                            (val) => setState(() => _darkMode = val),
                            Icons.dark_mode_rounded,
                          ),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          _switchTile(
                            'Push Notifications',
                            'Get alerts for prompt saves and likes',
                            _notifications,
                            (val) => setState(() => _notifications = val),
                            Icons.notifications_rounded,
                          ),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          _actionTile(
                            'Accent Colors Scheme',
                            'Gold Orange Signature theme active',
                            Icons.color_lens_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 3. AI SETTINGS ───
                    _sectionHeader('AI PREFERENCES COMMAND'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dropdownItem('Default AI Model', _selectedModel, [
                            'Midjourney v6', 'Flux.1 Pro', 'Stable Diffusion XL', 'DALL-E 3'
                          ], (val) {
                            if (val != null) setState(() => _selectedModel = val);
                          }),
                          const SizedBox(height: 16),
                          _dropdownItem('Default Workspace Style', _promptType, [
                            'Text-to-Image', 'Text-to-Text Prompt', 'Video Generation'
                          ], (val) {
                            if (val != null) setState(() => _promptType = val);
                          }),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Creativity Variance', style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('${(_creativityLevel * 100).toInt()}%', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.brandOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.brandOrange,
                              inactiveTrackColor: Colors.white10,
                              thumbColor: AppTheme.brandOrange,
                              overlayColor: AppTheme.brandOrange.withValues(alpha: 0.1),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _creativityLevel,
                              onChanged: (val) => setState(() => _creativityLevel = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 4. SECURITY & PRIVACY ───
                    _sectionHeader('SECURITY & SECURITY COMMAND'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _switchTile(
                            'Two-Factor Authentication',
                            'Enable extra verification keys on login',
                            _twoFactor,
                            (val) => setState(() => _twoFactor = val),
                            Icons.security_rounded,
                          ),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          _actionTile('Reset Workspace Password', 'Change password credentials', Icons.password_rounded),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          _actionTile('Active Device Sessions', 'Manage logged-in devices', Icons.devices_other_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 5. STORAGE CACHE ───
                    _sectionHeader('CACHE & DATA USAGE'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Application Cache Storage',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Speed up assets loading',
                                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white30),
                                  ),
                                ],
                              ),
                              Text(
                                '${_cacheSizeMB.toStringAsFixed(1)} MB',
                                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.brandOrange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: 0.35,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandOrange),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.brandOrange.withValues(alpha: 0.25)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                setState(() => _cacheSizeMB = 0.0);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Workspace cache storage cleared!')),
                                );
                              },
                              child: Text('Clear Workspace Cache', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.brandOrange, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 6. ABOUT APP ───
                    _sectionHeader('SYSTEM INFO'),
                    const SizedBox(height: 8),
                    AnzorCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _actionTile('Terms of Service Agreement', 'Read usage guidelines', Icons.article_rounded),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          _actionTile('Open Source Licenses', 'Read library attributes', Icons.handshake_rounded),
                          const Divider(color: Color(0x1BFFFFFF), height: 1),
                          ListTile(
                            title: Text('Anzor App Version', style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: Text('v1.2.0 (Build 36)', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── LOGOUT BUTTONS ───
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _confirmDeleteAccount(context),
                            child: Text(
                              'Delete Account',
                              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnzorButton(
                            height: 44,
                            radius: 12,
                            gradient: const LinearGradient(colors: [Color(0xFF222133), Color(0xFF222133)]),
                            onPressed: () => _confirmLogout(context),
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),

          // Frosted Glass AppBar Header
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
                    'Settings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                  Text(
                    'Manage your account and preferences.',
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
                    const SnackBar(content: Text('Help portal opened.')),
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
  // Helper builders
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1.0,
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged, IconData icon) {
    return SwitchListTile.adaptive(
      value: val,
      onChanged: onChanged,
      activeColor: AppTheme.brandOrange,
      secondary: Icon(icon, color: Colors.white60, size: 20),
      title: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white30)),
    );
  }

  Widget _actionTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60, size: 20),
      title: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white30)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped.')),
        );
      },
    );
  }

  Widget _dropdownItem(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF131024),
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white30, size: 14),
              items: items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131024),
        title: Text('Sign Out', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out of Anzor workspace?', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Pop settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully.')),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131024),
        title: Text('Delete Account', style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('WARNING: Deleting your account will permanently purge all creations, logs, and reputation stats. This cannot be undone.', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account permanently queued for deletion.')),
              );
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
