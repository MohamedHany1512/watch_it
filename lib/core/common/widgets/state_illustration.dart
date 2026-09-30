import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';

/// Which illustration to draw.
enum StateIllustration { emptySearch, offline, error }

/// Animated vector illustration used by the polished state screens.
///
/// A [CustomPainter] rather than an icon font, so it can use the brand
/// gradient and glow that stock Material icons cannot.
class StateIllustrationView extends StatefulWidget {
  const StateIllustrationView({
    super.key,
    required this.illustration,
    this.size = 168,
  });

  final StateIllustration illustration;
  final double size;

  @override
  State<StateIllustrationView> createState() => _StateIllustrationViewState();
}

class _StateIllustrationViewState extends State<StateIllustrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = MediaQuery.disableAnimationsOf(context)
              ? 0.5
              : _controller.value;
          return CustomPaint(
            painter: _StateIllustrationPainter(
              illustration: widget.illustration,
              phase: t,
            ),
          );
        },
      ),
    );
  }
}

class _StateIllustrationPainter extends CustomPainter {
  _StateIllustrationPainter({required this.illustration, required this.phase});

  final StateIllustration illustration;

  /// `0..1`, drives the float / rotate / pulse motion.
  final double phase;

  static const double _tau = math.pi * 2;

  Color get _accent => switch (illustration) {
    StateIllustration.emptySearch => AppColors.primaryLight,
    StateIllustration.offline => AppColors.warning,
    StateIllustration.error => AppColors.error,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double r = size.shortestSide / 2;

    _paintGlow(canvas, center, r);

    switch (illustration) {
      case StateIllustration.emptySearch:
        _paintSearch(canvas, center, r);
      case StateIllustration.offline:
        _paintOffline(canvas, center, r);
      case StateIllustration.error:
        _paintError(canvas, center, r);
    }
  }

  @override
  bool shouldRepaint(_StateIllustrationPainter oldDelegate) {
    return oldDelegate.illustration != illustration ||
        oldDelegate.phase != phase;
  }

  /// Soft radial halo behind the glyph.
  void _paintGlow(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            _accent.withValues(alpha: 0.22),
            _accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  /// A magnifier with a travelling highlight arc.
  void _paintSearch(Canvas canvas, Offset center, double r) {
    final Offset c = center.translate(0, math.sin(phase * _tau) * r * 0.03);
    final double radius = r * 0.42;

    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );

    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.075
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primaryLight, AppColors.accent],
        ).createShader(Rect.fromCircle(center: c, radius: radius * 1.4)),
    );

    canvas.drawLine(
      c + Offset(radius * 0.7, radius * 0.7),
      c + Offset(radius * 1.42, radius * 1.42),
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.085
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius * 0.62),
      phase * _tau,
      math.pi * 0.55,
      false,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );
  }

  /// A "broken wifi" symbol: three arcs, a pulsing dot and a slash.
  void _paintOffline(Canvas canvas, Offset center, double r) {
    final Offset c = center.translate(
      0,
      math.sin(phase * _tau) * r * 0.025 - r * 0.05,
    );

    for (int i = 0; i < 3; i++) {
      final double radius = r * (0.30 + i * 0.17);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        math.pi * 1.22,
        math.pi * 0.56,
        false,
        Paint()
          ..color = AppColors.warning.withValues(alpha: 0.9 - i * 0.26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.075
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      c.translate(0, r * 0.30),
      r * 0.075 * (0.85 + math.sin(phase * _tau) * 0.15),
      Paint()..color = AppColors.warning,
    );

    final double len = r * 0.72;
    canvas.drawLine(
      c + Offset(-len, len),
      c + Offset(len, -len),
      Paint()
        ..color = AppColors.error
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..strokeCap = StrokeCap.round,
    );
  }

  /// A rounded "alert" badge with a breathing exclamation mark.
  void _paintError(Canvas canvas, Offset center, double r) {
    final double pulse = 1 + (math.sin(phase * _tau) * 0.035);
    final Rect rect = Rect.fromCenter(
      center: center,
      width: r * 1.18 * pulse,
      height: r * 1.18 * pulse,
    );
    final RRect rounded = RRect.fromRectAndRadius(
      rect,
      Radius.circular(r * 0.36),
    );

    canvas.drawRRect(
      rounded,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.error.withValues(alpha: 0.85),
            AppColors.accentWarm.withValues(alpha: 0.7),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      rounded,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..color = AppColors.white.withValues(alpha: 0.22),
    );

    final Paint mark = Paint()
      ..color = AppColors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.09;

    canvas.drawLine(
      center.translate(0, -r * 0.20),
      center.translate(0, r * 0.10),
      mark,
    );
    canvas.drawCircle(center.translate(0, r * 0.30), r * 0.055, mark);
  }
}
