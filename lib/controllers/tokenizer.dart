// ignore_for_file: empty_catches, use_build_context_synchronously

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/extensions/string_extensions.dart';
import 'package:json_serializable_model_builder/utils/show_cupertino_confirmation.dart';
import 'package:lite_forms/controllers/lite_form_controller.dart';
import 'package:lite_forms/utils/exports.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

import 'json_tree_controller.dart';

/// It has exists until you clear a JSON
final Map<String, String?> typeNameCache = {};

/// [rootTypeName]
/// [mergeSimilarTokens] the tool will try to find
/// different JSON tokens (classes) with similar structure
/// and merge them into one. This way the repeated structures
/// will be using the same `dart` class instead of many
/// [useDerivedTypePrompts] means that the tool will try to guess a more
/// correct type of a primitive value based on its key name
/// e.g. If it got [int] value from JSON but the key is called `price` or `balance` ...
/// then it most probably should be [double] instead etc.
JsonTokenContainer jsonToTokenContainer({
  required Map json,
  String? rootTypeName,
  bool mergeSimilarTokens = true,
  bool useDerivedTypePrompts = true,
}) {
  List<JsonToken> allTokens = [];
  final JsonToken token = _tokenize(
    input: json,
    typeName: rootTypeName ?? 'Root',
    keyName: null,
    allTokens: allTokens,
    useDerivedTypePrompts: useDerivedTypePrompts,
  ) as JsonToken;
  token._isRoot = true;

  /// root token must also be in this list
  // allTokens.insert(0, token);

  if (mergeSimilarTokens) {
    /// merging
    final similar = <String, List<JsonToken>>{};

    for (var token in allTokens) {
      if (!similar.containsKey(token._compareKey)) {
        similar[token._compareKey] = [
          token,
        ];
      } else {
        similar[token._compareKey]!.add(token);
      }
    }

    /// This logic only removes full duplicates
    /// But there also might be very similar types, e.g.
    /// the types with a complete subset of fields of other
    /// but that other type has more keys. In this case
    /// they are marked as similar
    final duplicateTypes = <JsonToken>[];
    for (var kv in similar.entries) {
      final listOfSimilar = kv.value;
      if (listOfSimilar.length > 1) {
        final tokenWithShortestName = _findTokenWithShortestName(listOfSimilar);
        for (var token in kv.value) {
          token.copyTypeInfoFrom(tokenWithShortestName);
          if (token != tokenWithShortestName) {
            duplicateTypes.add(token);
          }
        }
      }
    }
    for (var dup in duplicateTypes) {
      allTokens.remove(dup);
    }
  }

  return JsonTokenContainer(
    allTokens: allTokens,
    rootToken: token,
  );
}

JsonToken _findTokenWithShortestName(
  List<JsonToken> value,
) {
  if (value.length < 2) {
    return value.first;
  }
  JsonToken shortest = value.first;
  for (var token in value) {
    if (token.typeName.length < shortest.typeName.length) {
      shortest = token;
    }
  }

  return shortest;
}

class JsonTokenContainer {
  JsonToken rootToken;
  List<JsonToken> allTokens;
  JsonTokenContainer({
    required this.rootToken,
    required this.allTokens,
  }) {
    for (var token in allTokens) {
      token._parentContainer = this;
      token._listGenericType?._parentContainer = this;
      for (var f in token.fields) {
        f._parentContainer = this;
        f._listGenericType?._parentContainer = this;
      }
    }
  }

  bool isNullable = false;
  bool useFinalForNonNullable = false;
  bool prependConstWherePossible = false;
  bool includeStaticDeserializeMethod = false;
  bool alwaysPreferCamelCase = false;

  List<Template> generateTemplates() {
    final list = <Template>[];
    for (var token in allTokens) {
      final template = token.toTemplate();
      if (template != null) {
        list.add(template);
      }
    }

    return list;
  }
}

