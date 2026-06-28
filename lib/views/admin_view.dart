import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../localization/localization.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _quickActions = [
    'Approve Prompts', 'Reject Prompts', 'Manage Users', 'Feature Creators',
    'Send Broadcast', 'Manage Categories', 'Model Telemetry', 'Incident Reports'
  ];
  final List<Map<String, String>> _users = [
    {'name': 'NeonKitten', 'role': 'Elite Creator', 'status': 'Active', 'reputation': '98.5%'},
    {'name': 'alex_prompt', 'role': 'Creator', 'status': 'Warned', 'reputation': '84.2%'},
    {'name': 'spammer_ai', 'role': 'Guest', 'status': 'Suspended', 'reputation': '12.0%'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchAdminData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final topPad = MediaQuery.of(context).padding.top;
    final pendingPrompts = appState.adminPrompts.where((p) => p.status == 'pending').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      body: Stack(
        children: [
          // Ambient neon backgrounds
          Positioned(
            top: -80, right: -80,
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
          Positioned(
            bottom: -60, left: -60,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.electricBlue.withValues(alpha: 0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          // Scrollable Workspace Layout
          TabBarView(
            controller: _tabController,
            children: [
              // ─── TAB 1: METRICS & CONSOLE ───
              _buildMetricsTab(context, appState, topPad),

              // ─── TAB 2: MODERATION QUEUE ───
              _buildModerationTab(context, pendingPrompts, appState, topPad),

              // ─── TAB 3: USER MANAGEMENT ───
              _buildUserManagementTab(context, appState, topPad),

              // ─── TAB 4: SYSTEM HEALTH ───
              _buildSystemHealthTab(context, appState, topPad),
            ],
          ),

          // Glass Header
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
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 8),
          color: const Color(0xD206050C),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        'Admin Dashboard',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                        ),
                      ),
                      Text(
                        'Telemetry Console & Marketplace Control Center',
                        style: GoogleFonts.inter(
                          fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tab Controls
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.brandOrange,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.white30,
                labelColor: AppTheme.brandOrange,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Moderation'),
                  Tab(text: 'Users'),
                  Tab(text: 'Console Logs'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: METRICS & CONSOLE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMetricsTab(BuildContext context, AppState appState, double topPad) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topPad + 110)),

        // Stats grid list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildMetricBox(context, 'Total User Base', '1,452 users', Icons.people_outline_rounded, AppTheme.electricBlue),
              _buildMetricBox(context, 'Active Node Sessions', '248 live', Icons.online_prediction_rounded, const Color(0xFF00FF7F)),
              _buildMetricBox(context, 'Pending Reviews', '${appState.adminPrompts.where((p) => p.status == 'pending').length} items', Icons.hourglass_empty_rounded, AppTheme.brandOrange),
              _buildMetricBox(context, 'Estimated Revenue', '\$12,450.00', Icons.wallet_rounded, const Color(0xFFFFD700)),
            ],
          ),
        ),

        // Quick Actions Grid Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'QUICK ADMINISTRATOR ACTIONS',
              style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
            ),
          ),
        ),

        // Quick actions Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.count(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: _quickActions.map((action) => _quickActionTile(action)).toList(),
          ),
        ),

        // Custom latency chart preview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API REQUEST LATENCY TRENDS (MS)',
                  style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  borderColor: AppTheme.brandOrange.withValues(alpha: 0.15),
                  child: const PerformanceChart(
                    title: 'LATENCY (MS) - SECURE API NODES',
                    dataPoints: [280, 310, 240, 420, 290, 340, 260, 305],
                    neonColor: AppTheme.brandOrange,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: MODERATION QUEUE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildModerationTab(BuildContext context, List<PromptItem> list, AppState appState, double topPad) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Icon(Icons.playlist_add_check_rounded, size: 38, color: Colors.white38),
            ),
            const SizedBox(height: 12),
            Text(
              'Moderation Queue is Clean',
              style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 120, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildModerationCard(context, item, appState);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3: USER MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUserManagementTab(BuildContext context, AppState appState, double topPad) {
    final users = _users;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 120, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        Color statusColor = Colors.green;
        if (user['status'] == 'Warned') statusColor = Colors.orange;
        if (user['status'] == 'Suspended') statusColor = Colors.red;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnzorCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://api.dicebear.com/7.x/bottts/png?seed=${user['name']}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name']!, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${user['role']} • Rep: ${user['reputation']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(user['status']!, style: GoogleFonts.inter(fontSize: 8.5, color: statusColor, fontWeight: FontWeight.bold)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white30, size: 18),
                  color: const Color(0xFF131024),
                  onSelected: (val) {
                    setState(() {
                      if (val == 'Warn') {
                        user['status'] = 'Warned';
                      } else if (val == 'Ban') {
                        user['status'] = 'Suspended';
                      } else if (val == 'Verify') {
                        user['role'] = 'Verified Creator';
                        user['status'] = 'Active';
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Action "$val" committed on user ${user['name']}.')),
                    );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Warn', child: Text('Send System Warning', style: TextStyle(color: Colors.white, fontSize: 12.5))),
                    const PopupMenuItem(value: 'Verify', child: Text('Grant Verified Badge', style: TextStyle(color: Colors.white, fontSize: 12.5))),
                    const PopupMenuItem(value: 'Ban', child: Text('Suspend/Ban Account', style: TextStyle(color: Colors.redAccent, fontSize: 12.5))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 4: SYSTEM HEALTH LOGS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSystemHealthTab(BuildContext context, AppState appState, double topPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPad + 120, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SYSTEM TELEMETRY STREAM',
                style: GoogleFonts.spaceGrotesk(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1.0),
              ),
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: AppTheme.brandOrange, size: 16),
                onPressed: () => appState.adminFetchMetricsAndLogs(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Log terminal box
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25), width: 1.2),
              ),
              child: appState.serverLogs.isEmpty
                  ? Center(
                      child: Text(
                        '> Initializing platform telemetry stream...',
                        style: GoogleFonts.firaCode(color: Colors.green.withValues(alpha: 0.5), fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: appState.serverLogs.length,
                      itemBuilder: (context, index) {
                        final log = appState.serverLogs[index];
                        Color lvlColor = Colors.green;
                        if (log.level == 'WARN') lvlColor = Colors.orange;
                        if (log.level == 'ERROR') lvlColor = Colors.redAccent;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '[${log.level}] [${log.source}] ${log.message}',
                            style: GoogleFonts.firaCode(fontSize: 10.5, color: lvlColor.withValues(alpha: 0.85)),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMetricBox(BuildContext context, String label, String val, IconData icon, Color color) {
    return AnzorCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            val,
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile(String title) {
    IconData actionIcon;
    switch (title) {
      case 'Approve Prompts':
        actionIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Reject Prompts':
        actionIcon = Icons.cancel_outlined;
        break;
      case 'Manage Users':
        actionIcon = Icons.people_alt_outlined;
        break;
      case 'Feature Creators':
        actionIcon = Icons.star_border_rounded;
        break;
      case 'Send Broadcast':
        actionIcon = Icons.broadcast_on_personal_rounded;
        break;
      case 'Manage Categories':
        actionIcon = Icons.category_outlined;
        break;
      case 'Model Telemetry':
        actionIcon = Icons.analytics_outlined;
        break;
      default:
        actionIcon = Icons.report_problem_outlined;
    }

    return GestureDetector(
      onTap: () {
        if (title == 'Approve Prompts' || title == 'Reject Prompts') {
          _tabController.animateTo(1);
        } else if (title == 'Manage Users') {
          _tabController.animateTo(2);
        } else if (title == 'Model Telemetry') {
          _tabController.animateTo(3);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Triggered Action: $title')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(actionIcon, size: 18, color: AppTheme.brandOrange),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 8.5, color: Colors.white54, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationCard(BuildContext context, PromptItem item, AppState appState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnzorCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample image preview
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                item.image,
                height: 100, width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100, width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.03),
                  child: const Icon(Icons.image_outlined, color: Colors.white24, size: 24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text('PENDING', style: GoogleFonts.inter(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Creator: ${item.author}  •  Category: ${item.category}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                  const Divider(color: Color(0x1BFFFFFF), height: 16),
                  Text(
                    item.prompt,
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white60, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                          onPressed: () => appState.adminModeratePrompt(item.id, 'reject'),
                          child: Text('Reject', style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnzorButton(
                          onPressed: () => appState.adminModeratePrompt(item.id, 'approve'),
                          radius: 8, height: 34,
                          gradient: AppTheme.brandGradient,
                          glowColor: AppTheme.brandOrange,
                          child: Text('Approve', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
