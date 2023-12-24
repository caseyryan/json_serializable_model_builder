// ignore_for_file: depend_on_referenced_packages, unnecessary_getters_setters, avoid_print

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
  includeStaticDeserializeMethod,
  useFinalForNonNullable,
  alwaysPreferCamelCase,
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
  int _numLines = 0;
  int get numLines => _numLines;

  List<JsonSettingType> _selectedTypes = [
    JsonSettingType.preferNullable,
    JsonSettingType.useFinalForNonNullable,
    JsonSettingType.prependConstWherePossible,
    JsonSettingType.includeStaticDeserializeMethod,
    JsonSettingType.alwaysPreferCamelCase,
  ];

  final List<JsonTokenContainer> _tokenContainers = [];
  List<JsonTokenContainer> get tokenContainers {
    return _tokenContainers;
  }

  List<JsonSettingType> get selectedTypes => _selectedTypes;
  bool _highlightJson = false;
  bool get highlightJson => _highlightJson;

  bool get preferNullable => _selectedTypes.contains(JsonSettingType.preferNullable);
  bool get useFinalForNonNullable => _selectedTypes.contains(JsonSettingType.useFinalForNonNullable);
  bool get prependConstWherePossible => _selectedTypes.contains(JsonSettingType.prependConstWherePossible);
  bool get includeStaticDeserializeMethod => _selectedTypes.contains(JsonSettingType.includeStaticDeserializeMethod);
  bool get alwaysPreferCamelCase => _selectedTypes.contains(JsonSettingType.alwaysPreferCamelCase);

  void _registerLanguages() {
    highlight.registerLanguage('json', json_lang.json);
    highlight.registerLanguage('dart', dart_lang.dart);
    _langRegistered = true;
    rebuild();
  }

  void onModelNameChange(String value) {}

  bool get showHighlightedText {
    return _highlightJson && _error == null && _langRegistered;
  }

  void toggleHighlight() {
    _highlightJson = !_highlightJson;
    rebuild();
  }

  String get formattedJson {
    return const JsonEncoder.withIndent('   ').convert(json);
  }

  List<List<Template>> generateTemplates() {
    final List<List<Template>> list = [];
    for (var container in _tokenContainers) {
      list.add(container.generateTemplates());
    }
    return list;
  }

  bool get hasPastedJson {
    return jsonController.text.isNotEmpty;
  }

  void onRegenerateModelsPressed() {
    try {
      _error = null;
      final tempJson = jsonDecode(jsonController.text);
      json = tempJson;
      _tokenContainers.clear();
      rebuildJson();
    } on FormatException catch (e) {
      _error = e.toString().trim();
      rebuild();
    } catch (e) {
      _error = 'Invalid JSON';
      print(e);
    }
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
      tokenContainer.includeStaticDeserializeMethod = includeStaticDeserializeMethod;
      tokenContainer.alwaysPreferCamelCase = alwaysPreferCamelCase;
      _tokenContainers.add(tokenContainer);
    } else {
      for (var container in _tokenContainers) {
        container.isNullable = preferNullable;
        container.useFinalForNonNullable = useFinalForNonNullable;
        container.prependConstWherePossible = prependConstWherePossible;
        container.includeStaticDeserializeMethod = includeStaticDeserializeMethod;
        container.alwaysPreferCamelCase = alwaysPreferCamelCase;
      }
    }
    _numLines = jsonController.text.formatJson().numLines;
    debugPrint('NUM LINES: $numLines');
    rebuild();
  }

  void enterExample() {
    reset();
    jsonController.text = _exampleJson.formatJson();
    onChange(_exampleJson);
  }

  Future onChange(String value) async {
    try {
      _error = null;
      json = jsonDecode(value);
      _buildTreeWrapper();
    } on FormatException catch (e) {
      _error = e.toString().trim();
    } catch (e) {
      _error = 'Invalid JSON';
    }
    rebuild();
  }

  void onTokenNameChange({
    required String value,
    required JsonToken token,
  }) {
    token.setTypeName(value);
    if (!token.isPrimitiveType()) {
      for (var token in token.alterEgos) {
        token.setTypeName(value);
      }
    }
    token.saveName();
    rebuild();
  }

  void saveTokenName(JsonToken token) {
    token.saveName();
    rebuild();
  }

  bool get hasData {
    return _tokenContainers.isNotEmpty;
  }

  @override
  void reset() {
    typeNameCache.clear();
    _numLines = 1;
    _error = null;
    _tokenContainers.clear();
    json.clear();
    jsonController.clear();
    rebuild();
  }

  @override
  void onLocalStorageInitialized() {
    _registerLanguages();
  }
}
