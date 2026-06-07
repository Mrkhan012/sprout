import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// A Scaffold whose body sits on Sprout's signature deep-navy hero gradient
/// (or a custom [gradient]), with floating decorative "blobs" echoing the deck.
///
/// Reused by the splash and every dark activity screen so they share one
/// backdrop. Content is centred and width-capped on large screens.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.gradient = AppColors.heroGradient,
    this.blobs = true,
    this.safeArea = true,
    this.padding,
  });

  final Widget child;
  final Gradient gradient;
  final bool blobs;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final r = context.r;

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (r.maxContentWidth != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: content,
        ),
      );
    }
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            if (blobs) ..._blobs(context),
            Positioned.fill(child: content),
          ],
        ),
      ),
    );
  }

  List<Widget> _blobs(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return [
      _Blob(
        diameter: size.width * 0.7,
        color: AppColors.indigo.withValues(alpha: 0.30),
        left: -size.width * 0.25,
        top: -size.width * 0.2,
      ),
      _Blob(
        diameter: size.width * 0.55,
        color: AppColors.coral.withValues(alpha: 0.18),
        right: -size.width * 0.2,
        bottom: size.height * 0.05,
      ),
      _Blob(
        diameter: size.width * 0.4,
        color: AppColors.teal.withValues(alpha: 0.16),
        right: size.width * 0.1,
        top: size.height * 0.12,
      ),
    ];
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.diameter,
    required this.color,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final double diameter;
  final Color color;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
