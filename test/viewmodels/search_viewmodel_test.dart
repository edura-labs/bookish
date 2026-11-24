import 'dart:async';

import 'package:bookish/app/app.locator.dart';
import 'package:bookish/models/book.dart';
import 'package:bookish/services/open_library_service.dart';
import 'package:bookish/ui/views/search/search_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

List<Book> _books(int count, {int start = 0}) => [
      for (var i = start; i < start + count; i++)
        Book(key: 'OL${i}W', title: 'Book $i'),
    ];

void main() {
  late MockOpenLibraryService openLibrary;

  SearchViewModel getModel() => SearchViewModel(debounce: Duration.zero);

  void stubSearch(
    Future<List<Book>> Function(String query, int page) answer,
  ) {
    when(
      openLibrary.searchBooks(
        any,
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      ),
    ).thenAnswer(
      (call) => answer(
        call.positionalArguments.first as String,
        call.namedArguments[#page] as int,
      ),
    );
  }

  group('SearchViewModelTest -', () {
    setUp(() {
      registerServices();
      openLibrary = getAndRegisterOpenLibraryService();
    });
    tearDown(() => locator.reset());

    test('Starts idle', () {
      final model = getModel();
      expect(model.status, SearchStatus.idle);
      expect(model.books, isEmpty);
    });

    test('Short queries stay idle and never call the API', () async {
      final model = getModel();
      model.onQueryChanged(' d ');
      await Future<void>.delayed(Duration.zero);

      expect(model.status, SearchStatus.idle);
      verifyNever(
        openLibrary.searchBooks(
          any,
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      );
    });

    test('Typing searches after the debounce, with the trimmed query', () async {
      stubSearch((_, __) async => _books(3));
      final model = SearchViewModel(
        debounce: const Duration(milliseconds: 20),
      );

      model.onQueryChanged('du');
      model.onQueryChanged('dun');
      model.onQueryChanged(' dune ');
      await Future<void>.delayed(const Duration(milliseconds: 60));

      // Only the last keystroke searched.
      verify(
        openLibrary.searchBooks(
          'dune',
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ),
      ).called(1);
      expect(model.status, SearchStatus.results);
      expect(model.books, hasLength(3));
    });

    test('No results gives the empty state', () async {
      stubSearch((_, __) async => const []);
      final model = getModel();

      model.onSubmitted('zzzxqv');
      await Future<void>.delayed(Duration.zero);

      expect(model.status, SearchStatus.empty);
      expect(model.query, 'zzzxqv');
    });

    test('A failed search shows the error message and can retry', () async {
      var fail = true;
      stubSearch((_, __) async {
        if (fail) {
          throw const OpenLibraryException(
            OpenLibraryErrorType.noConnection,
            'Offline',
          );
        }
        return _books(2);
      });
      final model = getModel();

      model.onSubmitted('dune');
      await Future<void>.delayed(Duration.zero);
      expect(model.status, SearchStatus.error);
      expect(model.errorMessage, 'Offline');

      fail = false;
      await model.retry();
      expect(model.status, SearchStatus.results);
      expect(model.books, hasLength(2));
    });

    test('A slow older search never overwrites a newer one', () async {
      final slow = Completer<List<Book>>();
      stubSearch(
        (query, _) => query == 'old' ? slow.future : Future.value(_books(1)),
      );
      final model = getModel();

      model.onSubmitted('old');
      model.onSubmitted('new');
      await Future<void>.delayed(Duration.zero);
      slow.complete(_books(5, start: 100));
      await Future<void>.delayed(Duration.zero);

      expect(model.query, 'new');
      expect(model.books.single.key, 'OL0W');
    });

    test('Clearing the field drops an in-flight search', () async {
      final slow = Completer<List<Book>>();
      stubSearch((_, __) => slow.future);
      final model = getModel();

      model.onSubmitted('dune');
      model.onQueryChanged('');
      slow.complete(_books(3));
      await Future<void>.delayed(Duration.zero);

      expect(model.status, SearchStatus.idle);
      expect(model.books, isEmpty);
    });

    group('pagination -', () {
      test('A full page means more can load; loadMore appends it', () async {
        stubSearch(
          (_, page) async => page == 1
              ? _books(SearchViewModel.pageSize)
              : _books(5, start: SearchViewModel.pageSize),
        );
        final model = getModel();

        model.onSubmitted('dune');
        await Future<void>.delayed(Duration.zero);
        expect(model.canLoadMore, isTrue);

        await model.loadMore();

        expect(model.books, hasLength(SearchViewModel.pageSize + 5));
        expect(model.hasMore, isFalse, reason: 'second page was short');
        expect(model.canLoadMore, isFalse);
        verify(
          openLibrary.searchBooks(
            'dune',
            page: 2,
            limit: anyNamed('limit'),
          ),
        ).called(1);
      });

      test('A short first page means nothing more to load', () async {
        stubSearch((_, __) async => _books(3));
        final model = getModel();

        model.onSubmitted('dune');
        await Future<void>.delayed(Duration.zero);

        expect(model.hasMore, isFalse);
        expect(model.canLoadMore, isFalse);
      });

      test('Duplicate works across pages are kept once', () async {
        stubSearch(
          (_, page) async => page == 1
              ? _books(SearchViewModel.pageSize)
              : _books(3, start: SearchViewModel.pageSize - 1),
        );
        final model = getModel();

        model.onSubmitted('dune');
        await Future<void>.delayed(Duration.zero);
        await model.loadMore();

        expect(model.books, hasLength(SearchViewModel.pageSize + 2));
      });

      test('A failed page shows a retry and keeps the results', () async {
        var failPage2 = true;
        stubSearch((_, page) async {
          if (page == 2 && failPage2) {
            throw const OpenLibraryException(
              OpenLibraryErrorType.timeout,
              'Too slow',
            );
          }
          return page == 1
              ? _books(SearchViewModel.pageSize)
              : _books(2, start: SearchViewModel.pageSize);
        });
        final model = getModel();

        model.onSubmitted('dune');
        await Future<void>.delayed(Duration.zero);
        await model.loadMore();

        expect(model.loadMoreError, 'Too slow');
        expect(model.books, hasLength(SearchViewModel.pageSize));
        expect(model.canLoadMore, isFalse);

        failPage2 = false;
        await model.retryLoadMore();
        expect(model.loadMoreError, isNull);
        expect(model.books, hasLength(SearchViewModel.pageSize + 2));
      });
    });
  });
}
