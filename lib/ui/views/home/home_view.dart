import 'package:bookish/ui/common/app_strings.dart';
import 'package:bookish/ui/views/search/search_view.dart';
import 'package:bookish/ui/views/shelf/shelf_view.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_tab_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

/// The app's root: top-level tabs for Search and My Shelf.
class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return AdaptiveTabShell(
      currentIndex: viewModel.currentIndex,
      onTabSelected: viewModel.setIndex,
      tabs: const [
        AdaptiveTab(
          label: ksTabSearch,
          materialIcon: Icons.search_outlined,
          materialSelectedIcon: Icons.search,
          cupertinoIcon: CupertinoIcons.search,
          child: SearchView(),
        ),
        AdaptiveTab(
          label: ksTabShelf,
          materialIcon: Icons.collections_bookmark_outlined,
          materialSelectedIcon: Icons.collections_bookmark,
          cupertinoIcon: CupertinoIcons.book_fill,
          child: ShelfView(),
        ),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
