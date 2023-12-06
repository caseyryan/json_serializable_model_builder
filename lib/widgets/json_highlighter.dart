import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import 'highlighter_theme.dart';

class JsonHighlighter extends StatelessWidget {
  const JsonHighlighter({
    super.key,
    required this.value,
    this.language = 'json',
  });

  final String value;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      child: HighlightView(
        value,
        language: language,
        theme: highlighterThemeLight,
      ),
    );
  }
}
