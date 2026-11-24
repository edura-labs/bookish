import 'package:bookish/ui/common/app_strings.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_page.dart';
import 'package:bookish/ui/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide AdaptivePage;

import 'shelf_viewmodel.dart';

/// My Shelf tab. The three status tabs arrive in build step 7.
class ShelfView extends StackedView<ShelfViewModel> {
  const ShelfView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ShelfViewModel viewModel,
    Widget? child,
  ) {
    return const AdaptivePage(
      title: ksShelfTitle,
      largeTitle: true,
      slivers: [
        SliverToBoxAdapter(
          child: EmptyState(
            materialIcon: Icons.collections_bookmark_outlined,
            cupertinoIcon: CupertinoIcons.book,
            title: ksShelfEmptyTitle,
            message: ksShelfEmptyMessage,
          ),
        ),
      ],
    );
  }

  @override
  ShelfViewModel viewModelBuilder(BuildContext context) => ShelfViewModel();
}
