import 'dart:io';

import 'package:bookish/models/book.dart';
import 'package:bookish/ui/common/app_strings.dart';
import 'package:dio/dio.dart';

/// Cover image sizes Open Library serves: small, medium and large.
enum CoverSize {
  small('S'),
  medium('M'),
  large('L');

  const CoverSize(this.suffix);
  final String suffix;
}

/// Why an Open Library call failed. ViewModels switch on this to pick the
/// right empty/error state; they never see Dio types.
enum OpenLibraryErrorType {
  noConnection,
  timeout,
  notFound,
  server,
  badResponse,
  cancelled,
  unknown,
}

class OpenLibraryException implements Exception {
  const OpenLibraryException(this.type, this.message);

  final OpenLibraryErrorType type;

  /// Safe to show to the user as is.
  final String message;

  @override
  String toString() => 'OpenLibraryException(${type.name}): $message';
}

/// All Open Library access goes through here. Nothing else in the app
/// imports Dio.
class OpenLibraryService {
  OpenLibraryService({Dio? dio}) : _dio = dio ?? Dio(defaultOptions);

  final Dio _dio;

  static const _baseUrl = 'https://openlibrary.org';
  static const _coversBaseUrl = 'https://covers.openlibrary.org/b/id';

  // Open Library asks clients to identify themselves with an app name and a
  // contact address, so they can reach us instead of blocking us.
  static const _userAgent = 'Bookish/0.1.0 (gideon.dart@gmail.com)';

  // Only the fields the app uses. The default search response is large.
  static const _searchFields = 'key,title,author_name,first_publish_year,'
      'cover_i,number_of_pages_median';

  static const defaultPageSize = 20;

  static BaseOptions get defaultOptions => BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {HttpHeaders.userAgentHeader: _userAgent},
      );

  /// Searches by title, author or keyword. [page] starts at 1.
  ///
  /// A blank query returns an empty list without calling the API.
  /// Throws [OpenLibraryException] on failure.
  Future<List<Book>> searchBooks(
    String query, {
    int page = 1,
    int limit = defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final data = await _getJson(
      '/search.json',
      queryParameters: {
        'q': trimmed,
        'fields': _searchFields,
        'page': page,
        'limit': limit,
      },
      cancelToken: cancelToken,
    );

    final docs = data['docs'];
    if (docs is! List) throw _badResponse();

    return docs
        .whereType<Map<String, dynamic>>()
        .map(Book.fromSearchJson)
        .whereType<Book>()
        .toList(growable: false);
  }

  /// Returns [book] with its description (and a cover, if it had none)
  /// filled in from the work endpoint.
  /// Throws [OpenLibraryException] on failure.
  Future<Book> getBookDetails(Book book, {CancelToken? cancelToken}) async {
    final data = await _getJson(
      '/works/${book.key}.json',
      cancelToken: cancelToken,
    );
    return book.withWorkDetails(data);
  }

  /// Cover image URL, or null when there is no cover.
  ///
  /// `default=false` makes Open Library answer 404 for a missing image
  /// instead of a blank 1x1 pixel, so the UI's error placeholder shows.
  String? coverUrl(int? coverId, {CoverSize size = CoverSize.medium}) {
    if (coverId == null || coverId <= 0) return null;
    return '$_coversBaseUrl/$coverId-${size.suffix}.jpg?default=false';
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) throw _badResponse();
      return data;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  OpenLibraryException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const OpenLibraryException(
          OpenLibraryErrorType.timeout,
          ksErrorTimeout,
        );
      case DioExceptionType.connectionError:
        return const OpenLibraryException(
          OpenLibraryErrorType.noConnection,
          ksErrorNoConnection,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status == 404) {
          return const OpenLibraryException(
            OpenLibraryErrorType.notFound,
            ksErrorNotFound,
          );
        }
        if (status >= 500) {
          return const OpenLibraryException(
            OpenLibraryErrorType.server,
            ksErrorServer,
          );
        }
        return _badResponse();
      case DioExceptionType.cancel:
        return const OpenLibraryException(
          OpenLibraryErrorType.cancelled,
          ksErrorCancelled,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const OpenLibraryException(
            OpenLibraryErrorType.noConnection,
            ksErrorNoConnection,
          );
        }
        return const OpenLibraryException(
          OpenLibraryErrorType.unknown,
          ksErrorUnknown,
        );
    }
  }

  OpenLibraryException _badResponse() => const OpenLibraryException(
        OpenLibraryErrorType.badResponse,
        ksErrorBadResponse,
      );
}
