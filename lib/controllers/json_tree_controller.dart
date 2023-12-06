// ignore_for_file: depend_on_referenced_packages, unnecessary_getters_setters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart' show highlight;
import 'package:highlight/languages/dart.dart' as dart_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import 'package:lite_forms/controllers/lite_form_controller.dart';
import 'package:lite_state/lite_state.dart';

import 'tokenizer.dart';

part '_example_json.dart';

enum JsonSettingType {
  preferNullable,
  prependConstWherePossible,
  useFinalForNonNullable,
}

JsonTreeController get jsonTreeController {
  return findController<JsonTreeController>();
}

class JsonTreeController extends LiteStateController<JsonTreeController> {
  final TextEditingController jsonController = TextEditingController();

  static const String kSettingsFormName = 'jsonSettingsForm';

  String? _error;
  String? get error => _error;
  Map<String, dynamic> json = {};
  bool _langRegistered = false;

  List<JsonSettingType> _selectedTypes = [
    JsonSettingType.preferNullable,
    JsonSettingType.useFinalForNonNullable,
    JsonSettingType.prependConstWherePossible,
  ];

  final List<JsonTokenContainer> _tokenContainers = [];
  List<JsonTokenContainer> get tokenContainers {
    return _tokenContainers;
  }

  List<JsonSettingType> get selectedTypes => _selectedTypes;

  bool get preferNullable => _selectedTypes.contains(JsonSettingType.preferNullable);
  bool get useFinalForNonNullable => _selectedTypes.contains(JsonSettingType.useFinalForNonNullable);
  bool get prependConstWherePossible => _selectedTypes.contains(JsonSettingType.prependConstWherePossible);

  void _registerLanguages() {
    highlight.registerLanguage('json', json_lang.json);
    highlight.registerLanguage('dart', dart_lang.dart);
    _langRegistered = true;
    rebuild();
  }

  void onModelNameChange(String value) {}

  bool get showHighlightedText {
    return json.isNotEmpty && _error == null && _langRegistered;
  }

  String get formattedJson {
    return const JsonEncoder.withIndent(' ').convert(json);
  }

  List<List<Template>> generateTemplates() {
    final List<List<Template>> list = [];
    for (var container in _tokenContainers) {
      list.add(container.generateTemplates());
    }
    return list;
  }

  Future rebuildJson() async {
    final data = await getFormData(formName: kSettingsFormName);
    _selectedTypes = (data['jsonSettings'] as List).cast<JsonSettingType>();
    if (json.isNotEmpty) {
      _buildTreeWrapper();
    }
  }

  void _buildTreeWrapper() {
    if (_tokenContainers.isEmpty) {
      final tokenContainer = jsonToTokenContainer(
        json: json,
        rootTypeName: 'Root',
      );
      tokenContainer.isNullable = preferNullable;
      tokenContainer.useFinalForNonNullable = useFinalForNonNullable;
      tokenContainer.prependConstWherePossible = prependConstWherePossible;
      _tokenContainers.add(tokenContainer);
    } else {
      for (var container in _tokenContainers) {
        container.isNullable = preferNullable;
        container.useFinalForNonNullable = useFinalForNonNullable;
        container.prependConstWherePossible = prependConstWherePossible;
      }
    }
    rebuild();
  }

  void enterExample() {
    reset();
    onJsonEnter(_exampleJson);
  }

  Future onJsonEnter(String value) async {
    try {
      _error = null;
      json = jsonDecode(value);
      _buildTreeWrapper();
    } catch (e) {
      json = {};
      _error = 'Invalid JSON';
    }
    rebuild();
  }

  bool get hasData {
    return _tokenContainers.isNotEmpty;
  }

  @override
  void reset() {
    _error = null;
    _tokenContainers.clear();
    json.clear();
    rebuild();
  }

  @override
  void onLocalStorageInitialized() {
    _registerLanguages();
  }
}
