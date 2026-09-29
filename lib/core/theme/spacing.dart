/// Consistent spacing scale — DESIGN.md section 6.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Corner radius used consistently across cards — DESIGN.md 2.3.
  /// Bumped from 14 to 20 for the glassmorphism theme (matches
  /// `GlassTokens.radiusMd`), so every card across the app — whether it
  /// was rebuilt on `GlassContainer` or is still a plain `Card` picking
  /// up the theme's translucent `CardThemeData` — shares the same,
  /// slightly softer roundedness instead of two different radii.
  static const double cardRadius = 20;
}