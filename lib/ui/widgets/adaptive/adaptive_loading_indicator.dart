import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Indeterminate progress: `CupertinoActivityIndicator` on iOS,
/// `CircularProgressIndicator` on Android.
class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({super.key, this.semanticLabel = 'Loading'});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Colours from the app theme in light and dark mode.
    final indicator = AppPlatform.current.isIos
        ? CupertinoActivityIndicator(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )
        : const CircularProgressIndicator();
    return Semantics(label: semanticLabel, child: indicator);
  }
}