Object? _tokenize({
  required String typeName,
  required String? keyName,
  required List<JsonToken> allTokens,
  required bool useDerivedTypePrompts,
  Object? input,
  List<String>? path,
}) {
  if (keyName == null && input is! Map) {
    throw 'The top level of your model must me a Map';
  }
  if (keyName == null || path == null) {
    path = [];
  }

  if (input is Map) {
    final token = JsonToken.mapped()
      .._keyName = keyName
      .._useDerivedTypePrompts = useDerivedTypePrompts
      .._typeName = typeName;
    allTokens.add(token);
    for (var kv in input.entries) {
      final keyName = kv.key;
      if (kv.value == null || (kv.value is List && kv.value.isEmpty) || (kv.value is Map && kv.value.isEmpty)) {
        continue;
      }
      final innerTypeName = kv.toTypeName();
      final value = _tokenize(
        typeName: innerTypeName,
        keyName: keyName,
        input: kv.value,
        allTokens: allTokens,
        useDerivedTypePrompts: useDerivedTypePrompts,
        path: path,
      );
      token.addValue(value);
      if (value is List) {
        for (var a in value) {
          if (a is JsonToken) {
            allTokens.add(a);
            break;
          }
        }
      }
    }
    return token;
  } else if (input is List && input.isNotEmpty) {
    final newToken = JsonToken()
      .._typeName = typeName
      .._useDerivedTypePrompts = useDerivedTypePrompts
      .._keyName = null
      .._value = _tokenize(
        typeName: typeName,
        keyName: keyName,
        input: input.first,
        allTokens: allTokens,
        useDerivedTypePrompts: useDerivedTypePrompts,
        path: path,
      );
    if (!newToken.isPrimitiveValue) {
      allTokens.add(newToken);
    }

    /// We don't have to set type here
    /// because it will be derived from _listGenericType
    final listToken = JsonToken.listed()
      .._keyName = keyName
      .._listGenericType = newToken;

    listToken.asList.add(newToken);
    listToken._useDerivedTypePrompts = useDerivedTypePrompts;

    return listToken;
  } else {
    final newToken = JsonToken()
      .._keyName = keyName
      .._useDerivedTypePrompts = useDerivedTypePrompts
      .._typeName = typeName
      .._value = input;
    if (!newToken.isPrimitiveValue) {
      allTokens.add(newToken);
    }
    return newToken;
  }
}

class JsonToken {
  static final RegExp _doubleRegexp = RegExp(
    r'^(-?)(0|([1-9][0-9]*))(\.[0-9]+)?$',
  );

  bool _isRoot = false;
  bool get isRoot => _isRoot;

  JsonTokenContainer? _parentContainer;

  /// If type is list, its generic type will be set here
  JsonToken? _listGenericType;

  List<JsonToken> _findTokensOfType(String type) {
    final temp = <JsonToken>[];
    if (_typeName == type) {
      temp.add(this);
    } else if (_value is JsonToken) {
      final token = _value as JsonToken;
      temp.addAll(token._findTokensOfType(type));
    }
    if (fields.isNotEmpty == true) {
      for (var token in fields) {
        temp.addAll(
          token._findTokensOfType(type),
        );
        if (token._listGenericType != null) {
          temp.addAll(
            token._listGenericType!._findTokensOfType(type),
          );
        }
      }
    }
    return temp;
  }

  Future onChangeNamePressed(BuildContext context) async {
    showCustomDialog(
      title: 'Change Type Name',
      cancelText: 'Cancel',
      confirmText: 'Save',
      context: context,
      confirmCondition: () async {
        final value = await form('alert.input').field.get(true);
        jsonTreeController.onTokenNameChange(
          value: value,
          token: this,
        );
        Navigator.of(context).pop();
      },
      content: AlertField(
        initialValue: typeName,
      ),
    );
  }

  List<JsonToken> get alterEgos {
    List<JsonToken> other = [];
    for (var token in _parentContainer!.allTokens) {
      if (_typeName != null) {
        other.addAll(token._findTokensOfType(_typeName!));
      }
    }
    other = other
        .where(
          (element) => element != this,
        )
        .toList();
    return other;
  }

  JsonToken();

  /// it can contain [JsonToken] values
  /// or Lists
  List<Object>? _keyValues;

