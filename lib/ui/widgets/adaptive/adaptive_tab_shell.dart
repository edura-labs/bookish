import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// One top-level destination. Labels should be a single word where possible.
class AdaptiveTab {
  const AdaptiveTab({
    required this.label,
    required this.materialIcon,
    required this.materialSelectedIcon,
    required this.cupertinoIcon,
    required this.child,
  });

  final String label;
  final IconData materialIcon;
  final IconData materialSelectedIcon;

  /// Apple prefers filled symbols in tab bars; selection is shown by tint.
  final IconData cupertinoIcon;
  final Widget child;
}

/// Top-level navigation, rendered natively per platform:
///
/// * iOS 26+: a floating Liquid Glass tab bar (`GlassTabBar.bottom`) over the
///   content. Falls back to the classic bar when Increase Contrast is on.
/// * iOS below 26: `CupertinoTabScaffold` + `CupertinoTabBar`.
/// * On both iOS paths each tab gets its own navigation stack
///   (`CupertinoTabView`), so pushed screens keep the tab bar and each tab
///   keeps its place when you switch away and back.
/// * Android: Material 3 `NavigationBar`, with tab state kept in an
///   `IndexedStack`.
///
/// The selected index lives in the ViewModel: pass it in as [currentIndex]
/// and update it from [onTabSelected].
class AdaptiveTabShell extends StatefulWidget {
  const AdaptiveTabShell({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
  }) : assert(tabs.length >= 2, 'A tab bar needs at least two tabs.');

  final List<AdaptiveTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  State<AdaptiveTabShell> createState() => _AdaptiveTabShellState();
}

class _AdaptiveTabShellState extends State<AdaptiveTabShell> {
  CupertinoTabController? _controller;

  @override
  void initState() {
    super.initState();
    if (AppPlatform.current.isIos) {
      _controller = CupertinoTabController(initialIndex: widget.currentIndex)
        ..addListener(_onCupertinoTabChanged);
    }
  }

  @override
  void didUpdateWidget(AdaptiveTabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (controller != null && controller.index != widget.currentIndex) {
      controller.index = widget.currentIndex;
    }
  }

  void _onCupertinoTabChanged() {
    final index = _controller!.index;
    if (index != widget.currentIndex) widget.onTabSelected(index);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return AppPlatform.usesGlass(context)
          ? _buildGlass(context, controller)
          : _buildCupertino(controller);
    }
    return _buildMaterial();
  }

  Widget _buildGlass(BuildContext context, CupertinoTabController controller) {
    final tint = CupertinoTheme.of(context).primaryColor;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final tabBar = GlassTabBar.bottom(
      selectedIndex: widget.currentIndex,
      // The controller's listener reports the change to the ViewModel.
      onTabSelected: (index) => controller.index = index,
      selectedIconColor: tint,
      selectedLabelColor: tint,
      unselectedIconColor: muted,
      unselectedLabelColor: muted,
      tabs: [
        for (final tab in widget.tabs)
          GlassTab(
            icon: Icon(tab.cupertinoIcon),
            label: tab.label,
            semanticLabel: tab.label,
          ),
      ],
    );

    // Content scrolls under the floating bar, so pages need its height as
    // bottom padding to keep their last item reachable.
    final media = MediaQuery.of(context);
    return GlassScaffold(
      bottomBar: tabBar,
      body: MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(bottom: tabBar.preferredSize.height),
        ),
        child: IndexedStack(
          index: widget.currentIndex,
          children: [
            for (final tab in widget.tabs)
              CupertinoTabView(builder: (context) => tab.child),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertino(CupertinoTabController controller) {
    return CupertinoTabScaffold(
      controller: controller,
      tabBar: CupertinoTabBar(
        // Active tint comes from the Cupertino theme (walnut / oak).
        inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: [
          for (final tab in widget.tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.cupertinoIcon),
              label: tab.label,
            ),
        ],
      ),
      tabBuilder: (context, index) => CupertinoTabView(
        builder: (context) => widget.tabs[index].child,
      ),
    );
  }

  Widget _buildMaterial() {
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: [for (final tab in widget.tabs) tab.child],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onTabSelected,
        destinations: [
          for (final tab in widget.tabs)
            NavigationDestination(
              icon: Icon(tab.materialIcon),
              selectedIcon: Icon(tab.materialSelectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
