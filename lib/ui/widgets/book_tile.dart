import 'package:bookish/models/book.dart';
import 'package:bookish/ui/common/app_typography.dart';
import 'package:bookish/ui/widgets/book_cover.dart';
import 'package:flutter/material.dart';

/// One book in a list: cover, title, authors, first published year and page
/// count. Content, so always solid: never glass.
class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    required this.coverUrl,
  });

  final Book book;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final type = AppTypography.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final byline = [
      if (book.authors.isNotEmpty) book.authors.take(2).join(', '),
      if (book.firstPublishYear != null) '${book.firstPublishYear}',
    ].join(' · ');
    final pages = book.pageCount == null ? null : '${book.pageCount} pages';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(url: coverUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: type.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (byline.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    byline,
                    style: type.subheadline.copyWith(color: muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (pages != null) ...[
                  const SizedBox(height: 2),
                  Text(pages, style: type.footnote.copyWith(color: muted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
