import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetmind_ai/core/theme/glass_token.dart';


/// Centralized ThemeData per DESIGN.md section 6 — rebuilt around a
/// glassmorphism visual language.
///
/// Every themed surface (cards, app bars, chips, inputs, buttons,
/// dialogs, sheets, list tiles, dividers) now uses a translucent fill
/// plus a soft light border instead of a flat opaque color, so it reads
/// as "glass" sitting on top of the app's ambient background — see
/// `core/widgets/glass_background.dart`, mounted once for the whole app
/// in `main.dart`. Because that cascades through `ThemeData`, every
/// screen that already builds a plain `Card`, `AppBar`, `Chip`,
/// `TextField`, dialog, or bottom sheet picks up the glass look for
/// free, with no per-screen changes required.
///
/// True frosted *blur* (`BackdropFilter`) can only be applied per-widget,
/// not through `ThemeData` alone, so this gives every themed surface the
/// tinted, bordered half of the look "for free," while screens that want
/// the fully blurred glass effect build on `GlassContainer` /
/// `GlassAppBar` (`core/widgets/`) instead of the stock `Card`/`AppBar` —
/// see `MeetingCard`, `TaskCard`, and `DashboardScreen` for worked
/// examples.
///
/// Design intent (DESIGN.md 1 & 2.1):
/// - A distinct **tertiary** color is still used specifically for
///   AI-generated surfaces (summary cards, assistant bubble) so users can
///   tell AI output from human-entered data at a glance — unchanged in
///   spirit from the previous theme, just re-tuned to a glass-friendly
///   teal so it still pops against translucent surfaces.
class AppTheme {
  AppTheme._();

  // Cool violet-blue seed — reads well as tinted glass in both themes.
  static const _seed = Color(0xFF5B5FEF);

  // Distinct hue for AI content, deliberately not derived from the seed
  // so it reads as a separate signal rather than a shade of the brand
  // color (DESIGN.md 2.1) — tuned to sit well against glass.
  static const _aiAccent = Color(0xFF14CFC0);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(
      tertiary: _aiAccent,
      tertiaryContainer: brightness == Brightness.light
          ? _aiAccent.withValues(alpha: 0.16)
          : _aiAccent.withValues(alpha: 0.22),
    );

    final textTheme = GoogleFonts.interTextTheme(
      brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    );

    final fillOpacity = GlassTokens.fillOpacity(brightness);
    final glassBorder = Colors.white.withValues(alpha: GlassTokens.borderOpacity(brightness));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      // Transparent so GlassBackground's gradient + blurred color blobs
      // (mounted once in main.dart) show through behind every screen —
      // the "glass sits on top of something" half of the effect. Every
      // glass surface's BackdropFilter blurs this.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: fillOpacity),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: brightness == Brightness.light ? 0.08 : 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusMd),
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface.withValues(alpha: fillOpacity),
        side: BorderSide(color: glassBorder),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: fillOpacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusSm),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusSm),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusSm),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GlassTokens.radiusSm)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: glassBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GlassTokens.radiusSm)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GlassTokens.radiusSm)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface.withValues(alpha: brightness == Brightness.light ? 0.88 : 0.80),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusLg),
          side: BorderSide(color: glassBorder),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface.withValues(alpha: brightness == Brightness.light ? 0.92 : 0.85),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(GlassTokens.radiusLg)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GlassTokens.radiusSm)),
      ),
      dividerTheme: DividerThemeData(color: glassBorder, space: 1),
    );
  }

  /// Use for anything that renders AI-generated content (summaries,
  /// extracted tasks, assistant replies) so it's visually distinct —
  /// DESIGN.md 2.1 and 3.6/3.9.
  static Color aiAccent(BuildContext context) => Theme.of(context).colorScheme.tertiary;
}