import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, TextStyle> get highlighterThemeLight {
  Color textValueColor = Colors.blue;
  Color numericValueColor = Colors.purple;
  Color stringColor = const Color.fromARGB(
    255,
    168,
    15,
    18,
  );
  return {
    'root': GoogleFonts.lato(
      backgroundColor: Colors.transparent,
      color: Colors.black87,
    ),
    'strong': GoogleFonts.lato(
      color: const Color.fromARGB(255, 255, 255, 0),
    ),
    'emphasis': GoogleFonts.lato(
      color: const Color.fromARGB(255, 238, 238, 237),
      fontStyle: FontStyle.italic,
    ),
    'bullet': TextStyle(
      color: textValueColor,
    ),
    'quote': TextStyle(
      color: textValueColor,
    ),
    'link': TextStyle(
      color: textValueColor,
    ),
    'number': TextStyle(
      color: numericValueColor,
    ),
    'regexp': TextStyle(
      color: textValueColor,
    ),
    'literal': TextStyle(
      color: textValueColor,
    ),
    'code': TextStyle(
      color: stringColor,
    ),
    'selector-class': TextStyle(
      color: stringColor,
    ),
    'keyword': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'selector-tag': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'section': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'attribute': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'name': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'variable': GoogleFonts.lato(
      color: const Color(0xffcb7832),
    ),
    'params': GoogleFonts.lato(
      color: const Color(0xffb9b9b9),
    ),
    'string': TextStyle(
      color: stringColor,
    ),
    'subst': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'type': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'built_in': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'builtin-name': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'symbol': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'selector-id': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'selector-attr': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'selector-pseudo': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'template-tag': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'template-variable': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'addition': GoogleFonts.lato(
      color: const Color.fromARGB(255, 128, 108, 44),
    ),
    'comment': GoogleFonts.lato(
      color: const Color.fromARGB(255, 61, 61, 61),
    ),
    'deletion': GoogleFonts.lato(
      color: const Color.fromARGB(255, 61, 61, 61),
    ),
    'meta': GoogleFonts.lato(
      color: const Color.fromARGB(255, 61, 61, 61),
    ),
  };
}
