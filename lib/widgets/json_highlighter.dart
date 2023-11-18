import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import 'highlighter_theme.dart';

class JsonHighlighter extends StatelessWidget {
  const JsonHighlighter({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      child: HighlightView(
        // textStyle: Theme.of(context).textTheme.bodyMedium,
        value,
        language: 'json',
        theme: highlighterThemeLight,
      ),
    );
  }
}
