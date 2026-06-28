import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class LanguageLocalizationView extends StatefulWidget {
  const LanguageLocalizationView({super.key});
  @override
  State<LanguageLocalizationView> createState() => _LanguageLocalizationViewState();
}

class _LanguageLocalizationViewState extends State<LanguageLocalizationView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  String _searchQuery = '';
  String _selectedLanguage = 'English';
  String _selectedRegion = 'United States';
  bool _autoTranslate = true;
  bool _autoDetect = true;
  bool _translateComments = false;
  bool _translatePrompts = true;
  bool _isApplying = false;

  final List<Map<String, dynamic>> _languages = [
    {'code': 'en', 'flag': '🇺🇸', 'native': 'English', 'english': 'English', 'progress': 100, 'downloaded': true},
    {'code': 'ur', 'flag': '🇵🇰', 'native': 'اردو', 'english': 'Urdu', 'progress': 92, 'downloaded': true},
    {'code': 'ps', 'flag': '🇦🇫', 'native': 'پښتو', 'english': 'Pashto', 'progress': 78, 'downloaded': false},
    {'code': 'ar', 'flag': '🇸🇦', 'native': 'العربية', 'english': 'Arabic', 'progress': 95, 'downloaded': true},
    {'code': 'fa', 'flag': '🇮🇷', 'native': 'فارسی', 'english': 'Persian', 'progress': 88, 'downloaded': false},
    {'code': 'hi', 'flag': '🇮🇳', 'native': 'हिन्दी', 'english': 'Hindi', 'progress': 85, 'downloaded': false},
    {'code': 'tr', 'flag': '🇹🇷', 'native': 'Türkçe', 'english': 'Turkish', 'progress': 90, 'downloaded': true},
    {'code': 'es', 'flag': '🇪🇸', 'native': 'Español', 'english': 'Spanish', 'progress': 97, 'downloaded': true},
    {'code': 'fr', 'flag': '🇫🇷', 'native': 'Français', 'english': 'French', 'progress': 96, 'downloaded': true},
    {'code': 'de', 'flag': '🇩🇪', 'native': 'Deutsch', 'english': 'German', 'progress': 94, 'downloaded': false},
    {'code': 'zh', 'flag': '🇨🇳', 'native': '中文', 'english': 'Chinese', 'progress': 91, 'downloaded': false},
    {'code': 'ja', 'flag': '🇯🇵', 'native': '日本語', 'english': 'Japanese', 'progress': 89, 'downloaded': false},
  ];

  final List<Map<String, dynamic>> _offlinePacks = [
    {'flag': '🇺🇸', 'language': 'English', 'size': '8.2 MB', 'version': '2.4.0', 'updated': '2 days ago', 'installed': true},
    {'flag': '🇵🇰', 'language': 'Urdu', 'size': '6.8 MB', 'version': '2.3.5', 'updated': '5 days ago', 'installed': true},
    {'flag': '🇸🇦', 'language': 'Arabic', 'size': '7.4 MB', 'version': '2.3.0', 'updated': '2 weeks ago', 'installed': true},
    {'flag': '🇪🇸', 'language': 'Spanish', 'size': '8.0 MB', 'version': '2.4.0', 'updated': '3 days ago', 'installed': false},
  ];

  List<Map<String, dynamic>> get _filteredLanguages => _searchQuery.isEmpty
      ? _languages
      : _languages.where((l) =>
          (l['english'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (l['native'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

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
          Positioned(top: -60, right: -60, child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.07), Colors.transparent])))),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 130)),

              // CURRENT LANGUAGE HERO
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildCurrentLangHero())),

              // LIVE PREVIEW
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildLivePreview())),

              // LANGUAGES
              _sectionHeader('🌍 SUPPORTED LANGUAGES (${_filteredLanguages.length})'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildLangCard(_filteredLanguages[i])),
                  childCount: _filteredLanguages.length,
                )),
              ),

              // REGIONAL SETTINGS
              _sectionHeader('🌐 REGIONAL SETTINGS'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildRegionalCard())),

              // TRANSLATION PREFERENCES
              _sectionHeader('🔄 TRANSLATION PREFERENCES'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildTranslationPrefs())),

              // OFFLINE PACKS
              _sectionHeader('📦 OFFLINE LANGUAGE PACKS'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildOfflinePack(_offlinePacks[i])),
                  childCount: _offlinePacks.length,
                )),
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
        child: Column(children: [
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Language & Localization', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('Personalize Anzor in your preferred language.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
            ])),
            TextButton(onPressed: () {}, child: Text('Auto Detect', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange))),
          ]),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: _isSearchFocused ? AppTheme.brandOrange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.07)),
            ),
            child: TextField(
              controller: _searchController, focusNode: _searchFocus,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(hintText: 'Search languages...', hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white24), prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Colors.white30), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ]),
      ),
    ),
  );

  Widget _buildCurrentLangHero() => AnzorCard(
    padding: const EdgeInsets.all(18),
    addGlow: true,
    glowColor: AppTheme.brandOrange,
    backgroundGradientColors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
    child: Column(children: [
      Row(children: [
        const Text('🌍', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Current Language', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
          Text(_selectedLanguage, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        ]),
        const Spacer(),
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E5A0))),
        const SizedBox(width: 4),
        Text('Active', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5A0))),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _infoTile('🌐 Region', _selectedRegion),
        _infoTile('🕒 Time', '12-hour'),
        _infoTile('📅 Date', 'MM/DD/YYYY'),
      ]),
    ]),
  );

  Widget _infoTile(String label, String value) => Expanded(child: Column(children: [
    Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
    const SizedBox(height: 2),
    Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70), textAlign: TextAlign.center, maxLines: 1),
  ]));

  Widget _buildLivePreview() => AnzorCard(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.preview_rounded, color: AppTheme.brandOrange, size: 15),
        const SizedBox(width: 6),
        Text('LIVE PREVIEW', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.brandOrange, letterSpacing: 1)),
        const Spacer(),
        Text(_selectedLanguage == 'English' ? '🇺🇸' : _selectedLanguage == 'Urdu' ? '🇵🇰' : '🌍', style: const TextStyle(fontSize: 16)),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_selectedLanguage == 'Urdu' ? 'انزور — اے آئی پرامپٹ اسٹوڈیو' : _selectedLanguage == 'Arabic' ? 'أنزور — استوديو الذكاء الاصطناعي' : 'Anzor — AI Prompt Studio', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.brandOrange, Color(0xFFFF8C00)]), borderRadius: BorderRadius.circular(8)), child: Text(_selectedLanguage == 'Urdu' ? 'شروع کریں' : _selectedLanguage == 'Arabic' ? 'ابدأ الآن' : 'Get Started', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withValues(alpha: 0.1))), child: Text(_selectedLanguage == 'Urdu' ? 'مزید جانیں' : _selectedLanguage == 'Arabic' ? 'اعرف أكثر' : 'Learn More', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60))),
          ]),
        ]),
      ),
    ]),
  );

  Widget _buildLangCard(Map<String, dynamic> lang) {
    final isSel = _selectedLanguage == lang['english'];
    return GestureDetector(
      onTap: () { setState(() => _selectedLanguage = lang['english'] as String); HapticFeedback.selectionClick(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.brandOrange.withValues(alpha: 0.08) : const Color(0xFF0F0E1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? AppTheme.brandOrange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06), width: isSel ? 1.4 : 1.0),
        ),
        child: Row(children: [
          Text(lang['flag'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang['native'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: isSel ? Colors.white : Colors.white70)),
            Text(lang['english'] as String, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white38)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (lang['downloaded'] == true)
              const Icon(Icons.download_done_rounded, color: Color(0xFF00E5A0), size: 14)
            else
              GestureDetector(onTap: () { HapticFeedback.lightImpact(); }, child: const Icon(Icons.download_rounded, color: Colors.white30, size: 14)),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                value: (lang['progress'] as int) / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(isSel ? AppTheme.brandOrange : const Color(0xFF00E5A0)),
                minHeight: 3,
              )),
            ),
            Text('${lang['progress']}%', style: GoogleFonts.inter(fontSize: 8.5, color: Colors.white30)),
          ]),
          if (isSel) ...[const SizedBox(width: 10), const Icon(Icons.check_circle_rounded, color: AppTheme.brandOrange, size: 18)],
        ]),
      ),
    );
  }

  Widget _buildRegionalCard() => AnzorCard(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _settingRow('Country', _selectedRegion, Icons.flag_rounded),
      _divider(),
      _settingRow('Time Zone', 'UTC+05:00 Karachi', Icons.access_time_rounded),
      _divider(),
      _settingRow('Date Format', 'MM/DD/YYYY', Icons.calendar_today_rounded),
      _divider(),
      _settingRow('Number Format', '1,234.56', Icons.tag_rounded),
      _divider(),
      _settingRow('Units', 'Metric', Icons.straighten_rounded),
    ]),
  );

  Widget _buildTranslationPrefs() => AnzorCard(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _switchRow('Auto Translate Comments', _translateComments, (v) => setState(() => _translateComments = v)),
      _divider(),
      _switchRow('Auto Translate Prompts', _translatePrompts, (v) => setState(() => _translatePrompts = v)),
      _divider(),
      _switchRow('Auto Detect Input Language', _autoDetect, (v) => setState(() => _autoDetect = v)),
      _divider(),
      _switchRow('Personalized Translations', _autoTranslate, (v) => setState(() => _autoTranslate = v)),
    ]),
  );

  Widget _buildOfflinePack(Map<String, dynamic> pack) => AnzorCard(
    padding: const EdgeInsets.all(14),
    child: Row(children: [
      Text(pack['flag'] as String, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(pack['language'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        Text('${pack['size']} • v${pack['version']} • Updated ${pack['updated']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
      ])),
      if (pack['installed'] == true)
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF00E5A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('Installed', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5A0), fontWeight: FontWeight.w700)))
      else
        GestureDetector(onTap: () { HapticFeedback.mediumImpact(); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.brandOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3))), child: Text('Download', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.brandOrange, fontWeight: FontWeight.w700)))),
    ]),
  );

  Widget _buildStickyBar() => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
        child: Row(children: [
          Expanded(child: GestureDetector(onTap: () {}, child: Container(height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Center(child: Text('Reset', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)))))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AnzorButton(height: 48, isLoading: _isApplying, onPressed: () async { setState(() => _isApplying = true); await Future.delayed(const Duration(milliseconds: 1200)); setState(() => _isApplying = false); HapticFeedback.mediumImpact(); }, child: Text('Apply Changes', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)))),
        ]),
      ),
    ),
  );

  SliverToBoxAdapter _sectionHeader(String label) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4))));
  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 8), color: Colors.white.withValues(alpha: 0.04));
  Widget _settingRow(String label, String value, IconData icon) => Row(children: [Icon(icon, color: Colors.white38, size: 16), const SizedBox(width: 10), Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70))), Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)), const SizedBox(width: 6), Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2), size: 16)]);
  Widget _switchRow(String label, bool val, ValueChanged<bool> onChanged) => Row(children: [Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70))), Switch(value: val, onChanged: onChanged, activeColor: AppTheme.brandOrange, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)]);
}
