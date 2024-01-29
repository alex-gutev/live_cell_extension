import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';

/// Generates extensions on [ValueCell] for classes annotated with [CellExtension].
class CellExtensionGenerator extends GeneratorForAnnotation<CellExtension> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = ClassPropVisitor();
    element.visitChildren(visitor);
    
    final buffer = StringBuffer();
    buffer.write(_generateCellExtension(visitor));

    if (annotation.read('mutable').boolValue) {
      buffer.write(_generateMutableCellExtension(visitor));
    }

    return buffer.toString();
  }

  /// Generate a [ValueCell] extension for a class visited by [visitor].
  String _generateCellExtension(ClassPropVisitor visitor) {
    final className = visitor.className;
    final buffer = StringBuffer();

    buffer.writeln('// Extends ValueCell with accessors for $className properties');
    buffer.writeln('extension ${className}CellExtension on ValueCell<$className> {');

    for (final field in visitor.fields.entries) {
      buffer.writeln(_generateCellAccessor(field.key, field.value.toString()));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate an accessor for the [name] property which returns a [ValueCell] holding a [type].
  String _generateCellAccessor(String name, String type) {
    return 'ValueCell<$type> get $name => apply((value) => value.$name);';
  }

  /// Generate a [MutableCell] extension for a class visited by [visitor].
  String _generateMutableCellExtension(ClassPropVisitor visitor) {
    final className = visitor.className;

    final buffer = StringBuffer();

    buffer.writeln('// Extends MutableCell with accessors for $className properties');
    buffer.writeln('extension ${className}MutableCellExtension on MutableCell<$className> {');

    buffer.write(_generateCopyWithMethod(visitor));

    for (final field in visitor.fields.entries) {
      buffer.writeln(_generateMutableAccessor(field.key, field.value.toString()));
    }

    buffer.writeln('}');

    return buffer.toString();
  }


  /// Generate an accessor for the [name] property which returns a [MutableCell] holding a [type].
  String _generateMutableAccessor(String name, String type) {
    return 'MutableCell<$type> get $name => [this].mutableComputeCell(() => value.$name,'
        '(p) { value = _copyWith(value, $name: p); });';
  }

  /// Generate a _copyWith static method for the class visited by [visitor].
  String _generateCopyWithMethod(ClassPropVisitor visitor) {
    final className = visitor.className;
    final buffer = StringBuffer();

    buffer.writeln('static $className _copyWith($className instance, {');

    for (final entry in visitor.fields.entries) {
      final type = entry.value.toString().replaceAll('?', '');
      final name = entry.key;

      buffer.writeln('$type? $name,');
    }

    buffer.writeln('}) {');
    buffer.writeln('return $className(');

    for (final name in visitor.fields.keys) {
      buffer.writeln('$name: $name ?? instance.$name,');
    }

    buffer.writeln(');');
    buffer.writeln('}');

    return buffer.toString();
  }
}