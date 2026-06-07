import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A one-shot particle burst — little stars/dots that fly outward and fade.
/// Reused for bubble pops and reward celebrations. Plays once on mount and
/// calls [onComplete]. Deterministic (seeded) so it's test-friendly.
class StarBurst extends StatefulWidget {
  const StarBurst({
    super.key,
    this.colors = AppColors.playful,
    this.particleCount = 14,
    this.size = 160,
    this.seed = 0,
    this.onComplete,
  });

  final List<Color> colors;
  final int particleCount;
  final double size;
  final int seed;
  final VoidCallback? onComplete;

  @override
  State<StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<StarBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final List<_Particle> _particles = _build();

  List<_Particle> _build() {
    final rng = math.Random(widget.seed);
    return List.generate(widget.particleCount, (i) {
      final angle = (i / widget.particleCount) * 2 * math.pi +
          rng.nextDouble() * 0.6;
      final distance = widget.size * (0.3 + rng.nextDouble() * 0.5);
      return _Particle(
        angle: angle,
        distance: distance,
        color: widget.colors[i % widget.colors.length],
        radius: 3 + rng.nextDouble() * 5,
        spin: rng.nextDouble() * 2 * math.pi,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _BurstPainter(_particles, _controller.value),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.radius,
    required this.spin,
  });

  final double angle;
  final double distance;
  final Color color;
  final double radius;
  final double spin;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Ease-out travel, late fade.
    final eased = Curves.easeOut.transform(t);
    final opacity = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);

    for (final p in particles) {
      final d = p.distance * eased;
      final pos = center + Offset(math.cos(p.angle) * d, math.sin(p.angle) * d);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      _drawStar(canvas, pos, p.radius * (1.4 - eased * 0.4), p.spin, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, double rot, Paint paint) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final a = rot + (i * math.pi / points);
      final p = c + Offset(math.cos(a) * radius, math.sin(a) * radius);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}
