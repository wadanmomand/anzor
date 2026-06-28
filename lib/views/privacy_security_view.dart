import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class PrivacySecurityView extends StatefulWidget {
  const PrivacySecurityView({super.key});
  @override
  State<PrivacySecurityView> createState() => _PrivacySecurityViewState();
}

class _PrivacySecurityViewState extends State<PrivacySecurityView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;
  bool _publicProfile = true;
  bool _showFollowers = true;
  bool _showActivity = false;
  bool _aiTraining = true;
  bool _biometric = true;
  bool _appLock = false;
  bool _twoFa = false;
  bool _searchVisible = true;
  bool _personalized = true;
  int _securityScore = 72;

  final List<Map<String, dynamic>> _checkup = [
    {'label': 'Strong Password', 'done': true},
    {'label': 'Email Verified', 'done': true},
    {'label': 'Phone Verified', 'done': false},
    {'label': '2FA Enabled', 'done': false},
    {'label': 'Recovery Email Added', 'done': true},
    {'label': 'No Suspicious Activity', 'done': true},
  ];

  final List<Map<String, dynamic>> _sessions = [
    {'device': 'iPhone 15 Pro', 'type': 'Mobile', 'os': 'iOS 17.4', 'country': 'Pakistan', 'ip': '***.***.12.45', 'lastActive': 'Now', 'current': true, 'icon': Icons.phone_iphone_rounded},
    {'device': 'MacBook Pro', 'type': 'Desktop', 'os': 'macOS 14', 'country': 'Pakistan', 'ip': '***.***.18.88', 'lastActive': '2 hours ago', 'current': false, 'icon': Icons.laptop_mac_rounded},
    {'device': 'Chrome Browser', 'type': 'Web', 'os': 'Windows 11', 'country': 'United Arab Emirates', 'ip': '***.***.44.12', 'lastActive': '3 days ago', 'current': false, 'icon': Icons.public_rounded},
  ];

  final List<Map<String, dynamic>> _permissions = [
    {'label': 'Camera', 'icon': Icons.camera_alt_rounded, 'granted': false, 'color': const Color(0xFF00D9FF)},
    {'label': 'Photos', 'icon': Icons.photo_library_rounded, 'granted': true, 'color': AppTheme.brandOrange},
    {'label': 'Notifications', 'icon': Icons.notifications_rounded, 'granted': true, 'color': const Color(0xFF00E5A0)},
    {'label': 'Storage', 'icon': Icons.storage_rounded, 'granted': true, 'color': const Color(0xFF7C4DFF)},
    {'label': 'Microphone', 'icon': Icons.mic_rounded, 'granted': false, 'color': const Color(0xFFFF4D6A)},
  ];

  final List<Map<String, dynamic>> _alerts = [
    {'icon': Icons.login_rounded, 'title': 'New Login Detected', 'desc': 'iPhone 15 Pro • Pakistan', 'time': 'Just now', 'color': const Color(0xFF00E5A0)},
    {'icon': Icons.lock_reset_rounded, 'title': 'Password Changed', 'desc': 'Via Security Settings', 'time': '3 days ago', 'color': AppTheme.brandOrange},
    {'icon': Icons.email_rounded, 'title': 'Email Updated', 'desc': 'New address confirmed', 'time': '1 week ago', 'color': AppTheme.electricBlue},
  ];

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scoreAnim = Tween<double>(begin: 0, end: _securityScore / 100).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic));
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          Positioned(top: -60, left: -60, child: Container(width: 240, height: 240, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.electricBlue.withValues(alpha: 0.07), Colors.transparent])))),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 90)),

              // SECURITY OVERVIEW
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildSecurityHero())),

              // SECURITY CHECKUP
              _sectionHeader('✅ SECURITY CHECKUP'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AnzorCard(padding: const EdgeInsets.all(16), child: Column(children: _checkup.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: c['done'] == true ? const Color(0xFF00E5A0).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05)), child: Icon(c['done'] == true ? Icons.check_rounded : Icons.close_rounded, color: c['done'] == true ? const Color(0xFF00E5A0) : Colors.white30, size: 12)),
                const SizedBox(width: 10),
                Expanded(child: Text(c['label'] as String, style: GoogleFonts.inter(fontSize: 13, color: c['done'] == true ? Colors.white70 : Colors.white38))),
                if (c['done'] != true) GestureDetector(onTap: () {}, child: Text('Fix', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.brandOrange, fontWeight: FontWeight.w700))),
              ]))).toList())))),

              // SESSIONS
              _sectionHeader('📱 ACTIVE SESSIONS'),
              SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildSessionCard(_sessions[i])), childCount: _sessions.length))),

              // ACCOUNT PROTECTION
              _sectionHeader('🔐 ACCOUNT PROTECTION'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AnzorCard(padding: const EdgeInsets.all(16), child: Column(children: [
                _actionRow('Change Password', Icons.lock_rounded, AppTheme.brandOrange, () {}),
                _divider(),
                _switchRow('Two-Factor Authentication', _twoFa, (v) => setState(() => _twoFa = v), Icons.security_rounded, const Color(0xFF00E5A0)),
                _divider(),
                _switchRow('Biometric Login', _biometric, (v) => setState(() => _biometric = v), Icons.fingerprint_rounded, AppTheme.electricBlue),
                _divider(),
                _switchRow('App Lock', _appLock, (v) => setState(() => _appLock = v), Icons.lock_outline_rounded, const Color(0xFF7C4DFF)),
              ])))),

              // PRIVACY CONTROLS
              _sectionHeader('🛡 PRIVACY CONTROLS'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AnzorCard(padding: const EdgeInsets.all(16), child: Column(children: [
                _switchRow('Public Profile', _publicProfile, (v) => setState(() => _publicProfile = v), Icons.person_rounded, AppTheme.brandOrange),
                _divider(),
                _switchRow('Show Activity', _showActivity, (v) => setState(() => _showActivity = v), Icons.timeline_rounded, const Color(0xFF00D9FF)),
                _divider(),
                _switchRow('Search Engine Visibility', _searchVisible, (v) => setState(() => _searchVisible = v), Icons.search_rounded, const Color(0xFF00E5A0)),
                _divider(),
                _switchRow('AI Training Permission', _aiTraining, (v) => setState(() => _aiTraining = v), Icons.smart_toy_rounded, const Color(0xFFFF4D6A)),
                _divider(),
                _switchRow('Personalized Recommendations', _personalized, (v) => setState(() => _personalized = v), Icons.recommend_rounded, const Color(0xFF7C4DFF)),
              ])))),

              // PERMISSIONS
              _sectionHeader('🔑 PERMISSION CENTER'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AnzorCard(padding: const EdgeInsets.all(16), child: Column(children: _permissions.map((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: (p['color'] as Color).withValues(alpha: 0.1)), child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 17)),
                const SizedBox(width: 12),
                Expanded(child: Text(p['label'] as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (p['granted'] == true ? const Color(0xFF00E5A0) : Colors.white.withValues(alpha: 0.06)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(p['granted'] == true ? 'Granted' : 'Denied', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: p['granted'] == true ? const Color(0xFF00E5A0) : Colors.white38))),
              ]))).toList())))),

              // SECURITY ALERTS
              _sectionHeader('⚠ SECURITY ALERTS'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildAlertCard(_alerts[i])), childCount: _alerts.length)),
              ),

              // DATA MANAGEMENT
              _sectionHeader('💾 DATA MANAGEMENT'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4),
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final items = [
                      {'label': 'Download My Data', 'icon': Icons.download_rounded, 'color': AppTheme.brandOrange},
                      {'label': 'Export Prompts', 'icon': Icons.upload_file_rounded, 'color': const Color(0xFF00D9FF)},
                      {'label': 'Clear Cache', 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF00E5A0)},
                      {'label': 'Delete Account', 'icon': Icons.delete_forever_rounded, 'color': const Color(0xFFFF4D6A)},
                    ];
                    final item = items[i];
                    final color = item['color'] as Color;
                    return GestureDetector(
                      onTap: () => HapticFeedback.mediumImpact(),
                      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))), child: Row(children: [
                        Icon(item['icon'] as IconData, color: color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item['label'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600), maxLines: 2)),
                      ])),
                    );
                  }, childCount: 4),
                ),
              ),
            ],
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyBar()),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
        color: const Color(0xD506050C),
        child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Privacy & Security', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('Protect your account and personal information.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
          ])),
          TextButton(onPressed: () {}, child: Text('Checkup', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange))),
          IconButton(icon: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 20), onPressed: () {}),
        ]),
      ),
    ),
  );

  Widget _buildSecurityHero() => AnzorCard(
    padding: const EdgeInsets.all(20),
    addGlow: true,
    glowColor: AppTheme.electricBlue,
    backgroundGradientColors: [AppTheme.electricBlue.withValues(alpha: 0.08), Colors.transparent],
    child: Column(children: [
      Row(children: [
        AnimatedBuilder(animation: _scoreAnim, builder: (_, __) => Stack(alignment: Alignment.center, children: [
          SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: _scoreAnim.value, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: AlwaysStoppedAnimation<Color>(_securityScore >= 80 ? const Color(0xFF00E5A0) : _securityScore >= 60 ? AppTheme.brandOrange : const Color(0xFFFF4D6A)), strokeWidth: 5)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$_securityScore', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('/100', style: GoogleFonts.inter(fontSize: 9, color: Colors.white38)),
          ]),
        ])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Security Score', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
          Text(_securityScore >= 80 ? 'Strong' : _securityScore >= 60 ? 'Fair' : 'Weak', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: _securityScore >= 80 ? const Color(0xFF00E5A0) : AppTheme.brandOrange)),
          Text('2 improvements recommended', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
        ])),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        _heroStat('${_sessions.length}', 'Devices', AppTheme.electricBlue),
        _heroStat(_twoFa ? 'ON' : 'OFF', '2FA', _twoFa ? const Color(0xFF00E5A0) : const Color(0xFFFF4D6A)),
        _heroStat('0', 'Alerts', const Color(0xFF00E5A0)),
      ]),
    ]),
  );

  Widget _heroStat(String val, String label, Color color) => Expanded(child: Column(children: [Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: color)), Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38))]));

  Widget _buildSessionCard(Map<String, dynamic> s) => AnzorCard(
    padding: const EdgeInsets.all(14),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: (s['current'] == true ? AppTheme.brandOrange : Colors.white.withValues(alpha: 0.06)).withValues(alpha: 0.15)), child: Icon(s['icon'] as IconData, color: s['current'] == true ? AppTheme.brandOrange : Colors.white54, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s['device'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
          if (s['current'] == true) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)), child: Text('This Device', style: GoogleFonts.inter(fontSize: 8.5, color: const Color(0xFF00E5A0), fontWeight: FontWeight.w700)))],
        ]),
        Text('${s['os']} • ${s['country']} • ${s['lastActive']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      ])),
      if (s['current'] != true) GestureDetector(onTap: () { HapticFeedback.mediumImpact(); }, child: Text('Sign Out', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFFF4D6A), fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _buildAlertCard(Map<String, dynamic> a) {
    final color = a['color'] as Color;
    return AnzorCard(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)), child: Icon(a['icon'] as IconData, color: color, size: 17)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(a['desc'] as String, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      ])),
      Text(a['time'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
    ]));
  }

  Widget _buildStickyBar() => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
        child: Row(children: [
          Expanded(child: GestureDetector(onTap: () {}, child: Container(height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Center(child: Text('Save Changes', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)))))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AnzorButton(height: 48, onPressed: () { HapticFeedback.mediumImpact(); }, child: Text('Run Security Checkup', style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)))),
        ]),
      ),
    ),
  );

  SliverToBoxAdapter _sectionHeader(String label) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4))));
  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 8), color: Colors.white.withValues(alpha: 0.04));
  Widget _actionRow(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 10), Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70))), Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2), size: 18)]));
  Widget _switchRow(String label, bool val, ValueChanged<bool> onChanged, IconData icon, Color color) => Row(children: [Icon(icon, color: color, size: 17), const SizedBox(width: 10), Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70))), Switch(value: val, onChanged: onChanged, activeColor: AppTheme.brandOrange, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)]);
}
