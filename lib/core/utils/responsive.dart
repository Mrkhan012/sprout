import 'package:flutter/widgets.dart';

/// Lightweight responsiveness helper.
///
/// Sprout runs on phones, tablets and (for review) the web/desktop. Rather than
/// pull in a heavy package we expose a small, dependency-free API that scales
/// spacing and font sizes against a 390pt baseline phone and exposes simple
/// form-factor breakpoints so layouts can re-flow (e.g. 2 vs 3 vs 4 columns).
class Responsive {
  Responsive(this.context) : _size = MediaQuery.sizeOf(context);

  final BuildContext context;
  final Size _size;

  static const double _baselineWidth = 390; // iPhone 13/14 logical width
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1000;

  double get width => _size.width;
  double get height => _size.height;

  bool get isPhone => width < tabletBreakpoint;
  bool get isTablet => width >= tabletBreakpoint && width < desktopBreakpoint;
  bool get isDesktop => width >= desktopBreakpoint;

  /// Clamped scale factor so big screens grow gently, not unboundedly.
  double get _scale => (width / _baselineWidth).clamp(0.85, 1.5);

  /// Scaled size for spacing / dimensions.
  double scale(double value) => value * _scale;

  /// Scaled font size, clamped a touch tighter to keep text comfortable.
  double font(double value) => value * (width / _baselineWidth).clamp(0.9, 1.3);

  /// Columns for the home activity grid, by form factor.
  int get gridColumns {
    if (isDesktop) return 3;
    if (isTablet) return 2;
    return width < 360 ? 1 : 2;
  }

  /// A max content width so the UI stays centered & readable on wide screens.
  double get maxContentWidth => isDesktop ? 920 : double.infinity;

  static Responsive of(BuildContext context) => Responsive(context);
}

/// Sugar so widgets can do `context.r.scale(16)`.
extension ResponsiveX on BuildContext {
  Responsive get r => Responsive(this);
}
