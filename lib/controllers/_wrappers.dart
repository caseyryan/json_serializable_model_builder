// ignore_for_file: unnecessary_getters_setters

part of 'json_tree_controller.dart';

class TypeWrapper extends Wrapper {
  /// This is necessary to find type wrappers
  /// in a common storage dynamic instead of using direct links
  /// It allows to unify types even if they are called differently
  /// in the input JSON
  String? _searchKey;
  String get searchKey {
    _searchKey ??= (typeName ?? super.keyName);
    return _searchKey!;
  }

  void convertTypeWrappersToValueWrappers() {
    final tempValues = [...values];
    for (var i = 0; i < values.length; i++) {
      final wrapper = values[i];
      if (wrapper is TypeWrapper) {
        wrapper.convertTypeWrappersToValueWrappers();
        final valueWrapper = ValueWrapper(
          keyName: wrapper.keyName,
        );
        valueWrapper.alternativeTypeName = wrapper.proposedTypeName;
        tempValues[i] = valueWrapper;
      } else {
        tempValues[i] = wrapper;
      }
    }
    values = tempValues;
  }

  List<Wrapper> values;
  String? typeName;
  TypeWrapper({
    required String name,
    required this.values,
    required this.typeName,
  }) : super(
          keyName: name,
        );

  List<String>? _keyNames;
  List<String> get keyNames {
    if (_keyNames == null) {
      _keyNames = [];
      for (var v in values) {
        _keyNames!.add(v.keyName);
      }
    }
    return _keyNames!;
  }

  @override
  set isNullable(bool value) {
    super.isNullable = value;

    for (var v in values) {
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

  Color get typeColor {
    if (isChangedManually) {
      return const Color.fromARGB(255, 24, 123, 203);
    }

    if (!canBeNullable) {
      return Colors.green;
    }
    return Colors.purple;
  }

  Object? get defaultValue {
    if (alternativeDefaultValue != null) {
      return alternativeDefaultValue!;
    }
    final typeName = proposedTypeName.replaceAll('?', '');

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