  /// The name of the type that was derived from
  /// the JSON key or a value. It the default value
  /// which can be changed later
  String? _typeName;
  String? _keyName;
  String? get keyName {
    if (_parentContainer?.alwaysPreferCamelCase == true && _keyName?.isSnakeCase == true) {
      return _keyName!.snakeToCamel();
    }
    return _keyName;
  }

  String getJsonKey() {
    if (_parentContainer?.alwaysPreferCamelCase == true) {
      if (_keyName?.isSnakeCase == true) {
        return "@JsonKey(name: '$_keyName')";
      }
    }
    return '';
  }

  Object? _value;
  bool _useDerivedTypePrompts = true;
  String? _autoCorrectedType;
  String? _manualType;
  Object? _manualDefaultValue;

  bool get isComplexType {
    return _keyValues != null;
  }

  void saveName() {
    if (_manualType?.isEmpty == true || _manualType?.startsWith(RegExp(r'[0-9]+')) == true) {
      _manualType = null;
    }

    _manualType = _manualType?.replaceAll(RegExp(r'[,.^;*!%# ]+'), '');
    if (_typeName?.isNotEmpty == true) {
      if (!isPrimitiveType()) {
        typeNameCache[_typeName!] = _manualType;
      } else {
        typeNameCache['$_typeName$keyName'] = _manualType;
      }
    }
    if (!isPrimitiveType()) {
      for (var token in alterEgos) {
        token.setTypeName(_manualType);
      }
    }
  }

  factory JsonToken.mapped() {
    return JsonToken().._keyValues = [];
  }

  void addValue(Object? value) {
    if (isComplexType && value != null) {
      _keyValues!.add(value);
    }
  }

  factory JsonToken.listed() {
    return JsonToken().._value = [];
  }

  @override
  String toString() {
    return '[JsonToken: $typeName]';
  }

  List get asList {
    if (!isListToken) {
      return const [];
    }
    return (_value! as List).whereType<JsonToken>().toList();
  }

  bool get isListToken {
    return _value is List;
  }

  String? __compareKey;

  void copyTypeInfoFrom(JsonToken other) {
    _typeName = other._typeName;
    _autoCorrectedType = other._autoCorrectedType;
    _manualType = other._manualType;
  }

  String get _compareKey {
    if (isComplexType) {
      if (__compareKey == null) {
        final sortedKeys = _keyValues!.map((e) => (e as JsonToken)._keyName).toList()..sort();
        __compareKey = sortedKeys.join();
      }
    } else if (_value is JsonToken) {
      return (_value as JsonToken)._compareKey;
    }
    // if (__compareKey == null) {
    //   print(_value);
    // }
    return __compareKey!;
  }

  void setTypeName(String? value) {
    if (_listGenericType is JsonToken) {
      if (value?.contains('<') == true && value?.contains('>') == true) {
        /// случай переименования типа в дженерик листе
        final generic = value!.extractListType();
        _listGenericType?.setTypeName(generic);
      }
      return;
    }
    _manualType = value;
  }

  void setDefaultValue(String value) {
    _manualDefaultValue = value;
  }

  bool get _isNullable {
    return _parentContainer!.isNullable;
  }

  String getDefaultValueView() {
    if (!_isNullable) {
      if (defaultValue != null && !isAlwaysNullable) {
        return ' = $defaultValue';
      }
    }
    return '';
  }

  Object? get defaultValue {
    if (_manualDefaultValue != null) {
      return _manualDefaultValue!;
    }
    if (typeName.startsWith('List<')) {
      return 'const []';
    }
    switch (typeName) {
      case 'double':
        return 0.0;
      case 'int':
        return 0;
      case 'bool':
        return true;
      case 'String':
        return "''";
    }

    return null;
  }

  List<JsonToken> get fields {
    return _keyValues?.whereType<JsonToken>().toList() ?? [];
  }

  bool get _canAddConstToClass {
    if (_parentContainer!.prependConstWherePossible && !_parentContainer!.isNullable) {
      if (_keyValues?.isNotEmpty != true || isPrimitiveValue) {
        return false;
      }
      return !fields.any((e) => e.isAlwaysNullable);
    }

    return false;
  }

