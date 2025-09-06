import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';
import 'data_class_generator.dart';
import 'type_expression_visitor.dart';

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
  String generateForAnnotatedElement(Element2 element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'The CellExtension annotation is only applicable to classes.',
        todo: 'Remove the CellExtension annotation',
        element: element
      );
    }

    final visitor = ClassPropVisitor();
    element.visitChildren2(visitor);

    final fields = _filterReservedFields(visitor.fields);

    if (fields.isEmpty) {
      throw InvalidGenerationSource(
          'No public final properties found on class ${element.displayName}.',
          todo: 'Make the properties of class ${element.displayName} public and final'
              ' or remove the CellExtension annotation.',
          element: element
      );
    }

    final spec = _CellExtensionSpec.parse(annotation.objectValue);

    final library = Library((b) {
      b.body.addAll(
          _generateCellExtension(
              spec: spec,
              className: element.name3!,
              fields: fields,
              types: element.typeParameters2,
              nullable: false
          )
      );

      if (spec.nullable) {
        b.body.addAll(
            _generateCellExtension(
                spec: spec,
                className: element.name3!,
                fields: fields,
                types: element.typeParameters2,
                nullable: true
            )
        );
      }

      if (spec.mutable) {
        final mutableFields = _filterReservedFields(
            visitor.mutableFields,
            allReservedFieldNames,
            'MutableCell'
        );

        if (mutableFields.isEmpty) {
          throw InvalidGenerationSource(
              'The constructor of class ${element.displayName} does not have any field formal parameters.',
              todo: 'Add field formal parameters to the constructor of ${element.displayName} or '
                  'remove `mutable: true` from the CellExtension annotation.',
              element: element
          );
        }

        b.body.addAll(
            _generateMutableCellExtension(
                spec: spec,
                className: element.name3!,
                fields: mutableFields,
                constructor: visitor.constructor!,
                types: element.typeParameters2
            )
        );
      }
    });

    final buffer = StringBuffer();
    final emitter = DartEmitter(useNullSafetySyntax: true);

    buffer.write(library.accept(emitter));

    if (spec.generateEquals) {
      buffer.write(DataClassGenerator.generateEqualsHashCode(element));
    }

    return buffer.toString();
  }

  /// Return a [Reference] that refers to a generic type parameter declaration
  Reference _typeParamRef(TypeParameterElement2 param) {
    return TypeReference((b) => b..symbol = param.name3!
        ..bound = param.bound?.accept(TypeExpressionVisitor())
    );
  }

  /// Generate a [ValueCell] extension providing accessors for [fields].
  Iterable<Spec> _generateCellExtension({
    required _CellExtensionSpec spec,
    required String className,
    required List<FieldElement2> fields,
    required List<TypeParameterElement2> types,
    required bool nullable
  }) sync* {
    final nullNameSuffix = nullable ? 'N' : '';
    final extensionName = '${spec.name ?? '${className}CellExtension'}$nullNameSuffix';
    final keyClass = '_\$ValueCellPropKey$className$nullNameSuffix';

    yield Extension((b) => b..name = extensionName
        ..types.addAll(types.map((t) => _typeParamRef(t)))
        ..on = TypeReference((b) => b..symbol = 'ValueCell'
            ..types.add(
              TypeReference((b) => b..symbol = className
                  ..types.addAll(types.map((t) => refer(t.name3!)))
                  ..isNullable = nullable
              )
            )
        )
        ..methods.addAll(
            fields.map((f) => _generateCellAccessor(
                field: f,
                keyClass: keyClass,
                nullable: nullable
            ))
        )
        ..docs.add('/// Extends ValueCell with accessors for $className properties')
    );

    yield _generatePropKeyClass(keyClass);
  }

  /// Generate a [ValueCell] accessor for a given class property.
  Method _generateCellAccessor({
    required FieldElement2 field,
    required String keyClass,
    required bool nullable,
  }) {
    final name = field.name3!;

    final propType = TypeReference((b) => b..symbol = 'ValueCell'
        ..types.add(field.type.accept(TypeExpressionVisitor(nullable: nullable)))
    );

    final propRef = nullable
        ? refer('value').nullSafeProperty(name)
        : refer('value').property(name);

    final accessor = Method((b) => b
      ..lambda = true
      ..requiredParameters.add(Parameter((b) => b..name = 'value'))
      ..body = propRef.code
    );

    final body = refer('apply')
        .call([
          accessor.closure
        ], {
          'key': refer(keyClass).call([
            refer('this'), refer('#$name')
          ])
        })
        .property('store')
        .call([], {'changesOnly': literalTrue});

    return Method((b) => b..name = name
        ..returns = propType
        ..type = MethodType.getter
        ..body = body.code
    );
  }

  /// Generate a [MutableCell] extension providing accessors for [fields].
  Iterable<Spec> _generateMutableCellExtension({
    required _CellExtensionSpec spec,
    required String className,
    required List<FieldElement2> fields,
    required ConstructorElement2 constructor,
    required List<TypeParameterElement2> types,
  }) sync* {
    final extensionName = spec.mutableName ?? '${className}MutableCellExtension';
    final keyClass = '_\$MutableCellPropKey$className';

    yield Extension((b) => b..name = extensionName
        ..types.addAll(types.map((t) => _typeParamRef(t)))
        ..on = TypeReference((b) => b..symbol = 'MutableCell'
            ..types.add(
              TypeReference((b) => b..symbol = className
                  ..types.addAll(types.map((t) => refer(t.name3!)))
              )
            )
        )
        ..methods.addAll(
            fields.map((f) => _generateMutableAccessor(
                className: className,
                fields: fields,
                constructor: constructor,
                field: f,
                keyClass: keyClass
            ))
        )
        ..docs.add('/// Extends MutableCell with accessors for $className properties')
    );

    yield _generatePropKeyClass(keyClass);
  }


  /// Generate a [MutableCell] accessor for a given class property.
  Method _generateMutableAccessor({
    required String className,
    required ConstructorElement2 constructor,
    required List<FieldElement2> fields,
    required FieldElement2 field,
    required String keyClass
  }) {
    final name = field.name3!;

    final propType = TypeReference((b) => b..symbol = 'MutableCell'
      ..types.add(field.type.accept(TypeExpressionVisitor()))
    );

    final copy = _generateCopyConstruct(
        className: className,
        constructor: constructor,
        fieldName: name,
        fieldValue: 'p',
        valueVar: '\$value'
    );

    final computeFn = Method((b) => b
        ..lambda = true
        ..requiredParameters.add(
          Parameter((b) => b..name = 'value')
        )
        ..body = refer('value')
            .property(name)
            .code
    );

    final reverseFn = Method((b) => b
        ..requiredParameters.add(
          Parameter((b) => b..name = 'p')
        )
        ..body = Block((b) => b..statements.addAll([
          declareFinal('\$value')
              .assign(refer('value'))
              .statement,

          refer('value')
              .assign(copy)
              .statement
        ]))
    );

    final body = refer('mutableApply').call([
      computeFn.closure,
      reverseFn.closure,
    ], {
      'key': refer(keyClass).call([
        refer('this'),
        refer('#$name')
      ]),

      'changesOnly': literalTrue
    });

    return Method((b) => b..name = name
        ..returns = propType
        ..type = MethodType.getter
        ..body = body.code
    );
  }

  /// Generate a call to the [constructor] of [className] which copies the property values.
  ///
  /// The generated code copies the values of the instance properties of the
  /// object stored in the variable [valueVar] with the exception of the
  /// property [fieldName], which is given the value [fieldValue].
  Expression _generateCopyConstruct({
    required String className,
    required ConstructorElement2 constructor,
    required String fieldName,
    required String fieldValue,
    required String valueVar,
  }) {
    FieldFormalParameterElement2 getFieldFormal(FormalParameterElement param) {
      if (param is SuperFormalParameterElement2) {
        return getFieldFormal(param.superConstructorParameter2!);
      }

      return param as FieldFormalParameterElement2;
    }

    Expression getFieldValue(FormalParameterElement param) => param.name3 == fieldName
        ? refer(fieldValue)
        : refer(valueVar).property(param.name3!);

    final fields = constructor.formalParameters
      .where((param) {
        if (param.isInitializingFormal && param is FieldFormalParameterElement2) {
          return !allReservedFieldNames.contains(param.field2?.name3);
        }

        return param.isSuperFormal &&
            param is SuperFormalParameterElement2 &&
            param.superConstructorParameter2 != null;
      })
      .map(getFieldFormal);

    final named = Map.fromEntries(
        fields.where((p) => p.isNamed)
            .map((p) => MapEntry(p.name3!, getFieldValue(p)))
    );

    final positional = fields.where((p) => !p.isNamed)
      .map(getFieldValue);

    return refer(className).call(positional, named);
  }

  /// Generate a property cell key class named [name].
  Class _generatePropKeyClass(String name) => Class((b) => b..name = name
    ..constructors.add(
      Constructor((b) => b..requiredParameters.addAll([
        Parameter((b) => b..name = '_cell'
          ..toThis = true
        ),
        Parameter((b) => b..name = '_prop'
          ..toThis = true
        )
      ]))
    )
    ..fields.addAll([
      Field((b) => b..name = '_cell'
        ..type = refer('ValueCell')
        ..modifier = FieldModifier.final$
      ),
      Field((b) => b..name = '_prop'
        ..type = refer('Symbol')
        ..modifier = FieldModifier.final$
      )
    ])
    ..methods.addAll([
      Method((b) => b..name='operator=='
        ..requiredParameters.add(
            Parameter((b) => b..name = 'other')
        )
        ..annotations.add(refer('override'))
        ..returns = refer('bool')
        ..body = refer('other')
            .isA(refer(name))
            .and(
              refer('_cell').equalTo(
                  refer('other').property('_cell')
              )
            )
            .and(
              refer('_prop').equalTo(
                  refer('other').property('_prop')
              )
            )
            .code
      ),
      Method((b) => b..name='hashCode'
        ..type = MethodType.getter
        ..annotations.add(refer('override'))
        ..returns = refer('int')
        ..body = refer('Object')
            .property('hash')
            .call([
              refer('runtimeType'),
              refer('_cell'),
              refer('_prop')
            ])
            .code
      )
    ])
  );

  /// Remove fields that use a reserved identifier.
  ///
  /// If a field uses an identifier present in [reserved], it is removed from
  /// [fields] and a warning is emitted with [extType] naming the extended class.
  ///
  /// The filtered list is returned, [fields] is not modified.
  static List<FieldElement2> _filterReservedFields(
      List<FieldElement2> fields,
      [Set<String> reserved = reservedFieldNames, String extType = 'ValueCell']) {
    List<FieldElement2> filtered = [];

    for (final field in fields) {
      if (reservedObjectFieldNames.contains(field.name3)) {
        continue;
      }
      else if (reserved.contains(field.name3)) {
        log.info('${field.displayName} is reserved for $extType properties. '
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

  /// Should equals and hash code functions be generated for the annotated class?
  final bool generateEquals;

  const _CellExtensionSpec({
    required this.name,
    required this.mutableName,
    required this.mutable,
    required this.nullable,
    required this.generateEquals
  });

  /// Parse the encoded annotation from [object].
  factory _CellExtensionSpec.parse(DartObject object) => _CellExtensionSpec(
      name: object.getField('name')?.toSymbolValue(),
      mutableName: object.getField('mutableName')?.toSymbolValue(),
      mutable: object.getField('mutable')?.toBoolValue() ?? false,
      nullable: object.getField('nullable')?.toBoolValue() ?? false,
      generateEquals: object.getField('generateEquals')?.toBoolValue() ?? true
  );
}