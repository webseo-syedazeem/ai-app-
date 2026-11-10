import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Central motion settings for AI Daily Helper.
/// Respects OS Reduce Motion and allows tests to verify settled states cleanly.
class AppMotion {
  AppMotion._();

  static bool enableAmbientLoops = true;

  static bool shouldLoop(BuildContext context) {
    if (!enableAmbientLoops) return false;
    return !MediaQuery.disableAnimationsOf(context);
  }
}

/// Finite staggered fade + slide entrance animation (60fps, zero controller overhead).
class StaggeredReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final Offset offset;

  const StaggeredReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 380),
    this.offset = const Offset(0, 14),
  });

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delayMs = (widget.baseDelay.inMilliseconds * widget.index).clamp(0, 420);
    if (delayMs == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _visible = true);
      });
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _visible ? 1.0 : 0.0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * (1.0 - t),
              widget.offset.dy * (1.0 - t),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Tactile press-down spring micro-interaction for cards, buttons, and chips.
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final HitTestBehavior behavior;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.965,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: Duration(milliseconds: _pressed ? 90 : 170),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Gentle continuous levitation loop for hero illustrations & floating badges.
class FloatingBob extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  final double phaseOffset;

  const FloatingBob({
    super.key,
    required this.child,
    this.amplitude = 5.0,
    this.duration = const Duration(milliseconds: 2800),
    this.phaseOffset = 0.0,
  });

  @override
  State<FloatingBob> createState() => _FloatingBobState();
}

class _FloatingBobState extends State<FloatingBob> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    if (AppMotion.enableAmbientLoops) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppMotion.shouldLoop(context)) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final dy = math.sin(_ctrl.value * math.pi * 2 + widget.phaseOffset) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

/// Smoothly pulsing radial halo for live voice capture and splash brand mark.
class AmbientPulseHalo extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxScale;
  final Duration duration;

  const AmbientPulseHalo({
    super.key,
    required this.child,
    this.color = const Color(0x336973FF),
    this.maxScale = 1.28,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<AmbientPulseHalo> createState() => _AmbientPulseHaloState();
}

class _AmbientPulseHaloState extends State<AmbientPulseHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    if (AppMotion.enableAmbientLoops) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppMotion.shouldLoop(context)) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final scale = 1.0 + (widget.maxScale - 1.0) * t;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: (1 - t) * 0.35),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
