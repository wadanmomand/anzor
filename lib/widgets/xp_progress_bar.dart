import 'package:flutter/material.dart';
import '../models/models.dart';

class XpProgressBar extends StatefulWidget {
  final int xp;
  final CreatorLevel level;

  const XpProgressBar({
    Key? key,
    required this.xp,
    required this.level,
  }) : super(key: key);

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _getMinXpForLevel(CreatorLevel level) {
    switch (level) {
      case CreatorLevel.beginner: return 0;
      case CreatorLevel.rising: return 500;
      case CreatorLevel.creator: return 1500;
      case CreatorLevel.pro: return 3000;
      case CreatorLevel.elite: return 6000;
      case CreatorLevel.legend: return 12000;
    }
  }

  int _getMaxXpForLevel(CreatorLevel level) {
    switch (level) {
      case CreatorLevel.beginner: return 500;
      case CreatorLevel.rising: return 1500;
      case CreatorLevel.creator: return 3000;
      case CreatorLevel.pro: return 6000;
      case CreatorLevel.elite: return 12000;
      case CreatorLevel.legend: return 25000;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final minXp = _getMinXpForLevel(widget.level);
    final maxXp = _getMaxXpForLevel(widget.level);
    final progress = ((widget.xp - minXp) / (maxXp - minXp)).clamp(0.0, 1.0);

    _animation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant XpProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.xp != widget.xp || oldWidget.level != widget.level) {
      final minXp = _getMinXpForLevel(widget.level);
      final maxXp = _getMaxXpForLevel(widget.level);
      final progress = ((widget.xp - minXp) / (maxXp - minXp)).clamp(0.0, 1.0);

      _animation = Tween<double>(
        begin: _animation.value,
        end: progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxXp = _getMaxXpForLevel(widget.level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Creator Experience',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.0,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.xp} / $maxXp XP',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: 8.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 1.0,
                ),
              ),
              child: FractionalTranslation(
                translation: Offset(0, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: (_animation.value * 1000).toInt(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF6A00),
                              Color(0xFFFF9800),
                              Color(0xFFFFC107),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6A00).withOpacity(0.35),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: ((1.0 - _animation.value) * 1000).toInt(),
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
