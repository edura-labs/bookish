import 'package:bookish/ui/common/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
/// * iOS: `CupertinoTabScaffold` + `CupertinoTabBar`. Each tab gets its own
///   navigation stack (`CupertinoTabView`), so pushed screens keep the tab bar
///   and each tab keeps its place when you switch away and back.
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
      return CupertinoTabScaffold(
        controller: controller,
        tabBar: CupertinoTabBar(
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
