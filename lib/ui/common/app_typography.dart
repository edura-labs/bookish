import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic text roles, named after Apple's text styles. Views use these
/// (never raw font sizes), so one view reads correctly on both platforms:
///
/// * iOS: San Francisco at Apple's default text-style sizes. Dynamic Type
///   scales them through MediaQuery's text scaler.
/// * Android: the Material type scale with Inter body and Fraunces headings.
///
/// [bookTitle] is the one brand moment: Fraunces on both platforms. On iOS it
/// is only for in-content display text (e.g. the title on the book detail
/// screen), never in bars or controls.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.headline,
    required this.body,
    required this.callout,
    required this.subheadline,
    required this.footnote,
    required this.caption,
    required this.bookTitle,
  });

  final TextStyle largeTitle;
  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle headline;
  final TextStyle body;
  final TextStyle callout;
  final TextStyle subheadline;
  final TextStyle footnote;
  final TextStyle caption;
  final TextStyle bookTitle;

  /// Falls back to Material roles built from the current theme, so widgets
  /// still render in tests or previews that don't use [AppTheme]. The
  /// fallback avoids Google Fonts, which tests can't download.
  static AppTypography of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppTypography>() ??
        AppTypography.material(
          theme.textTheme,
          theme.colorScheme.onSurface,
          bookTitle: theme.textTheme.headlineMedium,
        );
  }

  /// Apple's default (Large) sizes, weights and tracking.
  factory AppTypography.apple(Color color) {
    TextStyle sf(double size, double tracking, [FontWeight? weight]) {
      return TextStyle(
        // Flutter maps these names to SF Pro Text / SF Pro Display.
        fontFamily: size >= 20 ? 'CupertinoSystemDisplay' : 'CupertinoSystemText',
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        letterSpacing: tracking,
        color: color,
      );
    }

    return AppTypography(
      largeTitle: sf(34, 0.37),
      title1: sf(28, 0.36),
      title2: sf(22, 0.35),
      title3: sf(20, 0.38),
      headline: sf(17, -0.43, FontWeight.w600),
      body: sf(17, -0.43),
      callout: sf(16, -0.32),
      subheadline: sf(15, -0.24),
      footnote: sf(13, -0.08),
      caption: sf(12, 0),
      bookTitle: _fraunces(color),
    );
  }

  /// Material roles from the app's Android text theme (Inter + Fraunces).
  factory AppTypography.material(
    TextTheme text,
    Color color, {
    TextStyle? bookTitle,
  }) {
    TextStyle role(TextStyle? style, [FontWeight? weight]) =>
        (style ?? const TextStyle()).copyWith(color: color, fontWeight: weight);

    return AppTypography(
      largeTitle: role(text.headlineMedium),
      title1: role(text.headlineSmall),
      title2: role(text.titleLarge),
      title3: role(text.titleMedium, FontWeight.w600),
      headline: role(text.titleMedium, FontWeight.w600),
      body: role(text.bodyLarge),
      callout: role(text.bodyMedium),
      subheadline: role(text.bodyMedium),
      footnote: role(text.bodySmall),
      caption: role(text.labelSmall),
      bookTitle: bookTitle == null ? _fraunces(color) : role(bookTitle),
    );
  }

  static TextStyle _fraunces(Color color) => GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: color,
      );

  @override
  AppTypography copyWith({
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption,
    TextStyle? bookTitle,
  }) {
    return AppTypography(
      largeTitle: largeTitle ?? this.largeTitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      headline: headline ?? this.headline,
      body: body ?? this.body,
      callout: callout ?? this.callout,
      subheadline: subheadline ?? this.subheadline,
      footnote: footnote ?? this.footnote,
      caption: caption ?? this.caption,
      bookTitle: bookTitle ?? this.bookTitle,
    );
  }

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      largeTitle: mix(largeTitle, other.largeTitle),
      title1: mix(title1, other.title1),
      title2: mix(title2, other.title2),
      title3: mix(title3, other.title3),
      headline: mix(headline, other.headline),
      body: mix(body, other.body),
      callout: mix(callout, other.callout),
      subheadline: mix(subheadline, other.subheadline),
      footnote: mix(footnote, other.footnote),
      caption: mix(caption, other.caption),
      bookTitle: mix(bookTitle, other.bookTitle),
    );
  }
}
