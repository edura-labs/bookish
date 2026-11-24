import 'package:bookish/ui/common/app_platform.dart';
import 'package:bookish/ui/common/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A screen with a navigation bar and scrolling content, rendered natively
/// per platform:
///
/// * iOS 26+: `GlassScaffold` + `GlassAppBar`. The bar is transparent and its
///   buttons are glass, as in iOS 26; the large title collapses into the bar
///   as you scroll (`GlassLargeTitle`).
/// * iOS below 26 (and iOS 26 with Increase Contrast): `CupertinoPageScaffold`
///   with a `CupertinoNavigationBar`, or `CupertinoSliverNavigationBar` for a
///   large title.
/// * Android: Material `Scaffold` with an `AppBar`.
///
/// Content is always a list of [slivers], so it scrolls under the bar the way
/// each platform expects, and stays solid: glass is only for bars and
/// controls.
class AdaptivePage extends StatefulWidget {
  const AdaptivePage({
    super.key,
    required this.title,
    required this.slivers,
    this.largeTitle = false,
    this.actions = const [],
  });

  final String title;
  final List<Widget> slivers;

  /// Apple uses large titles for top-level tab screens.
  final bool largeTitle;

  /// Trailing bar actions, usually [AdaptiveIconButton]s. Keep to one or
  /// two; overflow belongs in a menu.
  final List<Widget> actions;

  @override
  State<AdaptivePage> createState() => _AdaptivePageState();
}

class _AdaptivePageState extends State<AdaptivePage> {
  // Created lazily: only iOS 26 large-title pages need it.
  GlassLargeTitleController? _titleController;

  static const _glassBarHeight = 44.0;

  @override
  void dispose() {
    _titleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.usesGlass(context)) return _buildGlass(context);
    return AppPlatform.current.isIos
        ? _buildCupertino(context)
        : _buildMaterial(context);
  }

  Widget _buildGlass(BuildContext context) {
    final media = MediaQuery.of(context);
    final titleController = widget.largeTitle
        ? (_titleController ??= GlassLargeTitleController())
        : null;
    final topInset = media.padding.top + _glassBarHeight;

    return GlassScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      statusBarStyle: GlassStatusBarStyle.auto,
      // Fade content only while it is under the bar itself.
      topEdgeFadeExtent: 0,
      appBar: GlassAppBar(
        title: Text(widget.title, style: AppTypography.of(context).headline),
        actions: widget.actions.isEmpty ? null : widget.actions,
        largeTitleController: titleController,
      ),
      body: CustomScrollView(
        controller: titleController?.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topInset)),
          if (titleController != null)
            GlassLargeTitle(
              text: widget.title,
              controller: titleController,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ...widget.slivers,
          SliverToBoxAdapter(child: SizedBox(height: media.padding.bottom)),
        ],
      ),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final trailing = widget.actions.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: widget.actions);
    final padding = MediaQuery.paddingOf(context);

    if (widget.largeTitle) {
      return CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(widget.title),
              trailing: trailing,
            ),
            ...widget.slivers,
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      );
    }

    // The bar is translucent, so the scaffold reports its height as top
    // padding and content scrolls underneath it.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: trailing,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: padding.top)),
          ...widget.slivers,
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
        ],
      ),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      body: CustomScrollView(
        slivers: [
          ...widget.slivers,
          SliverToBoxAdapter(child: SizedBox(height: bottom)),
        ],
      ),
    );
  }
}
