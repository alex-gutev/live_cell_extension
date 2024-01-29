import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

/// Visits a class and extracts information about its properties
class ClassPropVisitor extends SimpleElementVisitor<void> {
  /// The name of the class
  String get className => _className;

  /// The properties of the class mapped to their corresponding types
  Map<String, dynamic> get fields => _fields;

  var _className = '';
  Map<String, dynamic> _fields = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final returnType = element.returnType.toString();
    _className = returnType.replaceAll("*", ""); // ClassName* -> ClassName
  }

  @override
  void visitFieldElement(FieldElement element) {
    final elementType = element.type.toString().replaceAll("*", "");
    _fields[element.name] = elementType;
  }
}