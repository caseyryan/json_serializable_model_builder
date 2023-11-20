// ignore_for_file: depend_on_referenced_packages, unnecessary_getters_setters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart' show highlight;
import 'package:highlight/languages/dart.dart' as dart_lang;
import 'package:highlight/languages/json.dart' as json_lang;
import 'package:json_serializable_model_builder/extensions/string_extensions.dart';
import 'package:lite_forms/controllers/lite_form_controller.dart';
import 'package:lite_forms/utils/exports.dart';
import 'package:lite_state/lite_state.dart';

part '_example_json.dart';
part '_json_serializable_template.dart';
part '_wrappers.dart';

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
  TypeWrapper? typeWrapper;
  bool _langRegistered = false;

  final List<TypeWrapper> _allTypeWrappers = [];
  final List<TypeWrapper> _filteredTypeWrappers = [];
  List<TypeWrapper> get filteredTypeWrappers => _filteredTypeWrappers;

  List<JsonSettingType> _selectedTypes = [
    JsonSettingType.mergeSimilar,
    JsonSettingType.preferNullable,
  ];

  List<JsonSettingType> get selectedTypes => _selectedTypes;

  bool get tryMergeSimilarTypes => _selectedTypes.contains(JsonSettingType.mergeSimilar);
  bool get preferNullable => _selectedTypes.contains(JsonSettingType.preferNullable);

  TypeWrapper get mergedTypeWrapper {
    return TypeWrapper(
      values: _filteredTypeWrappers,
      typeName: _modelName,
      name: _modelName.firstToLowerCase(),
    );
  }

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

  Future saveModel() async {
    final wrappers = tryMergeSimilarTypes ? _filteredTypeWrappers : _allTypeWrappers;
    for (var wrapper in wrappers) {
      final filledTemplate = jsonSerializableTemplateFromWrapper(wrapper);
      print(filledTemplate);
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
    _allTypeWrappers.clear();
    _filteredTypeWrappers.clear();
    typeWrapper = buildTypeValueTree(
      json: json,
      typeName: _modelName,
      name: _modelName.firstToLowerCase(),
    );
    _tryFindSimilarStructuresAndJoinThem();
    rebuild();
  }

  /// Sometimes the same structures are used under different key names
  /// in json. This method tries to detect such cases and to use
  /// the same class for all of them
  void _tryFindSimilarStructuresAndJoinThem() {
    if (typeWrapper?.values == null || !tryMergeSimilarTypes) {
      return;
    }
    for (var existingWrapper in _allTypeWrappers) {
      for (var currentWrapper in _allTypeWrappers) {
        if (currentWrapper.searchKey == existingWrapper.searchKey) {
          continue;
        }
        bool isSimilarToExisting = _isSimilarTypeWrappers(
          currentWrapper,
          existingWrapper,
        );
        if (isSimilarToExisting) {
          currentWrapper.typeName = existingWrapper.typeName;
        }
      }
    }

    for (var wrapper in _allTypeWrappers) {
      if (!_filteredTypeWrappers.any((e) => e.typeName == wrapper.typeName)) {
        _filteredTypeWrappers.add(wrapper);
      }
    }
    for (var wrapper in _filteredTypeWrappers) {
      wrapper.convertTypeWrappersToValueWrappers();
    }
  }

  bool _isSimilarTypeWrappers(
    TypeWrapper first,
    TypeWrapper second,
  ) {
    for (var keyName in first.keyNames) {
      if (!second.keyNames.contains(keyName)) {
        return false;
      }
    }
    return true;
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
    return typeWrapper != null;
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
    _allTypeWrappers.add(wrapper);
    for (var kv in json.entries) {
      if (kv.value is Map) {
        final tName = kv.key.firstToUpperCase();
        final typeWrapper = buildTypeValueTree(
          json: kv.value,
          typeName: tName,
          name: kv.key,
        );
        _allTypeWrappers.add(typeWrapper);
        values.add(
          typeWrapper,
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
    for (var w in _allTypeWrappers) {
      w.isNullable = preferNullable;
    }
    return wrapper;
  }

  @override
  void reset() {
    _error = null;
    _allTypeWrappers.clear();
    _filteredTypeWrappers.clear();
    json.clear();
    typeWrapper = null;
    rebuild();
  }

  @override
  void onLocalStorageInitialized() {
    _registerLanguages();
  }
}
