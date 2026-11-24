import 'package:bookish/ui/common/app_strings.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_page.dart';
import 'package:bookish/ui/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide AdaptivePage;

import 'search_viewmodel.dart';

/// Search tab. The search field and results arrive in build step 4.
class SearchView extends StackedView<SearchViewModel> {
  const SearchView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SearchViewModel viewModel,
    Widget? child,
  ) {
    return const AdaptivePage(
      title: ksSearchTitle,
      largeTitle: true,
      slivers: [
        SliverToBoxAdapter(
          child: EmptyState(
            materialIcon: Icons.search,
            cupertinoIcon: CupertinoIcons.search,
            title: ksSearchEmptyTitle,
            message: ksSearchEmptyMessage,
          ),
        ),
      ],
    );
  }

  @override
  SearchViewModel viewModelBuilder(BuildContext context) => SearchViewModel();
}
