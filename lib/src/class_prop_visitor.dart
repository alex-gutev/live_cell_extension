import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

/// Visits a class and extracts information about its properties
class ClassPropVisitor extends SimpleElementVisitor<void> {
  /// The properties of the class which can be accessed
  UnmodifiableListView<FieldElement> get fields =>
      UnmodifiableListView(_fields);

  /// The properties of the class which can be initialized in the constructor
  UnmodifiableListView<FieldElement> get mutableFields =>
      UnmodifiableListView(_mutableFields);

  /// The constructor to use when creating an instance of the class
  ConstructorElement? get constructor => _constructor;

  final List<FieldElement> _fields = [];
  final List<FieldElement> _mutableFields =[];

  ConstructorElement? _constructor;

  @override
  void visitConstructorElement(ConstructorElement element) {
    if (element.name.isEmpty) {
      _constructor = element;

      for (final param in element.parameters) {
        if (param.isInitializingFormal && param is FieldFormalParameterElement) {
          if (param.field != null) {
            _mutableFields.add(param.field!);
          }
        }
      }
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    if (element.isPublic && element.setter == null) {
      _fields.add(element);
    }
  }
}