  String getFullTypeName() {
    final suffix = getTypeSuffix();
    var prefix = '';
    if (_parentContainer!.useFinalForNonNullable) {
      if (suffix.isEmpty && !_isNullable) {
        prefix = 'final ';
      }
    } else {
      if (suffix.isEmpty && !_isNullable) {
        prefix = 'late ';
      }
    }
    return '$prefix$typeName$suffix';
  }

  String getClassConstructorName() {
    if (!_canAddConstToClass) {
      return typeName;
    }
    return 'const $typeName';
  }

  String get typeName {
    if (_listGenericType != null) {
      return 'List<${_listGenericType!.typeName}>';
    }
    if (!isPrimitiveType()) {
      _manualType ??= typeNameCache[_typeName];
    } else {
      _manualType ??= typeNameCache['$_typeName$keyName'];
    }

    if (_manualType != null) {
      return _manualType!;
    }
    _autoCorrectedType ??= _tryCorrectType();
    return _autoCorrectedType!;
  }

  bool get isAlwaysNullable {
    return defaultValue == null;
  }

  String getTypeSuffix() {
    if (isAlwaysNullable) {
      return '?';
    }
    return _isNullable ? '?' : '';
  }

  String get modelName {
    if (_listGenericType != null) {
      return _listGenericType!.modelName;
    }
    return typeName.camelToSnake();
  }

  String get fileName {
    return '$modelName.dart';
  }

  String get archiveName {
    return '$modelName.zip';
  }

  String get import {
    return "import '$fileName'";
  }

  List<JsonToken> get asComplexTypeList {
    if (!isComplexType) {
      return const [];
    }
    return _keyValues!.whereType<JsonToken>().toList();
  }

  List<String> _getAllImports() {
    final temp = <String>[];
    if (isComplexType) {
      final tokens = asComplexTypeList;
      for (var token in tokens) {
        if (token.isPrimitiveValue || token.typeName == typeName) {
          continue;
        }
        temp.addAll(token._getAllImports());
        temp.add(token.import);
      }
    } else if (isListToken) {
      final tokens = asList;
      for (var token in tokens) {
        if (token.isPrimitiveValue || token.typeName == typeName || token.isListToken) {
          continue;
        }
        temp.addAll(token._getAllImports());
        temp.add(token.import);
      }
    }
    return temp;
  }

  String _getStaticDeserializeContents() {
    if (!_parentContainer!.includeStaticDeserializeMethod) {
      return '';
    }
    return '''
static %CLASS_MODEL_NAME%%CLASS_SUFFIX% deserialize(Map<String, dynamic> json) {
    return %CLASS_MODEL_NAME%%CLASS_SUFFIX%.fromJson(json);
  }
''';
  }

