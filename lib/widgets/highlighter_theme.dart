import 'package:flutter/material.dart';


Map<String, TextStyle> get highlighterThemeLight {
  Color textValueColor = Colors.blue;
  Color numericValueColor = Colors.purple;
  Color stringColor = const Color.fromARGB(255, 168, 15, 18);
  return {
    'root': const TextStyle(
      backgroundColor: Colors.transparent,
      color: Colors.black87,
    ),
    'strong': const TextStyle(color: Color.fromARGB(255, 255, 255, 0)),
    'emphasis': const TextStyle(
      color: Color.fromARGB(255, 238, 238, 237),
      fontStyle: FontStyle.italic,
    ),
    'bullet': TextStyle(color: textValueColor),
    'quote': TextStyle(color: textValueColor),
    'link': TextStyle(color: textValueColor),
    'number': TextStyle(color: numericValueColor),
    'regexp': TextStyle(color: textValueColor),
    'literal': TextStyle(color: textValueColor),
    'code': TextStyle(color: stringColor),
    'selector-class': TextStyle(color: stringColor),
    'keyword': const TextStyle(color: Color(0xffcb7832)),
    'selector-tag': const TextStyle(color: Color(0xffcb7832)),
    'section': const TextStyle(color: Color(0xffcb7832)),
    'attribute': const TextStyle(color: Color(0xffcb7832)),
    'name': const TextStyle(color: Color(0xffcb7832)),
    'variable': const TextStyle(color: Color(0xffcb7832)),
    'params': const TextStyle(color: Color(0xffb9b9b9)),
    'string': TextStyle(color: stringColor),
    'subst': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'type': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'built_in': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'builtin-name': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'symbol': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'selector-id': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'selector-attr': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'selector-pseudo': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'template-tag': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'template-variable': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'addition': const TextStyle(color: Color.fromARGB(255, 128, 108, 44)),
    'comment': const TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
    'deletion': const TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
    'meta': const TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
  };
}
