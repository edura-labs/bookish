import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

enum AdaptiveButtonStyle {
  /// The one key action on a screen (e.g. "Add to Shelf").
  primary,

  /// Supporting actions.
  secondary,
}

/// A text button, rendered natively per platform:
///
/// * iOS 26+: a Liquid Glass pill (`GlassButton`), walnut-tinted for primary,
///   clear glass for secondary.
/// * iOS below 26: `CupertinoButton`, filled (primary) or tinted (secondary).
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

  static const _glassHeight = 50.0;

  bool get _primary => style == AdaptiveButtonStyle.primary;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.usesGlass(context)) return _buildGlass(context);

    final button = AppPlatform.current.isIos
        ? _buildCupertino(context)
        : _buildMaterial();
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildGlass(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = _primary ? scheme.onPrimary : scheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) => GlassButton.custom(
        onTap: onPressed ?? () {},
        enabled: onPressed != null,
        label: label,
        width: expand ? constraints.maxWidth : null,
        height: _glassHeight,
        shape: const LiquidRoundedSuperellipse(borderRadius: _glassHeight / 2),
        style: _primary ? GlassButtonStyle.prominent : GlassButtonStyle.filled,
        // Primary is tinted with the scheme's fill tone, which is dark enough
        // for white text in both light and dark mode.
        settings: _primary
            ? LiquidGlassSettings(
                glassColor: scheme.primary.withValues(alpha: 0.85),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Fill colours come from the Material scheme, whose dark-mode fills are
    // dark enough for white text (the Cupertino primary is the lighter text
    // tint and is not).
    return CupertinoButton(
      color: _primary ? scheme.primary : scheme.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      minimumSize: const Size(44, 50),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: _primary
              ? scheme.onPrimary
              : CupertinoTheme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildMaterial() {
    final child = Text(label);
    return _primary
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}