  Template? toTemplate({
    String pathSuffix = '',
    String classSuffix = '',
  }) {
    if (isPrimitiveValue) {
      return null;
    }

    if (isComplexType) {
      String temp = _jsonSerializableTemplate;
      final params = <String>[];
      final fields = <String>[];
      final imports = HashSet<String>();
      var explicitToJson = true;

      final tokenList = _keyValues!.cast<JsonToken>();
      for (var token in tokenList) {
        final initialKeyName = token.keyName;
        String? typeName;
        String valueView = '';

        typeName = token.getFullTypeName();
        valueView = token.getDefaultValueView();
        // }

        if (valueView.isNotEmpty) {
          params.insert(0, '    this.$initialKeyName$valueView,');
        } else {
          params.add('    this.$initialKeyName$valueView,');
        }
        final fieldBuffer = StringBuffer();
        final jsonKeyAnnotation = token.getJsonKey();
        if (jsonKeyAnnotation.isNotEmpty) {
          fieldBuffer.writeln('  $jsonKeyAnnotation');
        }
        fieldBuffer.write('  $typeName $initialKeyName;');

        fields.add(fieldBuffer.toString());
      }
      if (!_parentContainer!.alwaysPreferCamelCase) {
        fields.sort(((a, b) {
          final aFinal = a.contains('final ');
          final bFinal = b.contains('final ');
          if (aFinal && bFinal) {
            return 0;
          }
          if (aFinal) {
            return -1;
          }
          return 1;
        }));
      }

      imports.addAll(_getAllImports());
      String importsView = imports.join(';\n');
      if (importsView.isNotEmpty) {
        importsView = '$importsView;';
      }

      temp = temp.replaceAll('%STATIC_DESERIALIZE%', _getStaticDeserializeContents());

      temp = temp.replaceAll('%OTHER_IMPORTS%', importsView);
      temp = temp.replaceAll('%PARAMS%', params.join('\n'));
      temp = temp.replaceAll('%FIELDS%', fields.join('\n'));
      temp = temp.replaceAll('%PATH_MODEL_NAME%', modelName);
      temp = temp.replaceAll('%PATH_SUFFIX%', pathSuffix);
      temp = temp.replaceAll('%CLASS_MODEL_NAME%', typeName);
      temp = temp.replaceAll('%CLASS_CONSTRUCTOR_NAME%', getClassConstructorName());
      temp = temp.replaceAll('%CLASS_SUFFIX%', classSuffix);
      temp = temp.replaceAll('%EXPLICIT_TO_JSON%', '$explicitToJson');

      return Template(
        fileName: fileName,
        typeName: typeName,
        content: temp,
        isRoot: isRoot,
        archiveName: archiveName,
      );
    }

    return null;
  }

  /// Balances or prices most probably must be doubles event they come as
  /// `int` in a json
  bool get _doubleMightBeUseful {
    if (_value is! num) {
      return false;
    }
    if (_keyName == null || !isPrimitiveValue || !_useDerivedTypePrompts) {
      return false;
    }
    final lowerName = _keyName!.toLowerCase();
    if (lowerName == 'id' || _keyName!.endsWith('Id') || _keyName!.endsWith('ID')) {
      return false;
    }
    return (lowerName.contains('balance') ||
        lowerName.contains('price') ||
        lowerName.contains('fee') ||
        lowerName.contains('commission') ||
        lowerName.contains('payment') ||
        lowerName.contains('pay') ||
        lowerName.contains('amount'));
  }

  bool get _dateTimeMightBeUseful {
    if (_keyName == null || _value is! String || !_useDerivedTypePrompts) {
      return false;
    }
    try {
      final date = DateTime.parse(_value?.toString() ?? '');
      if (kDebugMode) {
        print('DATE: $date');
      }
    } catch (e) {
      return false;
    }
    final lowerName = _keyName!.toLowerCase();
    return lowerName.contains('createdAt') ||
        lowerName.contains('updatedAt') ||
        lowerName.contains('date') ||
        lowerName.contains('time');
  }

  String _tryCorrectType() {
    if (_value is List) {
      final list = _value as List;
      if (list.isEmpty) {
        return 'List<dynamic>';
      } else {
        final tempType = list.first._typeName;
        return 'List<$tempType>';
      }
    }
    if (_value is String) {
      String v = _value as String;
      if (v.contains('.')) {
        if (_doubleRegexp.hasMatch(v)) {
          return 'double';
        }
      }
      if (int.tryParse(v) != null) {
        return 'int';
      }
      if (DateTime.tryParse(v) != null || _dateTimeMightBeUseful) {
        return 'DateTime';
      }
      if (v.toLowerCase() == 'true' || v.toLowerCase() == 'false') {
        return 'bool';
      }
    }
    if (_isDouble(_value) || _doubleMightBeUseful) {
      return 'double';
    } else if (_isInt(_value)) {
      return 'int';
    }

    if (_value is bool) {
      return 'bool';
    }
    return _typeName!;
  }

  bool get isPrimitiveValue {
    return _value?.isPrimitiveType() == true && !isComplexType;
  }

  bool _isDouble(Object? value) {
    if (kIsWeb) {
      /// on web a value is always double
      if (value is double) {
        if (!value.toString().contains('.')) {
          return false;
        }
        return true;
      }
    }
    return _value is double;
  }

