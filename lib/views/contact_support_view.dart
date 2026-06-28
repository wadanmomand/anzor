import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class ContactSupportView extends StatefulWidget {
  const ContactSupportView({super.key});
  @override
  State<ContactSupportView> createState() => _ContactSupportViewState();
}

class _ContactSupportViewState extends State<ContactSupportView>
    with SingleTickerProviderStateMixin {
  bool _showTickets = false;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String _ticketId = '';
  int _selectedCategory = -1;
  String _selectedPriority = 'Medium';

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<Map<String, dynamic>> _contactOptions = [
    {'icon': Icons.chat_bubble_outline_rounded, 'title': 'Live Chat', 'desc': 'Instant responses (Premium)', 'eta': 'Instant', 'color': AppTheme.brandOrange, 'available': false},
    {'icon': Icons.email_outlined, 'title': 'Email Support', 'desc': 'support@anzor.ai', 'eta': '< 24 hours', 'color': const Color(0xFF00D9FF), 'available': true},
    {'icon': Icons.confirmation_number_outlined, 'title': 'Submit Ticket', 'desc': 'Track your request online', 'eta': '1-3 days', 'color': const Color(0xFF00E5A0), 'available': true},
    {'icon': Icons.groups_rounded, 'title': 'Community', 'desc': 'Ask the creator community', 'eta': 'Minutes', 'color': const Color(0xFF7C4DFF), 'available': true},
  ];

  final List<String> _categories = ['General', 'Account', 'Bug Report', 'Premium', 'Privacy', 'Feature Request', 'Community'];
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  final List<Map<String, dynamic>> _myTickets = [
    {'id': 'ANZ-9101', 'subject': 'Prompt not generating correctly', 'status': 'Open', 'priority': 'High', 'date': '1 day ago', 'reply': '2 hours ago', 'statusColor': AppTheme.brandOrange},
    {'id': 'ANZ-8823', 'subject': 'Cannot access Premium features', 'status': 'Resolved', 'priority': 'Medium', 'date': '5 days ago', 'reply': '3 days ago', 'statusColor': const Color(0xFF00E5A0)},
    {'id': 'ANZ-8614', 'subject': 'Image export not working on iPad', 'status': 'In Review', 'priority': 'Low', 'date': '2 weeks ago', 'reply': '1 week ago', 'statusColor': const Color(0xFFFFC107)},
  ];

  final List<Map<String, dynamic>> _aiSuggestions = [
    {'text': 'Similar issue resolved: "Prompt generation timeout" — see solution →', 'type': 'solved'},
    {'text': 'Recommended article: "How to fix model connection errors"', 'type': 'article'},
    {'text': 'Est. resolution time: 4–8 hours based on category', 'type': 'eta'},
  ];

  final Map<String, String> _supportStats = {
    'Avg Response': '< 6 hours',
    'Satisfaction': '98%',
    'Queue': '14 tickets',
    'Status': 'Online',
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 2100));
    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
      _ticketId = 'ANZ-${9100 + DateTime.now().millisecond % 899}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    if (_showSuccess) return _buildSuccessScreen();
    if (_showTickets) return _buildTicketsScreen(topPad);

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
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
              SliverToBoxAdapter(child: SizedBox(height: topPad + 90)),

              // ─── SUPPORT HERO ───
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: _buildSupportHero())),

              // ─── CONTACT OPTIONS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('CONTACT OPTIONS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildContactCard(_contactOptions[i]),
                    childCount: _contactOptions.length,
                  ),
                ),
              ),

              // ─── SUPPORT FORM ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('SUBMIT SUPPORT TICKET', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnzorCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnzorInput(controller: _subjectController, hintText: 'Subject — What\'s your issue?', prefixIcon: Icons.title_rounded, onChanged: (_) => setState(() {})),
                      const SizedBox(height: 14),
                      // Category selector
                      Text('Category', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _categories.asMap().entries.map((e) {
                          final isSel = _selectedCategory == e.key;
                          return GestureDetector(
                            onTap: () { setState(() => _selectedCategory = isSel ? -1 : e.key); HapticFeedback.selectionClick(); },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.brandOrange.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSel ? AppTheme.brandOrange.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.07)),
                              ),
                              child: Text(e.value, style: GoogleFonts.inter(fontSize: 11, color: isSel ? AppTheme.brandOrange : Colors.white38, fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      // Priority
                      Text('Priority', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                      const SizedBox(height: 8),
                      Row(
                        children: _priorities.map((p) {
                          final isSel = _selectedPriority == p;
                          final colors = {'Low': Colors.green, 'Medium': AppTheme.brandOrange, 'High': const Color(0xFFFF4D6A), 'Critical': const Color(0xFFE040FB)};
                          final c = colors[p]!;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () { setState(() => _selectedPriority = p); HapticFeedback.selectionClick(); },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSel ? c.withValues(alpha: 0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSel ? c : Colors.white.withValues(alpha: 0.07)),
                                ),
                                child: Text(p, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: isSel ? c : Colors.white30)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      AnzorInput(
                        controller: _descController,
                        hintText: 'Describe your issue in detail...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 5, minLines: 3,
                        keyboardType: TextInputType.multiline,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      AnzorInput(controller: _emailController, hintText: 'Optional: your email for updates', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    ],
                  ),
                ),
              )),

              // ─── AI SUGGESTIONS ───
              if (_subjectController.text.length > 5) ...[
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.brandOrange, size: 13),
                    const SizedBox(width: 6),
                    Text('AI SUGGESTS BEFORE SUBMITTING', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2)),
                  ]),
                )),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final s = _aiSuggestions[i];
                        final colors = {'solved': const Color(0xFF00E5A0), 'article': AppTheme.electricBlue, 'eta': AppTheme.brandOrange};
                        final c = colors[s['type']]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(color: c.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withValues(alpha: 0.2))),
                            child: Row(children: [
                              Icon(Icons.lightbulb_outline_rounded, color: c, size: 14),
                              const SizedBox(width: 10),
                              Expanded(child: Text(s['text'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white60))),
                            ]),
                          ),
                        );
                      },
                      childCount: _aiSuggestions.length,
                    ),
                  ),
                ),
              ],

              // ─── ATTACHMENTS ───
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AnzorCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTACHMENTS', style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.4)),
                      const SizedBox(height: 12),
                      Row(children: [
                        _attachBtn(Icons.screenshot_monitor_rounded, 'Screenshot'),
                        const SizedBox(width: 8),
                        _attachBtn(Icons.videocam_outlined, 'Recording'),
                        const SizedBox(width: 8),
                        _attachBtn(Icons.attach_file_rounded, 'File'),
                      ]),
                    ],
                  ),
                ),
              )),

              SliverToBoxAdapter(child: const SizedBox(height: 110)),
            ],
          ),

          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(topPad)),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
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
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Contact Support', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('We\'re here to help you succeed.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
              ])),
              TextButton(onPressed: () => setState(() => _showTickets = true), child: Text('My Tickets', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.brandOrange))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportHero() {
    return AnzorCard(
      padding: const EdgeInsets.all(18),
      addGlow: true,
      glowColor: AppTheme.electricBlue,
      backgroundGradientColors: [AppTheme.electricBlue.withValues(alpha: 0.08), Colors.transparent],
      child: Column(
        children: [
          Row(children: [
            const Text('💬', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Anzor Support', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('We\'re here 24/7 to resolve every issue.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
            ])),
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E5A0))),
            const SizedBox(width: 4),
            Text('Online', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF00E5A0))),
          ]),
          const SizedBox(height: 14),
          Row(
            children: _supportStats.entries.map((e) => Expanded(child: Column(children: [
              Text(e.value, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.brandOrange)),
              Text(e.key, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
            ]))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> option) {
    final color = option['color'] as Color;
    final available = option['available'] as bool;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: available ? color.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: available ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(option['icon'] as IconData, color: available ? color : Colors.white24, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(option['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w800, color: available ? Colors.white : Colors.white30)),
              Text('ETA: ${option['eta']}', style: GoogleFonts.inter(fontSize: 9.5, color: available ? color : Colors.white.withValues(alpha: 0.2))),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _attachBtn(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white38, size: 18),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white30)),
          ]),
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
          decoration: BoxDecoration(color: const Color(0xEA06050C), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                    child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.save_outlined, color: Colors.white60, size: 16),
                      const SizedBox(width: 6),
                      Text('Save Draft', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)),
                    ])),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: AnzorButton(
                  height: 50,
                  onPressed: _selectedCategory >= 0 ? _submit : null,
                  isLoading: _isSubmitting,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text('Submit Ticket', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.brandOrange.withValues(alpha: 0.3), Colors.transparent])),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.brandOrange, size: 50),
                ),
                const SizedBox(height: 24),
                Text('Ticket Submitted!', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Our team will respond within 6–24 hours.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 28),
                AnzorCard(padding: const EdgeInsets.all(20), child: Column(children: [
                  _ticketRow('Ticket ID', _ticketId),
                  _ticketRow('Status', 'Open'),
                  _ticketRow('Priority', _selectedPriority),
                  _ticketRow('Estimated', '6–24 hours'),
                ])),
                const SizedBox(height: 24),
                AnzorButton(
                  height: 50,
                  onPressed: () => Navigator.pop(context),
                  child: Text('Return Home', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() { _showSuccess = false; _showTickets = true; }),
                  child: Text('Track Ticket →', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.brandOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38))),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white70)),
      ]),
    );
  }

  Widget _buildTicketsScreen(double topPad) {
    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 80)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final ticket = _myTickets[i];
                      final statusColor = ticket['statusColor'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnzorCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(ticket['id'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                  child: Text(ticket['status'] as String, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: statusColor)),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Text(ticket['subject'] as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                              const SizedBox(height: 8),
                              Row(children: [
                                Text('${ticket['date']} • Last reply: ${ticket['reply']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                                const Spacer(),
                                _miniBtn('Reply', AppTheme.brandOrange),
                              ]),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _myTickets.length,
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
                        onTap: () => setState(() => _showTickets = false),
                        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('My Support Tickets', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('Track and manage your requests.', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45))),
                      ]),
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

  Widget _miniBtn(String label, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }
}
