import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bouncy_tap.dart';
import '../../../../shared/widgets/star_burst.dart';
import '../../model/bubble.dart';

/// Renders one [Bubble]: it bobs gently while idle, and when popped it puffs up,
/// fades out and emits a star burst. The bob phase is derived from the bubble
/// id so the field doesn't pulse in unison.
class BubbleWidget extends StatefulWidget {
  const BubbleWidget({
    super.key,
    required this.bubble,
    required this.diameter,
    required this.onPop,
  });

  final Bubble bubble;
  final double diameter;
  final VoidCallback onPop;

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with TickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  bool _bursting = false;

  @override
  void didUpdateWidget(covariant BubbleWidget old) {
    super.didUpdateWidget(old);
    if (!old.bubble.popped && widget.bubble.popped) {
      setState(() => _bursting = true);
      _pop.forward();
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.bubble.id * 0.9;

    return AnimatedBuilder(
      animation: Listenable.merge([_bob, _pop]),
      builder: (context, child) {
        final bobY = math.sin(_bob.value * 2 * math.pi + phase) * 6;
        // Pop: scale up briefly then collapse; fade out.
        final pop = _pop.value;
        final scale = widget.bubble.popped
            ? (pop < 0.4 ? 1 + pop * 0.7 : 1.28 - (pop - 0.4) * 2.13)
            : 1.0;
        final opacity = widget.bubble.popped ? (1 - pop).clamp(0.0, 1.0) : 1.0;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.scale(
            scale: scale.clamp(0.0, 1.4),
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (_bursting)
            Positioned.fill(
              child: OverflowBox(
                maxWidth: widget.diameter * 2.4,
                maxHeight: widget.diameter * 2.4,
                child: StarBurst(
                  size: widget.diameter * 2.4,
                  seed: widget.bubble.id,
                  colors: [widget.bubble.color, AppColors.gold, AppColors.onDark],
                ),
              ),
            ),
          BouncyTap(
            onTap: widget.bubble.popped ? null : widget.onPop,
            child: _BubbleBody(
              diameter: widget.diameter,
              color: widget.bubble.color,
              emoji: widget.bubble.emoji,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({
    required this.diameter,
    required this.color,
    required this.emoji,
  });

  final double diameter;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            Color.lerp(color, Colors.white, 0.45)!,
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: diameter * 0.42)),
    );
  }
}
