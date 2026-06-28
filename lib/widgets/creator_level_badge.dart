import 'package:flutter/material.dart';
import '../models/models.dart';

class CreatorLevelBadge extends StatelessWidget {
  final CreatorLevel level;
  final bool showLabel;
  final double iconSize;
  final double fontSize;

  const CreatorLevelBadge({
    Key? key,
    required this.level,
    this.showLabel = true,
    this.iconSize = 12.0,
    this.fontSize = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    List<Color> gradientColors;
    Color textColor;
    Color borderStrokeColor;

    switch (level) {
      case CreatorLevel.beginner:
        icon = Icons.eco_rounded;
        label = 'Beginner';
        gradientColors = [const Color(0xFF0F2027), const Color(0xFF203A43)];
        textColor = const Color(0xFF4ADE80);
        borderStrokeColor = const Color(0xFF4ADE80).withOpacity(0.3);
        break;
      case CreatorLevel.rising:
        icon = Icons.rocket_launch_rounded;
        label = 'Rising Star';
        gradientColors = [const Color(0xFF1E3C72), const Color(0xFF2A5298)];
        textColor = const Color(0xFF38BDF8);
        borderStrokeColor = const Color(0xFF38BDF8).withOpacity(0.3);
        break;
      case CreatorLevel.creator:
        icon = Icons.star_rounded;
        label = 'AI Creator';
        gradientColors = [const Color(0xFF240B36), const Color(0xFF3C1053)];
        textColor = const Color(0xFFC084FC);
        borderStrokeColor = const Color(0xFFC084FC).withOpacity(0.3);
        break;
      case CreatorLevel.pro:
        icon = Icons.diamond_rounded;
        label = 'Pro Creator';
        gradientColors = [const Color(0xFF051937), const Color(0xFF004D7A)];
        textColor = const Color(0xFF22D3EE);
        borderStrokeColor = const Color(0xFF22D3EE).withOpacity(0.4);
        break;
      case CreatorLevel.elite:
        icon = Icons.workspace_premium_rounded;
        label = 'Elite Architect';
        gradientColors = [const Color(0xFF3A1C1C), const Color(0xFF6B1111)];
        textColor = const Color(0xFFFB923C);
        borderStrokeColor = const Color(0xFFFB923C).withOpacity(0.4);
        break;
      case CreatorLevel.legend:
        icon = Icons.emoji_events_rounded;
        label = 'Legend';
        gradientColors = [const Color(0xFF2C240E), const Color(0xFF6B5311)];
        textColor = const Color(0xFFFACC15);
        borderStrokeColor = const Color(0xFFFACC15).withOpacity(0.5);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8.0 : 6.0,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: borderStrokeColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.08),
            blurRadius: 6.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
