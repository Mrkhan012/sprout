import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps any child so it springs down on press and bounces back on release,
/// with a light haptic tick. This is the core "feels alive" interaction reused
/// by every tappable surface in the app (buttons, cards, bubbles).
class BouncyTap extends StatefulWidget {
  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
    this.haptics = true,
    this.sound = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptics;
  final bool sound;

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 220),
    lowerBound: 0,
    upperBound: 1,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: widget.pressedScale,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.elasticOut,
  ));

  bool get _interactive => widget.onTap != null;

  void _down(_) {
    if (!_interactive) return;
    _controller.forward();
  }

  void _up(_) {
    if (!_interactive) return;
    _controller.reverse();
  }

  void _cancel() {
    if (!_interactive) return;
    _controller.reverse();
  }

  void _tap() {
    if (!_interactive) return;
    if (widget.haptics) HapticFeedback.lightImpact();
    if (widget.sound) SystemSound.play(SystemSoundType.click);
    widget.onTap!();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      onTap: _tap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
