import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

// Glassmorphic blurred panel
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color borderColor;
  final double blur;
  final EdgeInsetsGeometry padding;
  final bool addGlow;
  final Color glowColor;
  final List<Color>? backgroundGradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 16.0,
    this.borderColor = const Color(0x17FFFFFF),
    this.blur = 15.0,
    this.padding = const EdgeInsets.all(16.0),
    this.addGlow = false,
    this.glowColor = AppTheme.brandOrange,
    this.backgroundGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Performance: No BackdropFilter and no ClipRRect.
    // ClipRRect forces a GPU stencil operation in Impeller on Android OpenGLES
    // (x86_64 emulators) which causes diagonal canvas corruption artifacts.
    // BoxDecoration.borderRadius clips the gradient background without stencil cost.
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: backgroundGradientColors != null
            ? LinearGradient(
                colors: backgroundGradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0x180A0E1A), // subtle glass over navy
                        Color(0x0B0A0E1A),
                      ]
                    : const [
                        Color(0xF0FFFFFF),
                        Color(0xD8FFFFFF),
                      ],
              ),
        border: Border.all(
          color: isDark ? borderColor : const Color(0x0F000000),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x08000000),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          if (addGlow && isDark)
            BoxShadow(
              color: glowColor.withValues(alpha: 0.22),
              blurRadius: 28,
              spreadRadius: 2,
            )
        ],
      ),
      child: child,
    );
  }
}

// Neon glowing interactive button
class NeonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final LinearGradient gradient;
  final Color glowColor;
  final double radius;
  final double height;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = AppTheme.brandGradient,
    this.glowColor = AppTheme.brandOrange,
    this.radius = 14.0,
    this.height = 52.0,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    )..addListener(() {
        setState(() {
          _scale = _controller.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.forward(),
      onTap: (widget.onPressed == null || widget.isLoading) ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null ? null : widget.gradient,
            color: widget.onPressed == null ? const Color(0xFF2A3048) : null,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              if (widget.onPressed != null && isDark)
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              if (widget.onPressed != null && isDark)
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.15),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}

// Rounded horizontally scrollable category selection chips
class StyleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeGlowColor;

  const StyleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeGlowColor = AppTheme.brandOrange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeGlowColor.withOpacity(0.2)
              : (isDark ? const Color(0x0EFFFFFF) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeGlowColor
                : (isDark ? const Color(0x1BFFFFFF) : Colors.transparent),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected && isDark)
              BoxShadow(
                color: activeGlowColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              )
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? Colors.white : activeGlowColor)
                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              ),
        ),
      ),
    );
  }
}

// Custom Painter Chart for Admin Panel (System Telemetry Monitor)
class PerformanceChart extends StatelessWidget {
  final List<double> dataPoints;
  final String title;
  final Color neonColor;
  final bool showBars;

