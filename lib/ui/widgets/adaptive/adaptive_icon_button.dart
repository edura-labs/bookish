import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// An icon-only button for bars and toolbars.
///
/// * iOS 26+: a Liquid Glass circle (`GlassIconButton`).
/// * iOS below 26: a plain `CupertinoButton`.
/// * Android: Material `IconButton`.
///
/// [label] is required: icon-only controls must have a text label for
/// screen readers (and it becomes the Android long-press tooltip).
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.label,
    required this.onPressed,
  });

  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.usesGlass(context)) {
      // 44 pt default size: Apple's minimum touch target.
      return GlassIconButton(
        onPressed: onPressed,
        semanticLabel: label,
        icon: Icon(
          cupertinoIcon,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    if (AppPlatform.current.isIos) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(44),
        onPressed: onPressed,
        child: Icon(cupertinoIcon, semanticLabel: label),
      );
    }

    return IconButton(
      icon: Icon(materialIcon),
      tooltip: label,
      onPressed: onPressed,
    );
  }
}
