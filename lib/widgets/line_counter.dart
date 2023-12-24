import 'package:flutter/material.dart';

class LineCounter extends StatelessWidget {
  const LineCounter({
    super.key,
    required this.numLines,
    required this.style,
  });

  final TextStyle style;
  final int numLines;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    for (var i = 0; i < numLines; i++) {
      buffer.write('${i + 1}.\n');
    }
    return Padding(
      padding: const EdgeInsets.only(
        right: 12.0,
      ),
      child: Text(
        buffer.toString(),
        style: style,
      ),
    );
  }
}
