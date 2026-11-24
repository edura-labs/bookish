import 'package:bookish/ui/common/app_platform.dart';
import 'package:bookish/ui/common/app_typography.dart';
import 'package:flutter/material.dart';

/// A calm, centred message for screens with nothing to show yet. It should
/// invite the next action, not just say "nothing here".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String title;
  final String message;

  /// Optional button, usually an [AdaptiveButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final type = AppTypography.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppPlatform.current.isIos ? cupertinoIcon : materialIcon,
            size: 48,
            color: muted,
          ),
          const SizedBox(height: 16),
          Text(title, style: type.title3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: type.subheadline.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