  bool _isInt(Object? value) {
    if (kIsWeb) {
      /// on web a value is always double
      if (value is num) {
        if (!value.toString().contains('.')) {
          return true;
        }
        return false;
      }
    }
    return _value is int;
  }
}



extension ObjectExtension on Object {
  bool isPrimitiveType() {
    if (this is JsonToken) {
      return (this as JsonToken)._value?.isPrimitiveType() == true;
    }
    switch (runtimeType) {
      case int:
      case double:
      case num:
      case bool:
      case String:
        return true;
    }
    return false;
  }

  bool get isBuiltInType {
    return isPrimitiveType() || runtimeType == DateTime;
  }
}

class Template {
  final String fileName;
  final String archiveName;
  final String typeName;
  final String content;
  final bool isRoot;
  Template({
    required this.fileName,
    required this.archiveName,
    required this.typeName,
    required this.content,
    required this.isRoot,
  });

  @override
  bool operator ==(covariant Template other) {
    return other.fileName == fileName;
  }

  @override
  int get hashCode {
    return fileName.hashCode;
  }
}

extension MapEntryExtension on MapEntry {
  String toTypeName() {
    if ((value as Object).isPrimitiveType()) {
      return value.runtimeType.toString();
    }
    if (value is List && value.isNotEmpty) {
      if ((value.first as Object).isPrimitiveType()) {
        return (value.first as Object).runtimeType.toString();
      }
    }
    return key.toString()._toCamelCase().toSingular().firstToUpperCase();
  }
}


extension StringExtension on String {
  String toSingular() {
    if (endsWith('s') || endsWith('S')) {
      return substring(0, length - 1);
    }
    return this;
  }

   String _toCamelCase([
    bool firstToUpper = true,
  ]) {
    if (isEmpty) return this;
    if (contains('_')) {
      final result = split('_').map((e) => e._toCamelCase()).join();
      return result;
    }
    final replaced = replaceAll(RegExp(r'[^A-Za-z ]+'), '');
    if (firstToUpper) {
      return replaced.firstToUpperCase();
    }
    return replaced;
  }

  String extractListType() {
    if (contains('List<') && contains('>')) {
      final match = RegExp(r'(?<=List<)[A-Za-z0-9_]+(?=>)').firstMatch(this);
      if (match == null) {
        return this;
      }
      return substring(match.start, match.end);
    }
    return this;
  }

  int get numLines {
    return RegExp(r'\n+').allMatches(this).length + 1;
  }

  String formatJson() {
    try {
      final map = jsonDecode(this);
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (e) {}
    return this;
  }

  Future copyToClipboard() async {
    await RichClipboard.setData(RichClipboardData(
      text: this,
    ));
  }

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(this),
      ),
    );
  }
}

const _jsonSerializableTemplate = r'''
// ignore_for_file: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
%OTHER_IMPORTS%

part '%PATH_MODEL_NAME%%PATH_SUFFIX%.g.dart';

@JsonSerializable(explicitToJson: %EXPLICIT_TO_JSON%)
class %CLASS_MODEL_NAME%%CLASS_SUFFIX% {
  %CLASS_CONSTRUCTOR_NAME%%CLASS_SUFFIX%({
%PARAMS%
  });

%FIELDS%

  %STATIC_DESERIALIZE%
  factory %CLASS_MODEL_NAME%%CLASS_SUFFIX%.fromJson(Map<String, dynamic> json) {
      return _$%CLASS_MODEL_NAME%%CLASS_SUFFIX%FromJson(json);
    }
  
  Map<String, dynamic> toJson() {
    return _$%CLASS_MODEL_NAME%%CLASS_SUFFIX%ToJson(this);
  }
}
''';

/// JsonKey values
// final Object? defaultValue;
// final bool? disallowNullValue;
// final Function? fromJson;
// final bool? includeFromJson;
// final bool? includeIfNull;
// final bool? includeToJson;
// final String? name;
// final Object? Function(Map, String)? readValue;
// final bool? required;
// final Function? toJson;
// final Enum? unknownEnumValue;
