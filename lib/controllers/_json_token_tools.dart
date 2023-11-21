import 'package:json_serializable_model_builder/extensions/string_extensions.dart';
import 'package:lite_forms/utils/exports.dart';

/// [rootTypeName]
/// [mergeSimilarTokens] the tool will try to find
/// different JSON tokens (classes) with similar structure
/// and merge them into one. This way the repeated structures
/// will be using the same `dart` class instead of many
JsonTokenContainer jsonToTokenContainer({
  required Map json,
  String? rootTypeName,
  bool mergeSimilarTokens = true,
}) {
  List<JsonToken> allTokens = [];
  final JsonToken token = _tokenize(
    value: json,
    typeName: rootTypeName ?? 'Root',
    keyName: null,
    allTokens: allTokens,
  ) as JsonToken;

  /// root token must also be in this list
  allTokens.insert(0, token);

  if (mergeSimilarTokens) {
    /// merging
    final temp = <JsonToken>[];
    for (var currentToken in allTokens) {
      if (!temp.any((t) => t._compareKey == currentToken._compareKey)) {
        temp.add(currentToken);
      }
    }
    allTokens = temp;
  }

  return JsonTokenContainer(
    allTokens: allTokens,
    rootToken: token,
  );
}

class JsonTokenContainer {
  JsonToken rootToken;
  List<JsonToken> allTokens;
  JsonTokenContainer({
    required this.rootToken,
    required this.allTokens,
  });

