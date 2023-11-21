// ignore_for_file: depend_on_referenced_packages, unnecessary_getters_setters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart' show highlight;
import 'package:highlight/languages/dart.dart' as dart_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import 'package:json_serializable_model_builder/controllers/_json_token_tools.dart';
import 'package:lite_forms/controllers/lite_form_controller.dart';
import 'package:lite_state/lite_state.dart';

part '_example_json.dart';

enum JsonSettingType {
  preferNullable,
  mergeSimilar,
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
  JsonTokenContainer? _tokenContainer;
  bool _langRegistered = false;

  List<JsonSettingType> _selectedTypes = [
    JsonSettingType.mergeSimilar,
    JsonSettingType.preferNullable,
  ];

  List<JsonSettingType> get selectedTypes => _selectedTypes;

  bool get mergeSimilarTypes =>
      _selectedTypes.contains(JsonSettingType.mergeSimilar);
  bool get preferNullable =>
      _selectedTypes.contains(JsonSettingType.preferNullable);

  void _registerLanguages() {
    highlight.registerLanguage('json', json_lang.json);
    highlight.registerLanguage('dart', dart_lang.dart);
    _langRegistered = true;
    rebuild();
  }

  String _rootModelName = 'Root';

  void onModelNameChange(String value) {
    _rootModelName = value;
  }

  bool get showHighlightedText {
    return json.isNotEmpty && _error == null && _langRegistered;
  }

  String get formattedJson {
    return const JsonEncoder.withIndent(' ').convert(json);
  }

  Future saveModel() async {
    print('SAVE');
  }

  Future rebuildJson() async {
    final data = await getFormData(formName: kSettingsFormName);
    _selectedTypes = (data['jsonSettings'] as List).cast<JsonSettingType>();
    if (json.isNotEmpty) {
      _buildTreeWrapper();
    }
  }

  void _buildTreeWrapper() {
    _tokenContainer = jsonToTokenContainer(
      json: json,
      rootTypeName: _rootModelName,
      mergeSimilarTokens: mergeSimilarTypes,
    );
    final templates = _tokenContainer!.toTemplates(
      nullable: preferNullable,
    );
    print(templates);
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
    return _tokenContainer != null;
  }

  @override
  void reset() {
    _error = null;
    _tokenContainer = null;
    json.clear();
    rebuild();
  }

  @override
  void onLocalStorageInitialized() {
    _registerLanguages();
  }
}
