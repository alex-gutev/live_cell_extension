import 'dart:collection';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/visitor2.dart';

/// Visits a class and extracts information about its properties
class ClassPropVisitor extends SimpleElementVisitor2<void> {
  /// If true only publicly accessible properties are included in [fields].
  final bool publicOnly;

  /// If true only properties without a setter are included in [fields].
  final bool immutableOnly;

  /// If true synthetic properties are included in [fields].
  final bool includeSynthetic;

  /// The properties of the class which can be accessed
  UnmodifiableListView<FieldElement2> get fields =>
      UnmodifiableListView(_fields);

  /// The properties of the class which can be initialized in the constructor
  UnmodifiableListView<FieldElement2> get mutableFields =>
      UnmodifiableListView(_mutableFields);

  /// The constructor to use when creating an instance of the class
  ConstructorElement2? get constructor => _constructor;

  final List<FieldElement2> _fields = [];
  final List<FieldElement2> _mutableFields =[];

  ConstructorElement2? _constructor;

  ClassPropVisitor({
    this.publicOnly = true,
    this.immutableOnly = true,
    this.includeSynthetic = true
  });

  @override
  void visitConstructorElement(ConstructorElement2 element) {
    if (element.name3 == 'new') {
      _constructor = element;

      for (final param in element.formalParameters) {
        _addConstructorParam(param);
      }
    }
  }

  /// Add the fields associated with a constructor parameter
  void _addConstructorParam(FormalParameterElement param) {
    if (param.isInitializingFormal && param is FieldFormalParameterElement2) {
      if (param.field2 != null) {
        _mutableFields.add(param.field2!);
      }
    }
    else if (param.isSuperFormal && param is SuperFormalParameterElement2) {
      if (param.superConstructorParameter2 != null) {
        _addConstructorParam(param.superConstructorParameter2!);
      }
    }
  }

  @override
  void visitFieldElement(FieldElement2 element) {
    if ((!publicOnly || element.isPublic) &&
        (!immutableOnly || element.setter2 == null) &&
        (includeSynthetic || !element.isSynthetic)
        && !element.isStatic) {
      _fields.add(element);
    }
  }
}