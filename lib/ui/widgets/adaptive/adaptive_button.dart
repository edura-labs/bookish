import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AdaptiveButtonStyle {
  /// The one key action on a screen (e.g. "Add to Shelf").
  primary,

  /// Supporting actions.
  secondary,
}

/// A text button for content areas (not bars). Content stays solid on every
/// platform, so this never uses glass.
///
/// * iOS: `CupertinoButton`, filled (primary) or tinted (secondary).
/// * Android: Material 3 `FilledButton` or `OutlinedButton`.
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AdaptiveButtonStyle.primary,
    this.expand = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AdaptiveButtonStyle style;

  /// Fill the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = AppPlatform.current.isIos
        ? _buildCupertino(context)
        : _buildMaterial();
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildCupertino(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = style == AdaptiveButtonStyle.primary;

    // Fill colours come from the Material scheme, whose dark-mode fills are
    // dark enough for white text (the Cupertino primary is the lighter text
    // tint and is not).
    return CupertinoButton(
      color: primary ? scheme.primary : scheme.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      minimumSize: const Size(44, 50),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: primary ? scheme.onPrimary : CupertinoTheme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildMaterial() {
    final child = Text(label);
    return style == AdaptiveButtonStyle.primary
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}
