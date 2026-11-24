// lib/ui/common/app_theme.dart
//
// Bookish: Reading Tracker. Theme: warm "paper, ink and walnut" look.
// Android: serif headings (Fraunces) for a bookish feel, Inter for body text.
// iOS: San Francisco throughout, per Apple's guidelines; Fraunces only for
// in-content display text via AppTypography.bookTitle.
// Light and dark themes share one builder so they never drift apart.
//
// Text contrast rule: dark text on light backgrounds; white/light text on
// dark backgrounds and everywhere in dark mode. Any coloured fill that
// carries text (buttons, chips, banners) must be dark enough for white text.
// In dark mode, accent-coloured TEXT on the dark background uses the lighter
// *Text tones below, never the fill tones.

import 'package:bookish/ui/common/app_platform.dart';
import 'package:bookish/ui/common/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Light
  static const paper = Color(0xFFF7F3EC); // scaffold background
  static const surface = Color(0xFFFFFDF9); // cards, inputs, nav bar
  static const ink = Color(0xFF1F1B16); // primary text
  static const inkMuted = Color(0xFF6B6259); // secondary text
  static const accent = Color(0xFF6B4226); // walnut brown: actions, progress
  static const forest = Color(0xFF2F5D50); // "Finished" status, success
  static const divider = Color(0xFFE6DFD3);

  // Dark
  static const night = Color(0xFF15130F);
  static const nightSurface = Color(0xFF1F1C17);
  static const parchment = Color(0xFFEDE6DA);
  static const parchmentMuted = Color(0xFFA89F93);
  static const accentDark = Color(0xFF9A6840); // walnut fill, white text
  static const accentDarkText = Color(0xFFC49A6C); // oak text on night
  static const forestDark = Color(0xFF447F6D); // forest fill, white text
  static const forestDarkText = Color(0xFF7FB5A3); // forest text on night
  static const dividerDark = Color(0xFF2E2A23);

  static const error = Color(0xFFB3261E);
  static const errorDark = Color(0xFFD2453A); // error fill, white text
  static const errorDarkText = Color(0xFFF2B8B5); // error text on night
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        isIos: AppPlatform.current.isIos,
        scaffold: AppColors.paper,
        accentText: AppColors.accent,
        errorText: AppColors.error,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          secondary: AppColors.forest,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.inkMuted,
          outlineVariant: AppColors.divider,
        ),
      );

  static ThemeData get dark => _build(
        isIos: AppPlatform.current.isIos,
        scaffold: AppColors.night,
        accentText: AppColors.accentDarkText,
        errorText: AppColors.errorDarkText,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.accentDark,
          onPrimary: Colors.white,
          secondary: AppColors.forestDark,
          onSecondary: Colors.white,
          error: AppColors.errorDark,
          onError: Colors.white,
          surface: AppColors.nightSurface,
          onSurface: AppColors.parchment,
          onSurfaceVariant: AppColors.parchmentMuted,
          outlineVariant: AppColors.dividerDark,
        ),
      );

  static ThemeData _build({
    required bool isIos,
    required ColorScheme scheme,
    required Color scaffold,
    required Color accentText,
    required Color errorText,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );

    final textTheme = (isIos ? base.textTheme : _androidTextTheme(base))
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final radius14 = BorderRadius.circular(14);
    final hairline = BorderSide(color: scheme.outlineVariant);

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      extensions: [
        isIos
            ? AppTypography.apple(scheme.onSurface)
            : AppTypography.material(textTheme, scheme.onSurface),
      ],
      // Cupertino widgets read this. primaryColor is the tint for text and
      // icons (walnut on paper, oak on night); fills come from the scheme.
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: scheme.brightness,
        primaryColor: accentText,
        // Cupertino text defaults to Apple's system label colours; use the
        // app's ink (light) / parchment (dark) instead, keeping SF sizes.
        textTheme: _cupertinoTextTheme(accentText, scheme.onSurface),
        primaryContrastingColor: scheme.brightness == Brightness.light
            ? Colors.white
            : AppColors.night,
        scaffoldBackgroundColor: scaffold,
        barBackgroundColor: scaffold.withValues(alpha: 0.92),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hairline,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: errorText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:
            OutlineInputBorder(borderRadius: radius14, borderSide: hairline),
        enabledBorder:
            OutlineInputBorder(borderRadius: radius14, borderSide: hairline),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius14,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: radius14),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: accentText,
          side: hairline,
          shape: RoundedRectangleBorder(borderRadius: radius14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        labelStyle: textTheme.labelMedium,
        side: hairline,
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static CupertinoTextThemeData _cupertinoTextTheme(Color tint, Color text) {
    final base = CupertinoTextThemeData(primaryColor: tint);
    return base.copyWith(
      textStyle: base.textStyle.copyWith(color: text),
      navTitleTextStyle: base.navTitleTextStyle.copyWith(color: text),
      navLargeTitleTextStyle: base.navLargeTitleTextStyle.copyWith(color: text),
    );
  }

  // Inter body, Fraunces for the larger headings (Android only).
  static TextTheme _androidTextTheme(ThemeData base) {
    final body = GoogleFonts.interTextTheme(base.textTheme);
    TextStyle? serif(TextStyle? s) =>
        GoogleFonts.fraunces(textStyle: s, fontWeight: FontWeight.w600);
    return body.copyWith(
      displaySmall: serif(body.displaySmall),
      headlineMedium: serif(body.headlineMedium),
      headlineSmall: serif(body.headlineSmall),
      titleLarge: serif(body.titleLarge),
    );
  }
}
