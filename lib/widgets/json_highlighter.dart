import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:google_fonts/google_fonts.dart';

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
        textStyle: GoogleFonts.lato(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }
}
