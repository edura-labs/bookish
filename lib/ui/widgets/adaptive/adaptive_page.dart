import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A screen with a navigation bar and scrolling content, rendered natively
/// per platform:
///
/// * iOS: `CupertinoPageScaffold` with a `CupertinoNavigationBar`, or a
///   collapsing large title (`CupertinoSliverNavigationBar`) when
///   [largeTitle] is true, as Apple uses for top-level tab screens.
/// * Android: Material `Scaffold` with an `AppBar`.
///
/// Content is always a list of [slivers], so lists scroll under the bar the
/// way each platform expects. Back navigation comes from the platform bar.
class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    super.key,
    required this.title,
    required this.slivers,
    this.largeTitle = false,
    this.actions = const [],
  });

  final String title;
  final List<Widget> slivers;
  final bool largeTitle;

  /// Trailing bar actions, usually [AdaptiveIconButton]s. Keep to one or
  /// two; overflow belongs in a menu.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppPlatform.current.isIos
        ? _buildCupertino(context)
        : _buildMaterial(context);
  }

  Widget _buildCupertino(BuildContext context) {
    final trailing = actions.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: actions);
    final padding = MediaQuery.paddingOf(context);

    if (largeTitle) {
      return CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(title),
              trailing: trailing,
            ),
            ...slivers,
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      );
    }

    // The bar is translucent, so the scaffold reports its height as top
    // padding and content scrolls underneath it.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: trailing,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: padding.top)),
          ...slivers,
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
        ],
      ),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: CustomScrollView(
        slivers: [
          ...slivers,
          SliverToBoxAdapter(child: SizedBox(height: bottom)),
        ],
      ),
    );
  }
}
