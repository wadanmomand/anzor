import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../widgets/glass_widgets.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF06050C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06050C),
        title: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.brandGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.srcIn,
              child: Text(
                localizations.translate('history_title'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              localizations.translate('history_subtitle'),
              style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: appState.historyList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 55,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.translate('history_empty'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.historyList.length,
              itemBuilder: (context, index) {
                final item = appState.historyList[index];
                return _buildTimelineItem(context, item, index, appState, localizations);
              },
            ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    HistoryItem item,
    int index,
    AppState appState,
    AppLocalizations localizations,
  ) {
    String dateStr = '';
    try {
      final date = DateTime.parse(item.date);
      dateStr = '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      dateStr = item.date;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Node
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0 ? AppTheme.brandOrange : Colors.grey[700],
                  border: Border.all(
                    color: index == 0
                        ? AppTheme.brandOrange.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2.0,
                  color: Colors.grey[700]?.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // History Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131024),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: index == 0
                        ? AppTheme.brandOrange.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.06),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: index == 0
                          ? AppTheme.brandOrange.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.brandOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.style,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: AppTheme.brandOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Raw Idea
                    Text(
                      '"${item.rawIdea}"',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Expanded snippet
                    Text(
                      item.expandedPrompt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── Action Toolbar ── AnzorActionButton ──────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AnzorActionButton(
                          icon: Icons.copy_rounded,
                          label: localizations.translate('copy_btn'),
                          variant: AnzorActionButtonVariant.primary,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: item.expandedPrompt));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prompt copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        AnzorActionButton(
                          icon: Icons.edit_rounded,
                          label: localizations.translate('edit_btn'),
                          onTap: () => _showEditDialog(context, item, appState, localizations),
                        ),
                        AnzorActionButton(
                          icon: Icons.refresh_rounded,
                          label: localizations.translate('regenerate_btn'),
                          onTap: () {
                            appState.generatePromptAction(item.rawIdea);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Regenerating prompt…')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    HistoryItem item,
    AppState appState,
    AppLocalizations localizations,
  ) {
    final TextEditingController ctrl = TextEditingController(text: item.expandedPrompt);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13141A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Edit Prompt',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: ctrl,
            maxLines: 5,
            style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: Colors.white),
            cursorColor: AppTheme.brandOrange,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.brandOrange, width: 1.2),
              ),
            ),
          ),
          actions: [
            AnzorActionButton(
              icon: Icons.close_rounded,
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
            AnzorActionButton(
              icon: Icons.check_rounded,
              label: 'Save',
              variant: AnzorActionButtonVariant.primary,
              onTap: () {
                final newContent = ctrl.text.trim();
                if (newContent.isNotEmpty) {
                  appState.updateHistoryItem(HistoryItem(
                    id: item.id,
                    rawIdea: item.rawIdea,
                    expandedPrompt: newContent,
                    explanation: item.explanation,
                    style: item.style,
                    presets: item.presets,
                    date: item.date,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prompt updated!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
