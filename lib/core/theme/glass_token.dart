import 'package:flutter/material.dart';

/// Shared design tokens for the app's glassmorphism visual language.
/// Centralizing these means every glass surface (AppBar, cards, chips,
/// sheets, dialogs) stays visually consistent instead of each screen
/// picking its own blur/opacity/radius values by hand.
class GlassTokens {
  GlassTokens._();

  // Blur strength for BackdropFilter surfaces.
  static const double blurLight = 12;
  static const double blurStrong = 24;

  // Corner radius used across glass surfaces.
  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 28;

  // Fill / border opacity, tuned separately for light and dark so the
  // effect reads correctly against both backgrounds — dark surfaces need
  // a much lower fill opacity or the "glass" just looks like flat grey.
  static double fillOpacity(Brightness b) => b == Brightness.light ? 0.55 : 0.14;

  static double borderOpacity(Brightness b) => b == Brightness.light ? 0.65 : 0.24;
}