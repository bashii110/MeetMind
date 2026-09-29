import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meetmind_ai/core/theme/glass_token.dart';



/// Drop-in replacement for [AppBar] that blurs the content scrolling
/// beneath it instead of painting a flat color — the toolbar half of the
/// app's glassmorphism theme. `core/theme/app_theme.dart` already makes
/// the stock `AppBar` transparent so it doesn't clash with the new
/// theme, but `ThemeData` alone can't add real blur to every `AppBar` in
/// the app; use this instead wherever a screen wants the fully frosted
/// toolbar (see `DashboardScreen` for a worked example).
///
/// Exposes the handful of `AppBar` parameters the app's screens actually
/// use; extend this if a screen needs one it doesn't expose yet.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.centerTitle = false,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: GlassTokens.blurStrong, sigmaY: GlassTokens.blurStrong),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: GlassTokens.fillOpacity(brightness)),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: GlassTokens.borderOpacity(brightness)),
              ),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            bottom: bottom,
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
