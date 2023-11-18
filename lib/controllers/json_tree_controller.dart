// ignore_for_file: depend_on_referenced_packages, unnecessary_getters_setters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart' show highlight;
import 'package:highlight/languages/dart.dart' as dart_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import 'package:lite_forms/utils/exports.dart';
import 'package:lite_state/lite_state.dart';

JsonTreeController get jsonTreeController {
  return findController<JsonTreeController>();
}

class JsonTreeController extends LiteStateController<JsonTreeController> {
  final TextEditingController jsonController = TextEditingController();

  String? _error;
  String? get error => _error;
  Map<String, dynamic> json = {};
  TypeWrapper? typeWrapper;
  bool _langRegistered = false;

  void _registerLanguages() {
    highlight.registerLanguage('json', json_lang.json);
    highlight.registerLanguage('dart', dart_lang.dart);
    _langRegistered = true;
    rebuild();
  }

  String _modelName = 'ClassName';

  void onModelNameChange(String value) {
    _modelName = value;
  }

  bool get showHighlightedText {
    return json.isNotEmpty && _error == null && _langRegistered;
  }

  String get formattedJson {
    return const JsonEncoder.withIndent(' ').convert(json);
  }

  void rebuildJson() {
    if (json.isNotEmpty) {
      typeWrapper = buildTypeValueTree(
        json: json,
        typeName: _modelName,
        name: _modelName.firstToLowerCase(),
      );
      rebuild();
    }
  }

  Future onJsonEnter(String value) async {
    try {
      _error = null;
      json = jsonDecode(value);
      typeWrapper = buildTypeValueTree(
        json: json,
        typeName: _modelName,
        name: _modelName.firstToLowerCase(),
      );
    } catch (e) {
      json = {};
      _error = 'Invalid JSON';
    }
    rebuild();
  }

  TypeWrapper buildTypeValueTree({
    required Map<String, dynamic> json,
    required String name,
    String? typeName,
  }) {
    List<Wrapper> values = [];
    TypeWrapper wrapper = TypeWrapper(
      name: name,
      values: values,
      typeName: typeName,
    );
    for (var kv in json.entries) {
      if (kv.value is Map) {
        final tName = kv.key.firstToUpperCase();
        values.add(
          buildTypeValueTree(
            json: kv.value,
            typeName: tName,
            name: kv.key,
          ),
        );
      } else {
        values.add(
          ValueWrapper(
            keyName: kv.key,
            value: kv.value,
          ),
        );
      }
    }
    return wrapper;
  }

  @override
  void reset() {}
  @override
  void onLocalStorageInitialized() {
    _registerLanguages();
  }
}

class TypeWrapper extends Wrapper {
  List<Wrapper> values;
  String? typeName;
  TypeWrapper({
    required String name,
    required this.values,
    required this.typeName,
  }) : super(
          keyName: name,
        );

  @override
  set isNullable(bool value) {
    super.isNullable = value;
    for (var v in values) {
      if (v.isChangedManually) {
        continue;
      }
      v.isNullable = value;
    }
  }

  String get proposedTypeName {
    const suffix = '?';
    if (alternativeTypeName != null) {
      return '$alternativeTypeName$suffix';
    }
    return '${typeName ?? super.keyName.firstToUpperCase()}$suffix';
  }
}

class ValueWrapper extends Wrapper {
  static final RegExp _doubleRegexp = RegExp(r'^(-?)(0|([1-9][0-9]*))(\.[0-9]+)?$');

  Object? value;
  Object? alternativeDefaultValue;  

  ValueWrapper({
    required String keyName,
    this.value,
  }) : super(keyName: keyName);

  /// Balances or prices most probably must be doubles event they come as
  /// `int` in a json
  bool get _doubleMightBeUseful {
    final lowerName = (alternativeKeyName ?? keyName).toLowerCase();
    return (lowerName.contains('balance') ||
        lowerName.contains('price') ||
        lowerName.contains('fee') ||
        lowerName.contains('commission') ||
        lowerName.contains('payment') ||
        lowerName.contains('pay') ||
        lowerName.contains('amount'));
  }

  bool get _dateTimeMightBeUseful {
    final lowerName = (alternativeKeyName ?? keyName).toLowerCase();
    return lowerName.contains('createdAt') ||
        lowerName.contains('updatedAt') ||
        lowerName.contains('date') ||
        lowerName.contains('time');
  }

  @override
  set isNullable(bool value) {
    if (!canBeNullable) {
      value = true;
    }
    super.isNullable = value;
  }
  
  bool get canBeNullable {
    return defaultValue != null;
  }

  Object? get defaultValue {
    if (alternativeDefaultValue != null) {
      return alternativeDefaultValue!;
    }
    final typeName = proposedTypeName.replaceAll('?', '');

    // if (typeName.endsWith('?')) {
    //   return null;
    // }
    switch (typeName) {
      case 'int':
        return 0;
      case 'double':
        return 0.0;
      case 'bool':
        return false;
      case 'String':
        return '';
    }
    return null;
  }

  String get proposedTypeName {
    if (alternativeTypeName != null) {
      return alternativeTypeName!;
    }
    if (value == null) {
      return 'Object?';
    }
    final suffix = _isNullable ? '?' : '';
    if (value is String) {
      String v = value as String;
      if (v.contains('.')) {
        if (_doubleRegexp.hasMatch(v)) {
          return 'double$suffix';
        }
        // return 'String$suffix';
      }
      if (int.tryParse(v) != null) {
        return 'int$suffix';
      }
      if (DateTime.tryParse(v) != null || _dateTimeMightBeUseful) {
        return 'DateTime$suffix';
      }
      if (v.toLowerCase() == 'true' || v.toLowerCase() == 'false') {
        return 'bool$suffix';
      }
    }
    if (value is double || _doubleMightBeUseful) {
      return 'double$suffix';
    } else if (value is int) {
      return 'int$suffix';
    }

    if (value is bool) {
      return 'bool$suffix';
    }
    return '${value.runtimeType.toString()}$suffix';
  }
}

class Wrapper {
  String keyName;
  bool _isNullable = true;
  set isNullable(bool value) {
    _isNullable = value;
  }

  bool get isNullable {
    return _isNullable;
  }

  String? alternativeKeyName;

  bool isChangedManually = false;

  /// If proposed type name is incorrect, you can set an alternative
  /// type name manually
  String? alternativeTypeName;

  Wrapper({
    required this.keyName,
  });
}
