import 'package:bookish/ui/common/app_strings.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_button.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_loading_indicator.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_page.dart';
import 'package:bookish/ui/widgets/adaptive/adaptive_search_field.dart';
import 'package:bookish/ui/widgets/book_tile.dart';
import 'package:bookish/ui/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide AdaptivePage;

import 'search_viewmodel.dart';

/// Search tab: debounced Open Library search with endless scrolling.
class SearchView extends StackedView<SearchViewModel> {
  const SearchView({super.key});

  /// Start fetching the next page this far (in logical pixels) before the
  /// end of the list, so new results are usually ready before you get there.
  static const _loadMoreThreshold = 600.0;

  @override
  Widget builder(
    BuildContext context,
    SearchViewModel viewModel,
    Widget? child,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _maybeLoadMore(notification, viewModel);
        return false;
      },
      child: AdaptivePage(
        title: ksSearchTitle,
        largeTitle: true,
        searchField: AdaptiveSearchField(
          placeholder: ksSearchPlaceholder,
          onChanged: viewModel.onQueryChanged,
          onSubmitted: viewModel.onSubmitted,
        ),
        slivers: _content(viewModel),
      ),
    );
  }

  /// Pagination helper: asks for the next page as the list nears its end.
  void _maybeLoadMore(
    ScrollNotification notification,
    SearchViewModel viewModel,
  ) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return;
    if (metrics.extentAfter > _loadMoreThreshold) return;
    if (viewModel.canLoadMore) viewModel.loadMore();
  }

  List<Widget> _content(SearchViewModel viewModel) {
    switch (viewModel.status) {
      case SearchStatus.idle:
        return const [
          SliverToBoxAdapter(
            child: EmptyState(
              materialIcon: Icons.search,
              cupertinoIcon: CupertinoIcons.search,
              title: ksSearchEmptyTitle,
              message: ksSearchEmptyMessage,
            ),
          ),
        ];

      case SearchStatus.loading:
        return const [
          SliverPadding(
            padding: EdgeInsets.only(top: 48),
            sliver: SliverToBoxAdapter(
              child: Center(child: AdaptiveLoadingIndicator()),
            ),
          ),
        ];

      case SearchStatus.empty:
        return [
          SliverToBoxAdapter(
            child: EmptyState(
              materialIcon: Icons.search_off,
              cupertinoIcon: CupertinoIcons.book,
              title: ksSearchNoResultsTitle,
              message: ksSearchNoResultsMessage(viewModel.query),
            ),
          ),
        ];

      case SearchStatus.error:
        return [
          SliverToBoxAdapter(
            child: EmptyState(
              materialIcon: Icons.cloud_off,
              cupertinoIcon: CupertinoIcons.wifi_slash,
              title: ksSearchErrorTitle,
              message: viewModel.errorMessage ?? ksErrorUnknown,
              action: AdaptiveButton(
                label: ksRetry,
                onPressed: viewModel.retry,
              ),
            ),
          ),
        ];

      case SearchStatus.results:
        return [
          SliverList.separated(
            itemCount: viewModel.books.length,
            itemBuilder: (context, index) {
              final book = viewModel.books[index];
              return BookTile(book: book, coverUrl: viewModel.coverUrl(book));
            },
            // Inset to line up with the text, as in iOS and Material lists.
            separatorBuilder: (context, index) => const Divider(indent: 78),
          ),
          SliverToBoxAdapter(child: _ListFooter(viewModel: viewModel)),
        ];
    }
  }

  @override
  SearchViewModel viewModelBuilder(BuildContext context) => SearchViewModel();
}

/// Below the results: a spinner while the next page loads, or a retry
/// button if it failed.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.viewModel});

  final SearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: AdaptiveLoadingIndicator()),
      );
    }

    if (viewModel.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: AdaptiveButton(
            label: ksRetry,
            style: AdaptiveButtonStyle.secondary,
            onPressed: viewModel.retryLoadMore,
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
