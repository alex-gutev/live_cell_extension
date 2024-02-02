import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';

/// Generates extensions on [ValueCell] for classes annotated with [CellExtension].
class CellExtensionGenerator extends GeneratorForAnnotation<CellExtension> {
  /// Set of identifiers which are reserved for ValueCell properties
  static const reservedFieldNames = {
    // ValueCell
    'value',
    'call',
    'eq',
    'neq',
    'addObserver',
    'removeObserver',

    // CellListenableExtension
    'listenable'

    // ComputeExtension
    'apply',

    // ErrorCellExtension
    'error',
    'onError',

    // MaybeCellExtension
    'unwrap',

    // PrevValueCellExtension
    'previous',

    // StoreCellExtension
    'store',

    // WidgetExtension
    'toWidget'
  };

  /// Set of identifiers which are reserved for MutableCell properties
  static const reservedMutableFieldNames = {
    // MutableCell
    'notifyUpdate',
    'notifyWillUpdate',

    // CellMaybeExtension
    'maybe',
  };

  /// Set of identifiers which are reserved for both ValueCell and MutableCell properties
  static final allReservedFieldNames =
      reservedFieldNames.union(reservedMutableFieldNames);

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

    final fields = _filterReservedFields(visitor.fields);

    if (fields.isEmpty) {
      throw InvalidGenerationSource(
          'No public final properties found on class ${element.name}.',
          todo: 'Make the properties of class ${element.name} public and final'
              ' or remove the CellExtension annotation.',
          element: element
      );
    }

    final buffer = StringBuffer();
    buffer.write(_generateCellExtension(element.name, fields));

    if (annotation.read('mutable').boolValue) {
      final mutableFields = _filterReservedFields(
          visitor.mutableFields,
          allReservedFieldNames,
          'MutableCell'
      );

      if (mutableFields.isEmpty) {
        throw InvalidGenerationSource(
            'The constructor of class ${element.name} does not have any field formal parameters.',
            todo: 'Add field formal parameters to the constructor of ${element.name} or '
                'remove `mutable: true` from the CellExtension annotation.',
            element: element
        );
      }

      buffer.write(_generateMutableCellExtension(
          className: element.name,
          fields: mutableFields,
          constructor: visitor.constructor!
      ));
    }

    return buffer.toString();
  }

  /// Generate a [ValueCell] extension providing accessors for [fields].
  String _generateCellExtension(String className, List<FieldElement> fields) {
    final buffer = StringBuffer();

    final keyClass = '_\$ValueCellPropKey$className';

    buffer.writeln('// Extends ValueCell with accessors for $className properties');
    buffer.writeln('extension ${className}CellExtension on ValueCell<$className> {');

    for (final field in fields) {
      buffer.writeln(_generateCellAccessor(field, keyClass));
    }

    buffer.writeln('}');
    buffer.write(_generatePropKeyClass(keyClass));

    return buffer.toString();
  }

  /// Generate an accessor for a class property which returns a [ValueCell] holding a [type].
  String _generateCellAccessor(FieldElement field, String keyClass) {
    final name = field.name;
    final type = field.type.toString();

    return 'ValueCell<$type> get $name => apply('
        '(value) => value.$name,'
        "key: $keyClass(this, '$name')"
        ');';
  }

  /// Generate a [MutableCell] extension providing accessors for [fields].
  String _generateMutableCellExtension({
    required String className,
    required List<FieldElement> fields,
    required ConstructorElement constructor,
  }) {
    final buffer = StringBuffer();

    final keyClass = '_\$MutableCellPropKey$className';
    
    buffer.writeln('// Extends MutableCell with accessors for $className properties');
    buffer.writeln('extension ${className}MutableCellExtension on MutableCell<$className> {');

    buffer.write(_generateCopyWithMethod(
        className: className,
        fields: fields,
        constructor: constructor
    ));

    for (final field in fields) {
      buffer.writeln(_generateMutableAccessor(field, keyClass));
    }

    buffer.writeln('}');
    buffer.write(_generatePropKeyClass(keyClass));

    return buffer.toString();
  }


  /// Generate an accessor for a class property which returns a [MutableCell] holding a [type].
  String _generateMutableAccessor(FieldElement field, String keyClass) {
    final name = field.name;
    final type = field.type.toString();

    return 'MutableCell<$type> get $name => MutableCellView('
        'argument: this,'
        "key: $keyClass(this, '$name'),"
        'compute: () => value.$name,'
        'reverse: (p) { value = _copyWith(value, $name: p); }'
        ');';
  }

  /// Generate a _copyWith static method for [className] which calls [constructor].
  String _generateCopyWithMethod({
    required String className,
    required ConstructorElement constructor,
    required List<FieldElement> fields,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('static $className _copyWith($className instance, {');

    for (final field in fields) {
      final type = field.type.toString();
      final suffix = field.type.nullabilitySuffix == NullabilitySuffix.none
          ? '?'
          : '';

      final name = field.name;

      buffer.writeln('$type$suffix $name,');
    }

    buffer.writeln('}) {');
    buffer.writeln('return $className(');

    for (final param in constructor.parameters) {
      if (param.isInitializingFormal && param is FieldFormalParameterElement) {
        final field = param.field!;
        final name = field.name;

        if (allReservedFieldNames.contains(name)) {
          continue;
        }

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

  /// Generate a property cell key class named [name].
  String _generatePropKeyClass(String name) {
    final buffer = StringBuffer();

    buffer.writeln('class $name {');
    buffer.writeln('final ValueCell _cell;');
    buffer.writeln('final String _prop;');
    buffer.writeln('$name(this._cell, this._prop);');

    buffer.writeln('@override');
    buffer.writeln(
        'bool operator==(other) => other is $name && '
        '_cell == other._cell && '
        '_prop == other._prop;'
    );

    buffer.writeln('@override');
    buffer.writeln('int get hashCode => Object.hash(runtimeType, _cell, _prop);');

    buffer.writeln('}');
    
    return buffer.toString();
  }

  /// Remove fields which use a reserved identifier.
  ///
  /// If a field uses an identifier present in [reserved], it is removed from
  /// [fields] and a warning is emitted with [extType] naming the extended class.
  ///
  /// The filtered list is returned, [fields] is not modified.
  static List<FieldElement> _filterReservedFields(
      List<FieldElement> fields,
      [Set<String> reserved = reservedFieldNames, String extType = 'ValueCell']) {
    List<FieldElement> filtered = [];

    for (final field in fields) {
      if (reservedFieldNames.contains(field.name)) {
        log.info('${field.name} is reserved for $extType properties. '
            'Accessor not be generated.');
      }
      else {
        filtered.add(field);
      }
    }

    return filtered;
  }
}