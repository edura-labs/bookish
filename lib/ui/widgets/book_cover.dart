import 'package:bookish/ui/common/app_platform.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A book cover at a fixed size, with a quiet placeholder while it loads and
/// when the book has no cover (Open Library answers 404 for those).
///
/// Content, so always solid: never glass.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    this.width = 48,
    this.height = 72,
    this.borderRadius = 4,
  });

  /// Null when the book has no cover.
  final String? url;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(width: width);
    final url = this.url;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: url == null
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.outlineVariant,
      child: Center(
        child: Icon(
          AppPlatform.current.isIos ? CupertinoIcons.book : Icons.menu_book,
          size: width * 0.45,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
