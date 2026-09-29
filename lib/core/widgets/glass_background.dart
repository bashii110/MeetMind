import 'dart:ui';

import 'package:flutter/material.dart';

/// The app's ambient backdrop for its glassmorphism theme: a soft base
/// gradient plus a few large, heavily blurred color blobs. Every glass
/// surface (`GlassContainer`, `GlassAppBar`, and — via the theme's
/// translucent `CardTheme` — every plain `Card` too) blurs *this* rather
/// than flat white/black, which is what makes the frosted effect read as
/// glass instead of just "translucent grey."
///
/// Mounted once, in `main.dart`'s `MaterialApp.router` `builder`, so it
/// sits behind every screen (and every dialog/bottom sheet, since those
/// render into the same routed subtree) without each screen needing to
/// add it itself.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0A0C18), Color(0xFF141832), Color(0xFF0A0C18)]
                  : const [Color(0xFFF4F5FF), Color(0xFFEFF8FF), Color(0xFFFAF4FF)],
            ),
          ),
        ),
        // Purely decorative — ignored for hit testing so it never steals
        // taps meant for the real content painted on top of it.
        IgnorePointer(
          child: Stack(
            children: [
              _Blob(top: -90, left: -70, color: scheme.primary.withValues(alpha: isDark ? 0.35 : 0.30)),
              _Blob(top: 140, right: -110, color: scheme.tertiary.withValues(alpha: isDark ? 0.28 : 0.22)),
              _Blob(bottom: -130, left: 30, color: scheme.secondary.withValues(alpha: isDark ? 0.24 : 0.18)),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({this.top, this.left, this.right, this.bottom, required this.color});

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
