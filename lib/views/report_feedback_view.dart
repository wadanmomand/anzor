import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class ReportFeedbackView extends StatefulWidget {
  const ReportFeedbackView({super.key});

  @override
  State<ReportFeedbackView> createState() => _ReportFeedbackViewState();
}

class _ReportFeedbackViewState extends State<ReportFeedbackView>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _successController;

  int _selectedReportType = -1;
  String _selectedCategory = '';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showHistory = false;
  String _ticketId = '';

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<Map<String, dynamic>> _reportTypes = [
    {'icon': Icons.image_outlined, 'label': 'Report Prompt', 'color': const Color(0xFFFF7A00), 'desc': 'Inappropriate or rule-breaking prompt content'},
    {'icon': Icons.person_outline_rounded, 'label': 'Report Creator', 'color': const Color(0xFFE040FB), 'desc': 'Abusive or suspicious creator behavior'},
    {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Report Comment', 'color': const Color(0xFF00D9FF), 'desc': 'Harmful or offensive comment in discussions'},
    {'icon': Icons.collections_bookmark_outlined, 'label': 'Report Collection', 'color': const Color(0xFFFFC107), 'desc': 'Collections with inappropriate content'},
    {'icon': Icons.bug_report_outlined, 'label': 'Report Bug', 'color': const Color(0xFF00E5A0), 'desc': 'Something is broken or not working correctly'},
    {'icon': Icons.lightbulb_outline_rounded, 'label': 'Suggest Feature', 'color': const Color(0xFFFF4D6A), 'desc': 'Share your ideas to improve Anzor'},
    {'icon': Icons.feedback_outlined, 'label': 'General Feedback', 'color': const Color(0xFF7C4DFF), 'desc': 'General platform feedback and suggestions'},
  ];

  final List<String> _categories = [
    'Spam', 'Copyright', 'Harassment', 'Fake Content', 'NSFW',
    'Misinformation', 'Scam', 'Violence', 'Technical Issue',
    'UI Bug', 'Performance', 'Feature Request',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  final List<Map<String, dynamic>> _reportHistory = [
    {'id': 'ANZ-8823', 'type': 'Report Prompt', 'status': 'Resolved', 'date': '3 days ago', 'resolution': 'Content removed', 'icon': Icons.image_outlined, 'statusColor': const Color(0xFF00E5A0)},
    {'id': 'ANZ-8614', 'type': 'Report Bug', 'status': 'In Review', 'date': '1 week ago', 'resolution': 'Under investigation', 'icon': Icons.bug_report_outlined, 'statusColor': const Color(0xFFFFC107)},
    {'id': 'ANZ-7990', 'type': 'Suggest Feature', 'status': 'Planned', 'date': '2 weeks ago', 'resolution': 'Added to roadmap', 'icon': Icons.lightbulb_outline_rounded, 'statusColor': const Color(0xFF00D9FF)},
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _successController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
      _ticketId = 'ANZ-${(8000 + DateTime.now().millisecond % 999)}';
    });
    _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    if (_showSuccess) return _buildSuccessScreen();
    if (_showHistory) return _buildHistoryScreen(topPad);

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.brandOrange.withValues(alpha: 0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.electricBlue.withValues(alpha: 0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 90)),

              // ─── AI ASSISTANT INSIGHT ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AnzorCard(
                    padding: const EdgeInsets.all(14),
                    addGlow: true,
                    glowColor: AppTheme.brandOrange,
                    backgroundGradientColors: [
                      AppTheme.brandOrange.withValues(alpha: 0.08),
                      AppTheme.brandOrange.withValues(alpha: 0.02),
                    ],
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [AppTheme.brandOrange.withValues(alpha: 0.3), Colors.transparent],
                            ),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Trust Assistant', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.brandOrange)),
                              const SizedBox(height: 2),
                              Text('Select a report type below. I\'ll help you categorize and describe it perfectly.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── SECTION LABEL ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text('REPORT TYPE', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                ),
              ),

              // ─── REPORT TYPE GRID ───
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReportTypeCard(index),
                    childCount: _reportTypes.length,
                  ),
                ),
              ),

              // ─── SMART CATEGORIES ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text('SMART CATEGORIES', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSel = _selectedCategory == cat;
                      return AnzorChip(
                        label: cat,
                        isSelected: isSel,
                        onTap: () {
                          setState(() => _selectedCategory = isSel ? '' : cat);
                          HapticFeedback.selectionClick();
                        },
                      );
                    },
                  ),
                ),
              ),

              // ─── REPORT DETAILS FORM ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: AnzorCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('REPORT DETAILS'),
                        const SizedBox(height: 14),
                        _buildPrioritySelector(),
                        const SizedBox(height: 14),
                        AnzorInput(
                          controller: _descriptionController,
                          hintText: 'Describe the issue in detail...',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 5,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        // AI Description improver
                        if (_descriptionController.text.length > 10)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.brandOrange.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.brandOrange.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_fix_high_rounded, color: AppTheme.brandOrange, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('AI Suggestion: Add specific timestamps or links for faster review.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white54)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 14),
                        AnzorInput(
                          controller: _emailController,
                          hintText: 'Optional: your email for updates',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── ATTACHMENTS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AnzorCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('ATTACHMENTS'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _attachmentButton(Icons.screenshot_monitor_rounded, 'Screenshot'),
                            const SizedBox(width: 10),
                            _attachmentButton(Icons.video_library_outlined, 'Recording'),
                            const SizedBox(width: 10),
                            _attachmentButton(Icons.attach_file_rounded, 'Log File'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── SUBMISSION PREVIEW ───
              if (_selectedReportType >= 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: AnzorCard(
                      padding: const EdgeInsets.all(16),
                      addGlow: true,
                      glowColor: AppTheme.electricBlue,
                      backgroundGradientColors: [
                        AppTheme.electricBlue.withValues(alpha: 0.06),
                        AppTheme.electricBlue.withValues(alpha: 0.01),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.preview_rounded, color: AppTheme.electricBlue, size: 15),
                              const SizedBox(width: 8),
                              Text('SUBMISSION PREVIEW', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.electricBlue, letterSpacing: 1.2)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _previewRow('Type', _reportTypes[_selectedReportType]['label'] as String),
                          _previewRow('Category', _selectedCategory.isEmpty ? 'Not selected' : _selectedCategory),
                          _previewRow('Priority', _selectedPriority),
                          _previewRow('Est. Review', _selectedPriority == 'Critical' ? '< 4 hours' : _selectedPriority == 'High' ? '< 24 hours' : '2-5 days'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.electricBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('A ticket ID will be generated after submission.', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.electricBlue)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: const SizedBox(height: 120)),
            ],
          ),

          // ─── GLASS HEADER ───
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildHeader(topPad),
          ),

          // ─── STICKY BOTTOM ACTION BAR ───
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
          color: const Color(0xD506050C),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report & Feedback', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('Help us improve the Anzor community.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white70, size: 20),
                onPressed: () => setState(() => _showHistory = true),
                tooltip: 'Report History',
              ),
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 20),
                onPressed: () {},
                tooltip: 'Help Center',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: const Color(0xEA06050C),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Row(
            children: [
              // Save Draft
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_outlined, color: Colors.white60, size: 16),
                          const SizedBox(width: 6),
                          Text('Save Draft', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Submit
              Expanded(
                flex: 3,
                child: AnzorButton(
                  height: 50,
                  onPressed: _selectedReportType >= 0 ? _submitReport : null,
                  isLoading: _isSubmitting,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Submit Report', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeCard(int index) {
    final type = _reportTypes[index];
    final isSelected = _selectedReportType == index;
    final color = type['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedReportType = isSelected ? -1 : index);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFF0F0E1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isSelected ? 0.2 : 0.08),
              ),
              child: Icon(type['icon'] as IconData, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(type['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.white70)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: _priorities.map((p) {
            final isSel = _selectedPriority == p;
            final colors = {'Low': Colors.green, 'Medium': AppTheme.brandOrange, 'High': const Color(0xFFFF4D6A), 'Critical': const Color(0xFFE040FB)};
            final c = colors[p]!;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedPriority = p);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? c.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? c : Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Text(p, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isSel ? c : Colors.white38)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _attachmentButton(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white38, size: 20),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38))),
          Expanded(child: Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4));
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.brandOrange.withValues(alpha: 0.3), Colors.transparent],
                    ),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.brandOrange, size: 56),
                ),
                const SizedBox(height: 28),
                Text('Report Submitted!', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Thank you for helping keep Anzor safe.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 28),
                AnzorCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _previewRow('Ticket ID', _ticketId),
                      _previewRow('Status', 'Under Review'),
                      _previewRow('Est. Review', '2–5 Business Days'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AnzorButton(
                  height: 50,
                  onPressed: () => setState(() { _showSuccess = false; _selectedReportType = -1; }),
                  child: Text('Return Home', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() { _showSuccess = false; _showHistory = true; }),
                  child: Text('Track Report →', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.brandOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryScreen(double topPad) {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 80)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _reportHistory[index];
                      final statusColor = item['statusColor'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnzorCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.brandOrange.withValues(alpha: 0.1),
                                ),
                                child: Icon(item['icon'] as IconData, color: AppTheme.brandOrange, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(item['id'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(item['status'] as String, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: statusColor)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item['type'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white60)),
                                    Text('${item['date']} • ${item['resolution']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _reportHistory.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
                  color: const Color(0xD506050C),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showHistory = false),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report History', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text('Your previous reports and resolutions.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
