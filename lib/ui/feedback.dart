import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Indeterminate loading indicator: three Plum dots pulsing in turn.
class B4Spinner extends StatefulWidget {
  const B4Spinner({this.size = 28, this.color, super.key});

  /// Width of the row of dots.
  final double size;
  final Color? color;

  @override
  State<B4Spinner> createState() => _B4SpinnerState();
}

class _B4SpinnerState extends State<B4Spinner>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.palette.primary;
    return Semantics(
      label: '…',
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _DotsPainter(animation: _controller, color: color),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / 3;
    final maxRadius = slot * 0.36;
    for (var i = 0; i < 3; i++) {
      // Each dot peaks a third of a cycle after the previous one.
      final phase = (animation.value - i / 3) % 1;
      final pulse = (math.sin(phase * math.pi * 2) + 1) / 2;
      canvas.drawCircle(
        Offset(slot * (i + 0.5), size.height / 2),
        maxRadius * (0.55 + 0.45 * pulse),
        Paint()..color = color.withValues(alpha: 0.35 + 0.65 * pulse),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

/// Centred spinner for a whole screen that is still loading.
class B4LoadingView extends StatelessWidget {
  const B4LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: B4Spinner());
}

/// Determinate ring, e.g. the share of this month's bills already paid.
class B4ProgressRing extends StatelessWidget {
  const B4ProgressRing({
    required this.value,
    required this.color,
    required this.trackColor,
    this.size = 84,
    this.strokeWidth = 9,
    this.child,
    super.key,
  });

  /// 0 to 1.
  final double value;
  final Color color;
  final Color trackColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => CustomPaint(
          painter: _ArcPainter(
            color: color,
            track: trackColor,
            strokeWidth: strokeWidth,
            sweep: v,
          ),
          child: child,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.color,
    required this.track,
    required this.strokeWidth,
    required this.sweep,
  });

  final Color color;
  final Color track;
  final double strokeWidth;

  /// Fraction of the full circle.
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * sweep,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.sweep != sweep ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
