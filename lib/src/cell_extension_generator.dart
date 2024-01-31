import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';

/// Generates extensions on [ValueCell] for classes annotated with [CellExtension].
class CellExtensionGenerator extends GeneratorForAnnotation<CellExtension> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The CellExtension annotation is only applicable to classes.',
        todo: 'Remove the CellExtension annotation',
        element: element
      );
    }

    final visitor = ClassPropVisitor();
    element.visitChildren(visitor);

    if (visitor.fields.isEmpty) {
      throw InvalidGenerationSource(
          'No public final properties found on class ${element.name}.',
          todo: 'Make the properties of class ${element.name} or remove the CellExtension annotation.',
          element: element
      );
    }

    final buffer = StringBuffer();
    buffer.write(_generateCellExtension(element.name, visitor));

    if (annotation.read('mutable').boolValue) {
      if (visitor.mutableFields.isEmpty) {
        throw InvalidGenerationSource(
            'The constructor of class ${element.name} does not have any field formal parameters.',
            todo: 'Add field parameters to the constructor of ${element.name} or '
                'remove `mutable: true` from the CellExtension annotation.',
            element: element
        );
      }

      buffer.write(_generateMutableCellExtension(element.name, visitor));
    }

    return buffer.toString();
  }

  /// Generate a [ValueCell] extension for a class visited by [visitor].
  String _generateCellExtension(String className, ClassPropVisitor visitor) {
    final buffer = StringBuffer();

    buffer.writeln('// Extends ValueCell with accessors for $className properties');
    buffer.writeln('extension ${className}CellExtension on ValueCell<$className> {');

    for (final field in visitor.fields) {
      buffer.writeln(_generateCellAccessor(field));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate an accessor for a class property which returns a [ValueCell] holding a [type].
  String _generateCellAccessor(FieldElement field) {
    final name = field.name;
    final type = field.type.toString();

    return 'ValueCell<$type> get $name => apply((value) => value.$name);';
  }

  /// Generate a [MutableCell] extension for a class visited by [visitor].
  String _generateMutableCellExtension(String className, ClassPropVisitor visitor) {
    final buffer = StringBuffer();

    buffer.writeln('// Extends MutableCell with accessors for $className properties');
    buffer.writeln('extension ${className}MutableCellExtension on MutableCell<$className> {');

    buffer.write(_generateCopyWithMethod(className, visitor));

    for (final field in visitor.mutableFields) {
      buffer.writeln(_generateMutableAccessor(field));
    }

    buffer.writeln('}');

    return buffer.toString();
  }


  /// Generate an accessor for a class property which returns a [MutableCell] holding a [type].
  String _generateMutableAccessor(FieldElement field) {
    final name = field.name;
    final type = field.type.toString();

    return 'MutableCell<$type> get $name => [this].mutableComputeCell(() => value.$name,'
        '(p) { value = _copyWith(value, $name: p); });';
  }

  /// Generate a _copyWith static method for the class visited by [visitor].
  String _generateCopyWithMethod(String className, ClassPropVisitor visitor) {
    final buffer = StringBuffer();
    buffer.writeln('static $className _copyWith($className instance, {');

    for (final field in visitor.mutableFields) {
      final type = field.type.toString();
      final suffix = field.type.nullabilitySuffix == NullabilitySuffix.none
          ? '?'
          : '';

      final name = field.name;

      buffer.writeln('$type$suffix $name,');
    }

    buffer.writeln('}) {');
    buffer.writeln('return $className(');

    for (final param in visitor.constructor!.parameters) {
      if (param.isInitializingFormal && param is FieldFormalParameterElement) {
        final field = param.field!;
        final name = field.name;

        if (param.isNamed) {
          buffer.write('$name: ');
        }

        buffer.writeln('$name ?? instance.$name,');
      }
    }

    buffer.writeln(');');
    buffer.writeln('}');

    return buffer.toString();
  }
}