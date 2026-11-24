import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bookish/models/book.dart';
import 'package:bookish/services/open_library_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers Dio requests with canned responses, so tests never hit the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  late _FakeAdapter adapter;

  OpenLibraryService serviceWith(
    ResponseBody Function(RequestOptions options) handler,
  ) {
    adapter = _FakeAdapter(handler);
    final dio = Dio(OpenLibraryService.defaultOptions)
      ..httpClientAdapter = adapter;
    return OpenLibraryService(dio: dio);
  }

  const dune = Book(key: 'OL893415W', title: 'Dune');

  group('OpenLibraryServiceTest -', () {
    group('searchBooks -', () {
      test('Blank query returns empty list without a request', () async {
        final service = serviceWith((_) => _json({'docs': []}));

        expect(await service.searchBooks('   '), isEmpty);
        expect(adapter.requests, isEmpty);
      });

      test('Sends trimmed query, field list, paging and User-Agent', () async {
        final service = serviceWith((_) => _json({'docs': []}));

        await service.searchBooks('  dune ', page: 2, limit: 10);

        final request = adapter.requests.single;
        expect(request.path, '/search.json');
        expect(request.queryParameters['q'], 'dune');
        expect(request.queryParameters['page'], 2);
        expect(request.queryParameters['limit'], 10);
        expect(request.queryParameters['fields'], contains('cover_i'));
        expect(
          request.headers[HttpHeaders.userAgentHeader],
          startsWith('Bookish/'),
        );
      });

      test('Parses a complete result', () async {
        final service = serviceWith(
          (_) => _json({
            'numFound': 1,
            'docs': [
              {
                'key': '/works/OL893415W',
                'title': 'Dune',
                'author_name': ['Frank Herbert'],
                'first_publish_year': 1965,
                'cover_i': 11481354,
                'number_of_pages_median': 604,
              },
            ],
          }),
        );

        final book = (await service.searchBooks('dune')).single;

        expect(book.key, 'OL893415W');
        expect(book.title, 'Dune');
        expect(book.authors, ['Frank Herbert']);
        expect(book.firstPublishYear, 1965);
        expect(book.coverId, 11481354);
        expect(book.pageCount, 604);
        expect(book.description, isNull);
      });

      test('Survives missing fields and skips unusable records', () async {
        final service = serviceWith(
          (_) => _json({
            'docs': [
              {'key': '/works/OL1W', 'title': 'Bare'},
              {'key': '/works/OL2W', 'title': 'No cover', 'cover_i': -1},
              {'title': 'No key'},
              {'key': '/works/OL3W'},
              'not a map',
            ],
          }),
        );

        final books = await service.searchBooks('anything');

        expect(books.map((b) => b.key), ['OL1W', 'OL2W']);
        expect(books.first.authors, isEmpty);
        expect(books.first.firstPublishYear, isNull);
        expect(books.first.pageCount, isNull);
        expect(books[1].coverId, isNull);
      });

      test('No results returns an empty list', () async {
        final service = serviceWith((_) => _json({'numFound': 0, 'docs': []}));

        expect(await service.searchBooks('zzzxqv'), isEmpty);
      });

      test('Unexpected body shape throws badResponse', () async {
        final service = serviceWith((_) => _json({'unexpected': true}));

        await expectLater(
          service.searchBooks('dune'),
          throwsA(_errorOfType(OpenLibraryErrorType.badResponse)),
        );
      });
    });

    group('getBookDetails -', () {
      test('Requests the work by bare key', () async {
        final service = serviceWith((_) => _json({}));

        await service.getBookDetails(dune);

        expect(adapter.requests.single.path, '/works/OL893415W.json');
      });

      test('Reads a plain string description', () async {
        final service = serviceWith(
          (_) => _json({'description': '  A desert planet.  '}),
        );

        final book = await service.getBookDetails(dune);

        expect(book.description, 'A desert planet.');
      });

      test('Reads an object description', () async {
        final service = serviceWith(
          (_) => _json({
            'description': {'type': '/type/text', 'value': 'Spice.'},
          }),
        );

        final book = await service.getBookDetails(dune);

        expect(book.description, 'Spice.');
      });

      test('Missing description stays null', () async {
        final service = serviceWith((_) => _json({'title': 'Dune'}));

        expect((await service.getBookDetails(dune)).description, isNull);
      });

      test('Fills a missing cover from covers, skipping -1', () async {
        final service = serviceWith(
          (_) => _json({
            'covers': [-1, 12345],
          }),
        );

        expect((await service.getBookDetails(dune)).coverId, 12345);
      });

      test('Keeps the search cover when it already has one', () async {
        final service = serviceWith(
          (_) => _json({
            'covers': [999],
          }),
        );
        final withCover = dune.copyWith(coverId: 111);

        expect((await service.getBookDetails(withCover)).coverId, 111);
      });
    });

    group('errors -', () {
      test('404 maps to notFound', () async {
        final service = serviceWith((_) => _json({}, status: 404));

        await expectLater(
          service.getBookDetails(dune),
          throwsA(_errorOfType(OpenLibraryErrorType.notFound)),
        );
      });

      test('5xx maps to server', () async {
        final service = serviceWith((_) => _json({}, status: 503));

        await expectLater(
          service.searchBooks('dune'),
          throwsA(_errorOfType(OpenLibraryErrorType.server)),
        );
      });

      test('Connection error maps to noConnection', () async {
        final service = serviceWith(
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        );

        await expectLater(
          service.searchBooks('dune'),
          throwsA(_errorOfType(OpenLibraryErrorType.noConnection)),
        );
      });

      test('Timeout maps to timeout', () async {
        final service = serviceWith(
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        );

        await expectLater(
          service.searchBooks('dune'),
          throwsA(_errorOfType(OpenLibraryErrorType.timeout)),
        );
      });
    });

    group('coverUrl -', () {
      final service = OpenLibraryService();

      test('Null or invalid id gives null', () {
        expect(service.coverUrl(null), isNull);
        expect(service.coverUrl(-1), isNull);
      });

      test('Builds a sized URL that 404s when missing', () {
        expect(
          service.coverUrl(42, size: CoverSize.large),
          'https://covers.openlibrary.org/b/id/42-L.jpg?default=false',
        );
      });
    });
  });

  group('BookTest -', () {
    test('normaliseKey strips the /works/ prefix', () {
      expect(Book.normaliseKey('/works/OL893415W'), 'OL893415W');
      expect(Book.normaliseKey('OL893415W'), 'OL893415W');
    });

    test('Books with the same key are equal', () {
      expect(dune, const Book(key: 'OL893415W', title: 'Other title'));
      expect(dune.hashCode, const Book(key: 'OL893415W', title: 'x').hashCode);
    });

    test('Blank descriptions count as none', () {
      expect(Book.parseDescription('   '), isNull);
      expect(Book.parseDescription({'value': 42}), isNull);
      expect(Book.parseDescription(null), isNull);
    });
  });
}

Matcher _errorOfType(OpenLibraryErrorType type) => isA<OpenLibraryException>()
    .having((error) => error.type, 'type', type);
