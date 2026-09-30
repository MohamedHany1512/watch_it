import 'package:flutter/material.dart';
import 'package:watch_it/core/themes/app_colors.dart';

/// A dependency-free animated shimmer, visually equivalent to the `shimmer`
/// package: a moving highlight sweeping across a muted base.
///
/// Implemented in-tree so the app keeps a minimal dependency list. It also
/// honours `MediaQuery.disableAnimations`, which the `shimmer` package does
/// not: users who ask the OS to reduce motion get a static placeholder.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.direction = Axis.horizontal,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final Axis direction;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = widget.baseColor ?? AppColors.surfaceMuted;
    final Color highlight = widget.highlightColor ?? AppColors.surfaceElevated;

    // Respect the OS "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      return ColoredBox(color: base, child: widget.child);
    }

    final bool horizontal = widget.direction == Axis.horizontal;
    // Sweep from -1..2 so the highlight fully enters and exits the box.
    final double t = (_controller.value * 3) - 1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: horizontal ? Alignment(t - 1, 0) : Alignment(0, t - 1),
              end: horizontal ? Alignment(t + 1, 0) : Alignment(0, t + 1),
              colors: <Color>[base, highlight, base],
              stops: const <double>[0.15, 0.5, 0.85],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single shimmering placeholder block.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Shimmer(
        child: SizedBox(
          width: width,
          height: height,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