  const PerformanceChart({
    super.key,
    required this.dataPoints,
    required this.title,
    this.neonColor = AppTheme.electricBlue,
    this.showBars = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.electricBlue,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(
                points: dataPoints,
                neonColor: neonColor,
                drawBars: showBars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> points;
  final Color neonColor;
  final bool drawBars;

  _ChartPainter({
    required this.points,
    required this.neonColor,
    required this.drawBars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double stepX = width / (points.length - 1);
    final double maxVal = points.reduce((a, b) => a > b ? a : b) + 1.0;

    final paintLine = Paint()
      ..color = neonColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGlow = Paint()
      ..color = neonColor.withOpacity(0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final path = Path();
    final fillPath = Path();

    // Map Y coordinates
    double getY(double val) => height - ((val / maxVal) * (height - 10));

    if (drawBars) {
      // Draw neon grid bars
      final double barWidth = (width / points.length) * 0.6;
      final double spacing = (width / points.length) * 0.4;
      final paintBar = Paint()..style = PaintingStyle.fill;

      for (int i = 0; i < points.length; i++) {
        final double x = (i * (barWidth + spacing)) + (barWidth / 2);
        final double y = getY(points[i]);

        final rect = Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, height);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

        // Draw shadow glow first
        paintBar.color = neonColor.withOpacity(0.15);
        canvas.drawRRect(rrect.inflate(3), paintBar);

        // Draw solid bar
        final barGradient = LinearGradient(
          colors: [neonColor, neonColor.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        paintBar.shader = barGradient.createShader(rect);
        canvas.drawRRect(rrect, paintBar);
        paintBar.shader = null; // Clear shader
      }
    } else {
      // Draw smooth line curve
      path.moveTo(0, getY(points[0]));
      fillPath.moveTo(0, height);
      fillPath.lineTo(0, getY(points[0]));

      for (int i = 1; i < points.length; i++) {
        final double x = i * stepX;
        final double y = getY(points[i]);
        
        // Bezier interpolation points for smoothness
        final double prevX = (i - 1) * stepX;
        final double prevY = getY(points[i - 1]);
        final double controlX1 = prevX + (stepX / 2);
        final double controlY1 = prevY;
        final double controlX2 = prevX + (stepX / 2);
        final double controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }

      fillPath.lineTo(width, height);
      fillPath.close();

      // Draw neon line shadow glow
      canvas.drawPath(path, paintGlow);
      // Draw core line
      canvas.drawPath(path, paintLine);

      // Draw area fill gradient
      final fillGradient = LinearGradient(
        colors: [neonColor.withOpacity(0.2), neonColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = fillGradient.createShader(Rect.fromLTRB(0, 0, width, height));
      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Unified spring/scale touch animation wrapper for premium feedback
class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleOnPress({super.key, required this.child, required this.onTap});

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnzorActionButton
// Premium reusable action button with consistent interaction across all
// button instances in the Anzor design system.
//
// Behavior:
//   • 98% scale-down on press (180ms ease-out)
//   • Soft orange glow while pressed
//   • HapticFeedback.lightImpact() on every tap
//   • M3 InkSparkle/InkRipple overlay in primary variant
//   • Two visual variants: primary (orange gradient) and ghost
// ─────────────────────────────────────────────────────────────────────────────

enum AnzorActionButtonVariant { primary, ghost }

class AnzorActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final AnzorActionButtonVariant variant;

  /// Override the accent color (defaults to brandOrange).
  final Color? accentColor;

  /// Show loading progress spinner
  final bool isLoading;

  /// Optional custom width
  final double? width;

  /// Optional custom height
  final double? height;

  const AnzorActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.variant = AnzorActionButtonVariant.ghost,
    this.accentColor,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<AnzorActionButton> createState() => _AnzorActionButtonState();
}

class _AnzorActionButtonState extends State<AnzorActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glowOpacity;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 220),
      value: 1.0, // starts at rest
    );

    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    _controller.reverse(); // scale down → 0.98
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.forward(); // scale back → 1.0
  }

  void _onTapCancel() {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.forward();
  }

  void _onTap() {
    if (widget.onTap == null || widget.isLoading) return;
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppTheme.brandOrange;
    final isPrimary = widget.variant == AnzorActionButtonVariant.primary;
    final isDisabled = widget.onTap == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: isPrimary && !isDisabled
                    ? AppTheme.brandGradient
                    : null,
                color: isPrimary
                    ? null
                    : _isPressed
                        ? accent.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isPrimary
                      ? Colors.transparent
                      : _isPressed
                          ? accent.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.09),
                  width: 0.9,
                ),
                boxShadow: [
                  // Orange glow on press
                  BoxShadow(
                    color: accent.withValues(
                        alpha: isPrimary
                            ? (0.38 - _glowOpacity.value * 0.15)
                            : _glowOpacity.value * 0.6),
                    blurRadius: isPrimary ? 14 : 10,
                    spreadRadius: isPrimary ? 0 : -1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  splashFactory: Theme.of(context).splashFactory,
                  borderRadius: BorderRadius.circular(11),
                  splashColor: accent.withValues(alpha: 0.2),
                  highlightColor: accent.withValues(alpha: 0.08),
                  onTap: null, // handled by GestureDetector above
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.label.isEmpty ? 10 : 13, vertical: 9),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isPrimary ? Colors.white : accent,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.icon,
                                  size: 14,
                                  color: isDisabled
                                      ? Colors.white38
                                      : isPrimary
                                          ? Colors.white
                                          : _isPressed
                                              ? accent
                                              : Colors.white.withValues(alpha: 0.65),
                                ),
                                if (widget.label.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDisabled
                                          ? Colors.white38
                                          : isPrimary
                                              ? Colors.white
                                              : _isPressed
                                                  ? accent
                                                  : Colors.white.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnzorCard
// ─────────────────────────────────────────────────────────────────────────────
class AnzorCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final bool addGlow;
  final Color glowColor;
  final List<Color>? backgroundGradientColors;

  const AnzorCard({
    super.key,
    required this.child,
    this.radius = 22.0, // 20-24px per spec sheet
    this.borderColor = const Color(0x10FFFFFF),
    this.padding = const EdgeInsets.all(16.0),
    this.addGlow = false,
    this.glowColor = AppTheme.brandOrange,
    this.backgroundGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: radius,
      borderColor: borderColor,
      padding: padding,
      addGlow: addGlow,
      glowColor: glowColor,
      backgroundGradientColors: backgroundGradientColors,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnzorButton
// ─────────────────────────────────────────────────────────────────────────────
class AnzorButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final LinearGradient gradient;
  final Color glowColor;
  final double radius;
  final double height;
  final bool isLoading;

  const AnzorButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = AppTheme.brandGradient,
    this.glowColor = AppTheme.brandOrange,
    this.radius = 16.0, // 16px per spec sheet
    this.height = 52.0,
    this.isLoading = false,
  });

  @override
  State<AnzorButton> createState() => _AnzorButtonState();
}

class _AnzorButtonState extends State<AnzorButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (widget.onPressed == null || widget.isLoading) return;
              setState(() => _isPressed = true);
              _controller.reverse();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              if (widget.onPressed == null || widget.isLoading) return;
              setState(() => _isPressed = false);
              _controller.forward();
            },
            onTapCancel: () {
              if (widget.onPressed == null || widget.isLoading) return;
              setState(() => _isPressed = false);
              _controller.forward();
            },
            onTap: (widget.onPressed == null || widget.isLoading) ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.onPressed == null ? null : widget.gradient,
                color: widget.onPressed == null ? const Color(0xFF2A3048) : null,
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: [
                  if (widget.onPressed != null)
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: _isPressed ? 0.35 : 0.15),
                      blurRadius: _isPressed ? 20 : 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnzorChip
// ─────────────────────────────────────────────────────────────────────────────
class AnzorChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AnzorChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.brandGradient : null,
          color: isSelected ? null : const Color(0xFF131024),
          borderRadius: BorderRadius.circular(16), // 16px per spec sheet
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.brandOrange.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnzorInput
// ─────────────────────────────────────────────────────────────────────────────
class AnzorInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  const AnzorInput({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  State<AnzorInput> createState() => _AnzorInputState();
}

class _AnzorInputState extends State<AnzorInput> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        borderRadius: BorderRadius.circular(20), // 20px per spec sheet
        border: Border.all(
          color: _isFocused
              ? AppTheme.brandOrange.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.08),
          width: _isFocused ? 1.2 : 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppTheme.brandOrange.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: _isFocused ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        validator: widget.validator,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFFF0F4FF),
        ),
        cursorColor: AppTheme.brandOrange,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.22),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: _isFocused ? AppTheme.brandOrange : Colors.white38, size: 18)
              : null,
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

