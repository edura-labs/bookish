import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An icon-only button for bars and toolbars.
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
    if (!AppPlatform.current.isIos) {
      return IconButton(
        icon: Icon(materialIcon),
        tooltip: label,
        onPressed: onPressed,
      );
    }

    // 44 x 44 pt: Apple's default minimum touch target.
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(44),
      onPressed: onPressed,
      child: Icon(cupertinoIcon, semanticLabel: label),
    );
  }
}
