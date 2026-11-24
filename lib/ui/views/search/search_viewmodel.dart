import 'dart:async';

import 'package:bookish/app/app.locator.dart';
import 'package:bookish/models/book.dart';
import 'package:bookish/services/open_library_service.dart';
import 'package:stacked/stacked.dart';

enum SearchStatus {
  /// Nothing typed yet (or too short to search).
  idle,

  /// First page on its way.
  loading,
  results,
  empty,
  error,
}

/// Debounced Open Library search with pagination.
///
/// Every search gets an id; a response that arrives after a newer search has
/// started is dropped, so slow requests can never overwrite newer results.
class SearchViewModel extends BaseViewModel {
  SearchViewModel({
    this.debounce = const Duration(milliseconds: 400),
  });

  final _openLibrary = locator<OpenLibraryService>();

  /// How long typing must pause before a search starts.
  final Duration debounce;

  /// Shorter queries don't search: they return too much to be useful.
  static const minQueryLength = 2;
  static const pageSize = OpenLibraryService.defaultPageSize;

  Timer? _debounceTimer;
  int _searchId = 0;

  String _query = '';
  String get query => _query;

  SearchStatus _status = SearchStatus.idle;
  SearchStatus get status => _status;

  List<Book> _books = const [];
  List<Book> get books => _books;

  String? _errorMessage;

  /// User-facing reason the last search failed.
  String? get errorMessage => _errorMessage;

  // ---- pagination state ----
  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _loadMoreError;

  /// Set when fetching the next page failed; the list shows a retry row.
  String? get loadMoreError => _loadMoreError;

  /// Called on every keystroke. Waits for [debounce] before searching.
  void onQueryChanged(String value) {
    _debounceTimer?.cancel();
    final trimmed = value.trim();

    if (trimmed.length < minQueryLength) {
      _searchId++; // drop anything still in flight
      _query = trimmed;
      _books = const [];
      _hasMore = false;
      _isLoadingMore = false;
      _loadMoreError = null;
      _status = SearchStatus.idle;
      rebuildUi();
      return;
    }

    _debounceTimer = Timer(debounce, () => _search(trimmed));
  }

  /// Keyboard search key: search now, skipping the debounce.
  void onSubmitted(String value) {
    _debounceTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.length >= minQueryLength) _search(trimmed);
  }

  Future<void> retry() => _search(_query);

  Future<void> _search(String query) async {
    final id = ++_searchId;
    _query = query;
    _status = SearchStatus.loading;
    _errorMessage = null;
    _books = const [];
    _page = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _loadMoreError = null;
    rebuildUi();

    try {
      final results = await _openLibrary.searchBooks(
        query,
        page: 1,
        limit: pageSize,
      );
      if (id != _searchId) return;
      _books = results;
      _hasMore = results.length == pageSize;
      _status = results.isEmpty ? SearchStatus.empty : SearchStatus.results;
    } on OpenLibraryException catch (error) {
      if (id != _searchId) return;
      _errorMessage = error.message;
      _status = SearchStatus.error;
    }
    rebuildUi();
  }

  // ---- pagination helpers ----

  /// Whether the view should ask for the next page now. Safe to call often.
  bool get canLoadMore =>
      _status == SearchStatus.results &&
      _hasMore &&
      !_isLoadingMore &&
      _loadMoreError == null;

  /// Fetches the next page and appends it. Does nothing unless [canLoadMore].
  Future<void> loadMore() async {
    if (!canLoadMore) return;
    final id = _searchId;
    _isLoadingMore = true;
    rebuildUi();

    try {
      final next = await _openLibrary.searchBooks(
        _query,
        page: _page + 1,
        limit: pageSize,
      );
      if (id != _searchId) return;
      _page++;
      // Open Library can repeat a work across pages; keep the first one.
      final seen = _books.toSet();
      _books = [..._books, ...next.where(seen.add)];
      _hasMore = next.length == pageSize;
    } on OpenLibraryException catch (error) {
      if (id != _searchId) return;
      _loadMoreError = error.message;
    }
    _isLoadingMore = false;
    rebuildUi();
  }

  /// Clears a failed page load and tries it again.
  Future<void> retryLoadMore() {
    _loadMoreError = null;
    return loadMore();
  }

  String? coverUrl(Book book) => _openLibrary.coverUrl(book.coverId);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
