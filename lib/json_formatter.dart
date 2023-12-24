// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:json_serializable_model_builder/controllers/tokenizer.dart';

class JsonFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    try {
      newText = newText.formatJson();
    } catch (e) {
      print(e);
    }
    return newValue.copyWith(
      text: newText,
    );
  }
}
