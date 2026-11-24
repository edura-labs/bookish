import 'package:bookish/ui/common/app_platform.dart';
import 'package:bookish/ui/common/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A search input, rendered natively per platform:
///
/// * iOS 26+: Liquid Glass search bar (`GlassSearchBar`).
/// * iOS below 26: `CupertinoSearchTextField`.
/// * Android: Material text field with a search icon and a clear button.
///
/// Every platform's clear button reports an empty string to [onChanged].
class AdaptiveSearchField extends StatefulWidget {
  const AdaptiveSearchField({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.onSubmitted,
  });

  final String placeholder;
  final ValueChanged<String> onChanged;

  /// Called when the keyboard's search key is pressed.
  final ValueChanged<String>? onSubmitted;

  @override
  State<AdaptiveSearchField> createState() => _AdaptiveSearchFieldState();
}

class _AdaptiveSearchFieldState extends State<AdaptiveSearchField> {
  // Owned here so every platform keeps its text across rebuilds and Android
  // can show its clear button.
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = AppTypography.of(context);
    final muted = scheme.onSurfaceVariant;

    if (AppPlatform.usesGlass(context)) {
      return GlassSearchBar(
        controller: _controller,
        placeholder: widget.placeholder,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textStyle: type.body,
        placeholderStyle: type.body.copyWith(color: muted),
        searchIconColor: muted,
        clearIconColor: muted,
        cancelButtonColor: CupertinoTheme.of(context).primaryColor,
        clearButtonSemanticLabel: 'Clear search',
      );
    }

    if (AppPlatform.current.isIos) {
      return CupertinoSearchTextField(
        controller: _controller,
        placeholder: widget.placeholder,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: type.body,
        placeholderStyle: type.body.copyWith(color: muted),
        itemColor: muted,
        backgroundColor: scheme.outlineVariant.withValues(alpha: 0.6),
        onSuffixTap: _clear,
      );
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
