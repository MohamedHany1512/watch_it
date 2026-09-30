import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';

/// Paints the ambient "glow" layer behind the whole app.
///
/// Three large, heavily blurred radial blobs over the deep background. This is
/// what makes the dark theme feel alive instead of flat, and it costs a single
/// painted layer rather than a stack of decorated containers.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.child});

  /// Content painted on top of the glow.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF14142B),
            AppColors.background,
            Color(0xFF0B0B18),
          ],
          stops: <double>[0, 0.55, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _GlowOrb(
            color: AppColors.glowPrimary,
            alignment: Alignment(-0.85, -0.95),
            size: 320,
            opacity: 0.5,
          ),
          const _GlowOrb(
            color: AppColors.glowAccent,
            alignment: Alignment(1.0, -0.55),
            size: 280,
            opacity: 0.28,
          ),
          const _GlowOrb(
            color: AppColors.glowWarm,
            alignment: Alignment(0.6, 0.85),
            size: 300,
            opacity: 0.2,
          ),
          ?child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.alignment,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final Alignment alignment;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A frosted "glass" surface: real [ImageFilter.blur], a translucent fill and
/// a luminous hairline border.
///
/// Use this for floating bars, sheets and overlays - not for every card, since
/// a blur is comparatively expensive.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.blur = 24,
    this.borderRadius = AppColors.pillRadius,
    this.fill = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
    this.padding = EdgeInsets.zero,
    this.gradient,
  });

  final Widget child;
  final double blur;
  final double borderRadius;
  final Color fill;
  final Color borderColor;
  final EdgeInsets padding;

  /// Optional gradient layered on top of [fill] (used for accent bars).
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