  List<Template> toTemplates({
    bool nullable = true,
  }) {
    final list = <Template>[];
    for (var token in allTokens) {
      final template = token.toTemplate(
        nullable: nullable,
      );
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
  Object? value,
  List<String>? path,
}) {
  if (keyName == null && value is! Map) {
    throw 'The top level of your model must me a Map';
  }
  if (keyName == null || path == null) {
    path = [];
  }
  // if (keyName != null) {
  //   path.add(keyName);
  // }

  if (value is Map) {
    final token = JsonToken()
      .._keyName = keyName
      .._typeName = typeName
      .._path = path.join(' -> ')
      .._value = {};
    for (var kv in value.entries) {
      final keyName = kv.key;
      final innerTypeName = kv.toTypeName();
      final value = _tokenize(
        typeName: innerTypeName,
        keyName: keyName,
        value: kv.value,
        allTokens: allTokens,
        path: path,
      );
      (token._value as Map)[keyName] = value;
      if (value is List) {
        for (var a in value) {
          if (a is JsonToken) {
            allTokens.add(a);
            break;
          }
        }
      } else if (value is JsonToken) {
        allTokens.add(value);
      }
    }
    return token;
  } else if (value is List && value.isNotEmpty) {
    final newToken = JsonToken()
      .._typeName = typeName
      .._keyName = null
      .._path = path.join(' -> ')
      .._value = _tokenize(
        typeName: typeName,
        keyName: keyName,
        value: value.first,
        allTokens: allTokens,
        path: path,
      );
    if (!newToken.isPrimitiveValue) {
      allTokens.add(newToken);
    }
    return [newToken];
  } else {
    final newToken = JsonToken()
      .._keyName = keyName
      .._typeName = typeName
      .._path = path.join(' -> ')
      .._value = value;
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

  /// The name of the type that was derived from
  /// the JSON key or a value. It the default value
  /// which can be changed later
  String? _typeName;
  String? _keyName;
  Object? _value;

  String? __compareKey;

  String? get _compareKey {
    if (_value is Map) {
      __compareKey ??= (_value as Map).keys.join();
    } else if (_value is JsonToken) {
      return (_value as JsonToken)._compareKey;
    }
    return __compareKey;
  }

  String? _autoCorrectedType;
  String? _manualType;
  Object? _manualDefaultValue;
  String? _path;

  bool _isTypeSetManually = false;
  bool get isTypeSetManually => _isTypeSetManually;

  void setTypeName(String value) {
    _manualType = value;
  }

  void setDefaultValue(String value) {
    _manualDefaultValue = value;
  }

  String get defaultValueView {
    if (defaultValue != null && !isAlwaysNullable) {
      return ' = $defaultValue';
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

  String getFullTypeName(bool nullable) {
    return '${typeName}${_getTypeSuffix(nullable)}';
  }

  String get typeName {
    if (_manualType != null) {
      return _manualType!;
    }
    if (_autoCorrectedType == null) {
      _autoCorrectedType = _tryCorrectType();
    }
    return _autoCorrectedType!;
  }

  bool get isAlwaysNullable {
    return defaultValue == null;
  }

  String _getTypeSuffix(bool nullable) {
    if (isAlwaysNullable) {
      return '?';
    }
    return nullable ? '?' : '';
  }

  Template? toTemplate({
    required bool nullable,
    String pathSuffix = '',
    String classSuffix = '',
  }) {
    if (_value is List) {
      final list = _value as List;
      if (list.isNotEmpty && list.first is JsonToken) {
        return (list.first as JsonToken).toTemplate(
          nullable: nullable,
        );
      }
    } else if (_value is JsonToken) {
      return (_value as JsonToken).toTemplate(nullable: nullable);
    } else if (_value is Map) {
      final suffix = nullable ? '?' : '';
      final map = _value as Map;
      String temp = _jsonSerializableTemplate;
      final params = <String>[];
      final fields = <String>[];
      final imports = <String>[];
      var explicitToJson = true;
      for (var kv in map.entries) {
        final keyName = kv.key;
        String? typeName;
        String valueView = '';
        if (kv.value is JsonToken) {
          final token = kv.value as JsonToken;

          typeName = token.getFullTypeName(nullable);
          valueView = token.defaultValueView;
        } else if (kv.value is List) {
          final list = kv.value as List;
          if (list.isEmpty) {
            typeName = 'List<dynamic>$suffix';
          } else {
            final token = (list.first as JsonToken);
            typeName =
                'List<${token.typeName}>${token._getTypeSuffix(nullable)}';
            valueView = token.defaultValueView;
          }
        }
        if (valueView.isNotEmpty) {
          params.insert(0, '    this.$keyName$valueView,');
        } else {
          params.add('    this.$keyName$valueView,');
        }
        if (nullable || typeName!.endsWith('?')) {
          fields.add('  $typeName $keyName;');
        } else {
          fields.add('  final $typeName $keyName;');
        }
      }
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

      final modelName = typeName.camelToSnake();
      final fileName = '$modelName.dart';
      imports.add("import '$fileName'");

      temp = temp.replaceAll('%OTHER_IMPORTS%', imports.join('\n'));
      temp = temp.replaceAll('%PARAMS%', params.join('\n'));
      temp = temp.replaceAll('%FIELDS%', fields.join('\n'));
      temp = temp.replaceAll('%PATH_MODEL_NAME%', modelName);
      temp = temp.replaceAll('%PATH_SUFFIX%', pathSuffix);
      temp = temp.replaceAll('%CLASS_MODEL_NAME%', typeName);
      temp = temp.replaceAll('%CLASS_SUFFIX%', classSuffix);
      temp = temp.replaceAll('%EXPLICIT_TO_JSON%', '$explicitToJson');

      return Template(
        fileName: fileName,
        typeName: typeName,
        content: temp,
      );
    }
    return null;
  }

  /// Balances or prices most probably must be doubles event they come as
  /// `int` in a json
  bool get _doubleMightBeUseful {
    if (_keyName == null) {
      return false;
    }
    final lowerName = _keyName!.toLowerCase();
    return (lowerName.contains('balance') ||
        lowerName.contains('price') ||
        lowerName.contains('fee') ||
        lowerName.contains('commission') ||
        lowerName.contains('payment') ||
        lowerName.contains('pay') ||
        lowerName.contains('amount'));
  }

  bool get _dateTimeMightBeUseful {
    if (_keyName == null) {
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
    if (_value is double || _doubleMightBeUseful) {
      return 'double';
    } else if (_value is int) {
      return 'int';
    }

    if (_value is bool) {
      return 'bool';
    }
    return _typeName!;
  }

  bool get isPrimitiveValue {
    return _value?.isPrimitiveType() == true;
  }
}

extension ObjectExtension on Object {
  bool isPrimitiveType() {
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

  bool isBuiltInType() {
    return isPrimitiveType() || this is DateTime;
  }
}

class Template {
  String fileName;
  String typeName;
  String content;
  Template({
    required this.fileName,
    required this.typeName,
    required this.content,
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
    return key.toString().toSingular().firstToUpperCase();
  }
}

extension StringExtension on String {
  String toSingular() {
    if (endsWith('s') || endsWith('S')) {
      return substring(0, length - 1);
    }
    return this;
  }
}

const _jsonSerializableTemplate = r'''
import 'package:json_annotation/json_annotation.dart';
%OTHER_IMPORTS%

part '%PATH_MODEL_NAME%%PATH_SUFFIX%.g.dart';

@JsonSerializable(explicitToJson: %EXPLICIT_TO_JSON%)
class %CLASS_MODEL_NAME%%CLASS_SUFFIX% {
  %CLASS_MODEL_NAME%%CLASS_SUFFIX%({
%PARAMS%
  });

%FIELDS%

  static %CLASS_MODEL_NAME%%CLASS_SUFFIX% deserialize(Map<String, dynamic> json) {
    return %CLASS_MODEL_NAME%%CLASS_SUFFIX%.fromJson(json);
  }

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