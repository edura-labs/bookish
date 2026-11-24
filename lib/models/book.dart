/// A book as Bookish knows it: one Open Library "work".
///
/// Search results fill everything except [description]. The description
/// only comes from the work endpoint, so it is added later with
/// [Book.withWorkDetails].
///
/// Two books are equal when they share the same [key], whatever their other
/// fields hold. The shelf relies on this.
class Book {
  const Book({
    required this.key,
    required this.title,
    this.authors = const [],
    this.firstPublishYear,
    this.coverId,
    this.pageCount,
    this.description,
  });

  /// Bare Open Library work id, e.g. `OL893415W` (never `/works/OL893415W`).
  final String key;
  final String title;

  /// Author names in the order Open Library lists them. Empty when unknown.
  final List<String> authors;
  final int? firstPublishYear;

  /// Open Library cover id. Null when the book has no cover.
  final int? coverId;

  /// Median page count across editions. Null when unknown.
  final int? pageCount;
  final String? description;

  /// Parses one entry of the `docs` list from `/search.json`.
  ///
  /// Returns null when the entry has no usable key or title, so callers can
  /// skip it instead of crashing on one bad record.
  static Book? fromSearchJson(Map<String, dynamic> json) {
    final rawKey = json['key'];
    final rawTitle = json['title'];
    if (rawKey is! String || rawTitle is! String) return null;

    final key = normaliseKey(rawKey);
    final title = rawTitle.trim();
    if (key.isEmpty || title.isEmpty) return null;

    final authors = json['author_name'];

    return Book(
      key: key,
      title: title,
      authors: authors is List
          ? authors.whereType<String>().toList(growable: false)
          : const [],
      firstPublishYear: _asInt(json['first_publish_year']),
      coverId: _validCoverId(json['cover_i']),
      pageCount: _positiveInt(json['number_of_pages_median']),
    );
  }

  /// Returns a copy with the fields from `/works/<key>.json` merged in:
  /// the description, and a cover when the search result had none.
  Book withWorkDetails(Map<String, dynamic> json) {
    return copyWith(
      description: parseDescription(json['description']),
      coverId: coverId ?? _firstValidCover(json['covers']),
    );
  }

  Book copyWith({
    String? title,
    List<String>? authors,
    int? firstPublishYear,
    int? coverId,
    int? pageCount,
    String? description,
  }) {
    return Book(
      key: key,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      coverId: coverId ?? this.coverId,
      pageCount: pageCount ?? this.pageCount,
      description: description ?? this.description,
    );
  }

  /// Turns `/works/OL893415W` (search format) into `OL893415W`.
  static String normaliseKey(String raw) {
    final parts = raw.trim().split('/').where((part) => part.isNotEmpty);
    return parts.isEmpty ? '' : parts.last;
  }

  /// Open Library sends a description either as a plain string or as
  /// `{"type": "/type/text", "value": "..."}`. Anything else counts as none.
  static String? parseDescription(Object? raw) {
    final Object? text = raw is Map ? raw['value'] : raw;
    if (text is! String) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _asInt(Object? raw) => raw is num ? raw.toInt() : null;

  static int? _positiveInt(Object? raw) {
    final value = _asInt(raw);
    return (value == null || value <= 0) ? null : value;
  }

  // Open Library uses -1 for "no cover" inside `covers` lists.
  static int? _validCoverId(Object? raw) => _positiveInt(raw);

  static int? _firstValidCover(Object? raw) {
    if (raw is! List) return null;
    for (final id in raw) {
      final valid = _validCoverId(id);
      if (valid != null) return valid;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is Book && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'Book($key, $title)';
}
