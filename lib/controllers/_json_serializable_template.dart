part of 'json_tree_controller.dart';

String jsonSerializableTemplateFromWrapper(
  TypeWrapper value,
) {
  String temp = _jsonSerializableTemplate;
  var params = <String>[];
  var fields = <String>[];
  var imports = <String>[];
  var pathSuffix = '';
  var classSuffix = '';
  var explicitToJson = true;
  for (Wrapper wrapper in value.values) {
    if (wrapper.isNullable) {
      fields.add(
        '  ${wrapper.proposedTypeName} ${wrapper.proposedKeyName};',
      );
      params.add(
        '    this.${wrapper.proposedKeyName},',
      );
    } else {
      fields.add(
        '  final ${wrapper.proposedTypeName} ${wrapper.proposedKeyName};',
      );
      params.add(
        '    this.${wrapper.proposedKeyName} = ${wrapper.defaultValue},',
      );
    }
  }
  final typeName = value.proposedTypeName.replaceAll('?', '');
  final fileName = typeName.camelToSnake();
  temp = temp.replaceAll('%PARAMS%', params.join('\n'));
  temp = temp.replaceAll('%FIELDS%', fields.join('\n'));
  temp = temp.replaceAll('%PATH_MODEL_NAME%', fileName);
  temp = temp.replaceAll('%PATH_SUFFIX%', pathSuffix);
  temp = temp.replaceAll('%CLASS_MODEL_NAME%', typeName);
  temp = temp.replaceAll('%CLASS_SUFFIX%', classSuffix);
  temp = temp.replaceAll('%EXPLICIT_TO_JSON%', '$explicitToJson');

  return temp;
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
