import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The circular battery indicator on the home screen.
///
/// Animates between levels rather than snapping, so a battery broadcast during
/// charging reads as movement instead of a flicker.
class BatteryGauge extends StatelessWidget {
  const BatteryGauge({
    super.key,
    required this.level,
    required this.color,
    required this.statusLabel,
    this.charging = false,
    this.size = 220,
  });

  final int level;
  final Color color;
  final String statusLabel;
  final bool charging;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: (level / 100).clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _GaugePainter(
              progress: value,
              color: color,
              trackColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: child,
          );
        },
        // The gauge is a fixed-size circle, so its contents cannot grow without
        // bound. Clamping keeps it readable at large system font sizes instead of
        // overflowing, while still honouring smaller increases.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (charging)
                Icon(Icons.bolt_rounded, color: color, size: 28)
              else
                const SizedBox(height: 28),
              Text(
                '$level%',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  statusLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  /// Leaves a gap at the bottom so the arc reads as a gauge, not a full ring.
  static const _startAngle = math.pi * 0.75;
  static const _sweepAngle = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: [color.withValues(alpha: 0.55), color],
        transform: GradientRotation(_startAngle),
      ).createShader(rect);

    canvas.drawArc(rect, _startAngle, _sweepAngle, false, track);
    if (progress > 0) {
      canvas.drawArc(rect, _startAngle, _sweepAngle * progress, false, fill);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
