import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';

/// Generates extensions on [ValueCell] for classes annotated with [CellExtension].
class CellExtensionGenerator extends GeneratorForAnnotation<CellExtension> {
  /// Identifiers reserved for [Object] properties.
  static const reservedObjectFieldNames = {
    'hashCode'
  };

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

    final spec = _CellExtensionSpec.parse(annotation.objectValue);

    final buffer = StringBuffer();
    buffer.write(_generateCellExtension(
        spec: spec,
        className: element.name,
        fields: fields,
        types: element.typeParameters
    ));

    if (spec.mutable) {
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
          spec: spec,
          className: element.name,
          fields: mutableFields,
          constructor: visitor.constructor!,
          types: element.typeParameters
      ));
    }

    return buffer.toString();
  }

  /// Generate a [ValueCell] extension providing accessors for [fields].
  String _generateCellExtension({
    required _CellExtensionSpec spec,
    required String className,
    required List<FieldElement> fields,
    required List<TypeParameterElement> types
  }) {
    final buffer = StringBuffer();

    final extensionName = spec.name ?? '${className}CellExtension';
    final keyClass = '_\$ValueCellPropKey$className';

    final nullSuffix = spec.nullable ? '?' : '';

    final typeParams = types.isNotEmpty
        ? '<${types.map((e) => e.getDisplayString(withNullability: true)).join(',')}>'
        : '';

    final classTypeParams = types.isNotEmpty
        ? '<${types.map((e) => e.name).join(',')}>'
        : '';

    buffer.writeln('/// Extends ValueCell with accessors for $className properties');
    buffer.writeln('extension $extensionName$typeParams on ValueCell<$className$classTypeParams$nullSuffix> {');

    for (final field in fields) {
      buffer.writeln(_generateCellAccessor(
          field: field,
          keyClass: keyClass,
          nullable: spec.nullable
      ));
    }

    buffer.writeln('}');
    buffer.write(_generatePropKeyClass(keyClass));

    return buffer.toString();
  }

  /// Generate an accessor for a class property which returns a [ValueCell] holding a [type].
  String _generateCellAccessor({
    required FieldElement field,
    required String keyClass,
    required bool nullable,
  }) {
    final name = field.name;
    final type = field.type.getDisplayString(withNullability: false);

    final nullSuffix = nullable ||
        [NullabilitySuffix.question, NullabilitySuffix.star]
            .contains(field.type.nullabilitySuffix)
        ? '?'
        : '';

    final nullOperator = nullable ? '?' : '';

    return 'ValueCell<$type$nullSuffix> get $name => apply('
        '(value) => value$nullOperator.$name,'
        'key: $keyClass(this, #$name)'
        ').store(changesOnly: true);';
  }

  /// Generate a [MutableCell] extension providing accessors for [fields].
  String _generateMutableCellExtension({
    required _CellExtensionSpec spec,
    required String className,
    required List<FieldElement> fields,
    required ConstructorElement constructor,
    required List<TypeParameterElement> types,
  }) {
    final buffer = StringBuffer();

    final extensionName = spec.mutableName ?? '${className}MutableCellExtension';
    final keyClass = '_\$MutableCellPropKey$className';

    final typeParams = types.isNotEmpty
        ? '<${types.map((e) => e.getDisplayString(withNullability: true)).join(',')}>'
        : '';

    final classTypeParams = types.isNotEmpty
        ? '<${types.map((e) => e.name).join(',')}>'
        : '';

    buffer.writeln('/// Extends MutableCell with accessors for $className properties');
    buffer.writeln('extension $extensionName$typeParams on MutableCell<$className$classTypeParams> {');

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

    return 'MutableCell<$type> get $name => mutableApply('
        '(value) => value.$name,'
        '(p) { value = _copyWith(value, $name: p); },'
        'key: $keyClass(this, #$name),'
        'changesOnly: true'
        ');';
  }

  /// Generate a _copyWith static method for [className] which calls [constructor].
  String _generateCopyWithMethod({
    required String className,
    required ConstructorElement constructor,
    required List<FieldElement> fields,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('static $className _copyWith($className \$instance, {');

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

    final fieldNames = fields.map((f) => f.name).toSet();

    for (final param in constructor.parameters) {
      _addConstructorParam(
          buffer: buffer,
          param: param,
          fields: fieldNames
      );
    }

    buffer.writeln(');');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Emit code to [buffer] for a field parameter in the _copyWith method.
  void _addConstructorParam({
    required StringBuffer buffer,
    required ParameterElement param,
    required Set<String> fields,
  }) {
    if (param.isInitializingFormal && param is FieldFormalParameterElement) {
      final field = param.field!;
      final name = field.name;

      if (allReservedFieldNames.contains(name)) {
        return;
      }

      if (param.isNamed) {
        buffer.write('$name: ');
      }

      if (fields.contains(name)) {
        buffer.writeln('$name ?? \$instance.$name,');
      }
      else {
        buffer.writeln('\$instance.$name,');
      }
    }
    else if (param.isSuperFormal && param is SuperFormalParameterElement) {
      if (param.superConstructorParameter != null) {
        _addConstructorParam(
            buffer: buffer,
            param: param.superConstructorParameter!,
            fields: fields
        );
      }
    }
  }

  /// Generate a property cell key class named [name].
  String _generatePropKeyClass(String name) {
    final buffer = StringBuffer();

    buffer.writeln('class $name {');
    buffer.writeln('final ValueCell _cell;');
    buffer.writeln('final Symbol _prop;');
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
      if (reservedObjectFieldNames.contains(field.name)) {
        continue;
      }
      else if (reserved.contains(field.name)) {
        log.info('${field.name} is reserved for $extType properties. '
            'Accessor not generated.');
      }
      else {
        filtered.add(field);
      }
    }

    return filtered;
  }
}

/// Decoded cell extension annotation
class _CellExtensionSpec {
  /// Name of the ValueCell extension to generate.
  final String? name;

  /// Name of the MutableCell extension to generate.
  final String? mutableName;

  /// Should an extension on MutableCell be generated?
  final bool mutable;

  /// Should extensions on nullable types be generated?
  final bool nullable;

  const _CellExtensionSpec({
    required this.name,
    required this.mutableName,
    required this.mutable,
    required this.nullable
  });

  /// Parse the encoded annotation from [object].
  factory _CellExtensionSpec.parse(DartObject object) => _CellExtensionSpec(
      name: object.getField('name')?.toSymbolValue(),
      mutableName: object.getField('mutableName')?.toSymbolValue(),
      mutable: object.getField('mutable')?.toBoolValue() ?? false,
      nullable: object.getField('nullable')?.toBoolValue() ?? false
  );
}