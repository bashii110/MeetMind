import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meetmind_ai/core/theme/glass_token.dart';



/// A frosted-glass surface: blurs whatever is painted behind it, then
/// lays a translucent tint, a soft 1px light border, and a gentle shadow
/// on top. This is the building block every "glass card" in the app
/// should be made from (see `MeetingCard`, `TaskCard`, `EmptyState`,
/// `DashboardScreen`'s stat cards) so blur strength, border, and radius
/// stay consistent across screens instead of every screen hand-rolling
/// its own `BackdropFilter`.
///
/// Needs something to actually blur — the app mounts `GlassBackground`
/// once, behind the whole routed app, in `main.dart`, so every glass
/// surface has a gradient/blob backdrop to refract regardless of which
/// screen it's on.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.blur = GlassTokens.blurLight,
    this.tint,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  /// BackdropFilter blur sigma. Defaults to `GlassTokens.blurLight`; pass
  /// `GlassTokens.blurStrong` for surfaces that sit over busier content
  /// (e.g. a sticky header over a scrolling list).
  final double blur;

  /// Overrides the tint color used for the fill gradient. Defaults to
  /// `Theme.of(context).colorScheme.surface` — pass
  /// `Theme.of(context).colorScheme.tertiary` (or similar) for a glass
  /// surface that should also carry the AI-accent signal (DESIGN.md 2.1).
  final Color? tint;

  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = borderRadius ?? BorderRadius.circular(GlassTokens.radiusMd);
    final fill = tint ?? Theme.of(context).colorScheme.surface;
    final fillOpacity = GlassTokens.fillOpacity(brightness);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                fill.withValues(alpha: fillOpacity + 0.08),
                fill.withValues(alpha: fillOpacity),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: GlassTokens.borderOpacity(brightness)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: brightness == Brightness.light ? 0.06 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap == null) return content;

    // GestureDetector rather than InkWell: an ink splash is barely
    // visible (and looks wrong) painted on top of a blurred, translucent
    // surface, so this keeps the tap target without that artifact.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}