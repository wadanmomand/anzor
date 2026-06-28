import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class DownloadsExportView extends StatefulWidget {
  const DownloadsExportView({super.key});
  @override
  State<DownloadsExportView> createState() => _DownloadsExportViewState();
}

class _DownloadsExportViewState extends State<DownloadsExportView>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'All';
  bool _isExporting = false;

  final List<String> _filters = ['All', 'PDF', 'DOCX', 'Markdown', 'CSV', 'JSON', 'ZIP', 'Today', 'This Week'];

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.download_rounded, 'label': 'Download Prompt', 'color': AppTheme.brandOrange},
    {'icon': Icons.upload_file_rounded, 'label': 'Export Collection', 'color': const Color(0xFF00D9FF)},
    {'icon': Icons.picture_as_pdf_rounded, 'label': 'Export PDF', 'color': const Color(0xFFFF4D6A)},
    {'icon': Icons.description_rounded, 'label': 'Export DOCX', 'color': const Color(0xFF7C4DFF)},
    {'icon': Icons.table_chart_rounded, 'label': 'Export CSV', 'color': const Color(0xFF00E5A0)},
    {'icon': Icons.backup_rounded, 'label': 'Backup All', 'color': AppTheme.brandGold},
    {'icon': Icons.cloud_sync_rounded, 'label': 'Sync Cloud', 'color': const Color(0xFF00D9FF)},
    {'icon': Icons.code_rounded, 'label': 'Export JSON', 'color': Colors.white54},
  ];

  final List<Map<String, dynamic>> _downloads = [
    {'name': 'Cyberpunk_Portrait_Prompt', 'type': 'PDF', 'size': '2.4 MB', 'date': 'Today, 2:30 PM', 'status': 'Completed', 'icon': Icons.picture_as_pdf_rounded, 'color': const Color(0xFFFF4D6A)},
    {'name': 'Marketing_Collection_Export', 'type': 'ZIP', 'size': '18.7 MB', 'date': 'Yesterday', 'status': 'Completed', 'icon': Icons.folder_zip_rounded, 'color': AppTheme.brandOrange},
    {'name': 'Analytics_Report_June', 'type': 'CSV', 'size': '0.8 MB', 'date': '2 days ago', 'status': 'Completed', 'icon': Icons.table_chart_rounded, 'color': const Color(0xFF00E5A0)},
    {'name': 'Creator_Profile_Backup', 'type': 'JSON', 'size': '5.2 MB', 'date': '1 week ago', 'status': 'Completed', 'icon': Icons.data_object_rounded, 'color': const Color(0xFF7C4DFF)},
    {'name': 'AI_Models_Comparison', 'type': 'DOCX', 'size': '1.1 MB', 'date': '2 weeks ago', 'status': 'Completed', 'icon': Icons.article_rounded, 'color': const Color(0xFF00D9FF)},
  ];

  final List<Map<String, dynamic>> _recentFiles = [
    {'name': 'Cyberpunk.pdf', 'format': 'PDF', 'time': '2h ago', 'color': const Color(0xFFFF4D6A)},
    {'name': 'Marketing.zip', 'format': 'ZIP', 'time': '1d ago', 'color': AppTheme.brandOrange},
    {'name': 'Analytics.csv', 'format': 'CSV', 'time': '2d ago', 'color': const Color(0xFF00E5A0)},
    {'name': 'Profile.json', 'format': 'JSON', 'time': '1w ago', 'color': const Color(0xFF7C4DFF)},
  ];

  final List<Map<String, dynamic>> _exportFormats = [
    {'format': 'PDF', 'icon': Icons.picture_as_pdf_rounded, 'color': const Color(0xFFFF4D6A), 'desc': 'Best for sharing'},
    {'format': 'DOCX', 'icon': Icons.description_rounded, 'color': const Color(0xFF00D9FF), 'desc': 'Editable document'},
    {'format': 'Markdown', 'icon': Icons.code_rounded, 'color': const Color(0xFF7C4DFF), 'desc': 'Developer friendly'},
    {'format': 'CSV', 'icon': Icons.table_chart_rounded, 'color': const Color(0xFF00E5A0), 'desc': 'Data analysis'},
    {'format': 'JSON', 'icon': Icons.data_object_rounded, 'color': AppTheme.brandOrange, 'desc': 'Full data export'},
    {'format': 'ZIP', 'icon': Icons.folder_zip_rounded, 'color': AppTheme.brandGold, 'desc': 'Bulk archive'},
  ];

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
              SliverToBoxAdapter(child: SizedBox(height: topPad + 110)),

              // STORAGE OVERVIEW
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildStorageHero())),

              // QUICK ACTIONS
              _sectionHeader('⚡ QUICK ACTIONS'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85),
                  delegate: SliverChildBuilderDelegate((_, i) => _buildQuickAction(_quickActions[i]), childCount: _quickActions.length),
                ),
              ),

              // RECENT FILES
              _sectionHeader('🕐 RECENT FILES'),
              SliverToBoxAdapter(child: SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _recentFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _buildRecentCard(_recentFiles[i]),
                ),
              )),

              // EXPORT CENTER
              _sectionHeader('📤 EXPORT FORMATS'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.5),
                  delegate: SliverChildBuilderDelegate((_, i) => _buildFormatCard(_exportFormats[i]), childCount: _exportFormats.length),
                ),
              ),

              // BACKUP & SYNC
              _sectionHeader('☁ BACKUP & SYNC'),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildBackupCard())),

              // DOWNLOAD HISTORY
              _sectionHeader('📋 DOWNLOAD HISTORY'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildDownloadCard(_downloads[i])),
                  childCount: _downloads.length,
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
              Text('Downloads & Exports', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('Manage, download, and back up your AI content.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
            ])),
            IconButton(icon: const Icon(Icons.filter_list_rounded, color: Colors.white70, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.storage_rounded, color: Colors.white70, size: 20), onPressed: () {}),
          ]),
          const SizedBox(height: 8),
          SizedBox(height: 28, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) => AnzorChip(label: _filters[i], isSelected: _activeFilter == _filters[i], onTap: () { setState(() => _activeFilter = _filters[i]); HapticFeedback.selectionClick(); }),
          )),
        ]),
      ),
    ),
  );

  Widget _buildStorageHero() => AnzorCard(
    padding: const EdgeInsets.all(18),
    addGlow: true,
    glowColor: AppTheme.brandOrange,
    backgroundGradientColors: [AppTheme.brandOrange.withValues(alpha: 0.08), Colors.transparent],
    child: Column(children: [
      Row(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 72, height: 72, child: CircularProgressIndicator(value: 0.62, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandOrange), strokeWidth: 5)),
          Column(mainAxisSize: MainAxisSize.min, children: [Text('62%', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)), Text('Used', style: GoogleFonts.inter(fontSize: 9, color: Colors.white38))]),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Storage Overview', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
          Text('6.2 GB used of 10 GB', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.62, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandOrange), minHeight: 5)),
        ])),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _storageStat('☁', 'Cloud', '4.8 GB', AppTheme.brandOrange),
        _storageStat('📱', 'Local', '1.4 GB', AppTheme.electricBlue),
        _storageStat('📂', 'Downloads', '127', const Color(0xFF00E5A0)),
        _storageStat('📤', 'Exports', '48', const Color(0xFF7C4DFF)),
      ]),
    ]),
  );

  Widget _storageStat(String emoji, String label, String value, Color color) => Expanded(child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 16)), Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w900, color: color)), Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38))]));

  Widget _buildQuickAction(Map<String, dynamic> action) {
    final color = action['color'] as Color;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(action['icon'] as IconData, color: color, size: 20),
          const SizedBox(height: 5),
          Text(action['label'] as String, style: GoogleFonts.inter(fontSize: 8.5, color: Colors.white60), textAlign: TextAlign.center, maxLines: 2),
        ]),
      ),
    );
  }

  Widget _buildRecentCard(Map<String, dynamic> file) {
    final color = file['color'] as Color;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)), child: Text(file['format'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w800, color: color))), const Spacer(), Icon(Icons.open_in_new_rounded, color: Colors.white30, size: 12)]),
        const SizedBox(height: 8),
        Text(file['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1),
        Text(file['time'] as String, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38)),
      ]),
    );
  }

  Widget _buildFormatCard(Map<String, dynamic> format) {
    final color = format['color'] as Color;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(format['icon'] as IconData, color: color, size: 20),
          const SizedBox(height: 5),
          Text(format['format'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(format['desc'] as String, style: GoogleFonts.inter(fontSize: 8.5, color: Colors.white38), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildBackupCard() => AnzorCard(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.cloud_done_rounded, color: Color(0xFF00E5A0), size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Last Backup', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
          Text('Today at 3:15 AM', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E5A0))),
        const SizedBox(width: 4),
        Text('Synced', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5A0))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GestureDetector(onTap: () { HapticFeedback.mediumImpact(); }, child: Container(height: 40, decoration: BoxDecoration(color: AppTheme.brandOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.3))), child: Center(child: Text('Backup Now', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.brandOrange)))))),
        const SizedBox(width: 8),
        Expanded(child: GestureDetector(onTap: () {}, child: Container(height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Center(child: Text('Restore', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white60)))))),
      ]),
    ]),
  );

  Widget _buildDownloadCard(Map<String, dynamic> d) {
    final color = d['color'] as Color;
    return AnzorCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)), child: Icon(d['icon'] as IconData, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d['name'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1),
          Text('${d['type']} • ${d['size']} • ${d['date']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
        ])),
        Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(onTap: () { HapticFeedback.lightImpact(); }, child: const Icon(Icons.share_rounded, color: Colors.white30, size: 16)),
          const SizedBox(width: 12),
          GestureDetector(onTap: () { HapticFeedback.lightImpact(); }, child: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 16)),
        ]),
      ]),
    );
  }

  Widget _buildStickyBar() => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
        child: AnzorButton(height: 48, isLoading: _isExporting, onPressed: () async { setState(() => _isExporting = true); await Future.delayed(const Duration(milliseconds: 1500)); setState(() => _isExporting = false); HapticFeedback.mediumImpact(); }, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.backup_rounded, color: Colors.white, size: 16), const SizedBox(width: 8), Text('Backup All Data', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))])),
      ),
    ),
  );

  SliverToBoxAdapter _sectionHeader(String label) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4))));
}
