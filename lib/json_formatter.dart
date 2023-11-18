import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class JsonFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    try {
      final map = jsonDecode(newText);
      newText = const JsonEncoder.withIndent('  ').convert(map);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return newValue.copyWith(
      text: newText,
    );
  }
}
