import 'package:flutter/material.dart';


class VideoTitle extends StatelessWidget {
  const VideoTitle({
    super.key,
    required this.text,
    required this.style,
    this.query = '',
    this.maxLines = 3,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle style;

  final String query;

  final int maxLines;
  final TextAlign textAlign;

  static final RegExp _arabic = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿ]');

  static TextDirection? directionOf(String text) {
    return _arabic.hasMatch(text) ? TextDirection.rtl : null;
  }

  @override
  Widget build(BuildContext context) {
    final String needle = query.trim().toLowerCase();
    final TextDirection? direction = directionOf(text);

    if (needle.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        textDirection: direction,
      );
    }

    return Text.rich(
      TextSpan(children: _buildSpans(context, needle)),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      textDirection: direction,
    );
  }

  List<InlineSpan> _buildSpans(BuildContext context, String needle) {
    final String haystack = text.toLowerCase();
    final Color accent = Theme.of(context).colorScheme.primary;

    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;

    while (cursor <= text.length) {
      final int index = haystack.indexOf(needle, cursor);
      if (index == -1) break;

      if (index > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, index), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + needle.length),
          style: style.copyWith(
            color: accent,
            fontWeight: FontWeight.w800,
            backgroundColor: accent.withValues(alpha: 0.12),
          ),
        ),
      );
      cursor = index + needle.length;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }

    return spans;
  }
}
