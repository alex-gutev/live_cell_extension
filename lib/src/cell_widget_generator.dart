import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';

import 'type_expression_visitor.dart';

/// Generates widget wrappers which take ValueCell properties.
///
/// This generates a wrapper for a Flutter widget, which allows the widget's
/// properties to be bound to cells. This means that when the value of a cell
/// changes, the value of the corresponding property to which the cell is
/// bound is updated to reflect the value of the cell.
/// 
/// For example this will generate the following wrapper for the `Text` widget:
/// 
/// ```dart
/// class CellText extends StatelessWidget {
///   final ValueCell<String> data;
///   final ValueCell<TextStyle?>? style;
///   ...
///   
///   CellText({
///     super.key,
///     required this.data,
///     this.style,
///     ...
///   });
///   
///   ...
/// }
/// ```
/// 
/// A `CellText` can then be constructed as follows:
/// 
/// ```dart
/// final content = MutableCell('');
/// ...
/// return CellText(data: content);
/// ```
/// 
/// When the value of the `content` cell, from the example above, is set, the
/// `CellText` widget is updated with a value for the `data` property equal
/// to the new value of the `content` cell.
/// 
/// ```dart
/// // Changes the text label to 'Hello World'
/// content.value = 'Hello World';
/// ```
class CellWidgetGenerator extends GeneratorForAnnotation<GenerateCellWidgets> {
  @override
  String generateForAnnotatedDirective(ElementDirective directive, ConstantReader annotation, BuildStep buildStep) {
    final specs = annotation.read('specs').listValue;

    final library = Library((b) {
      for (final spec in specs) {
        final widgetSpec = _WidgetClassSpec.parse(spec);

        b.body.addAll(
            _generateWidgetClasses(widgetSpec)
        );
      }
    });

    final buffer = StringBuffer();
    final emitter = DartEmitter(useNullSafetySyntax: true);

    buffer.write(library.accept(emitter));

    return buffer.toString();
  }

  /// Generate widget classes for each constructor of a widget [spec].
  Iterable<Class> _generateWidgetClasses(_WidgetClassSpec spec) sync* {
    final widgetClass = spec.widgetClass;

    final className = widgetClass.element3.name3!;
    final genName = spec.genName ?? 'Live$className';

    final defaultConstructor = widgetClass.constructors2
        .firstWhere((e) => e.name3 == 'new');

    final supers = defaultConstructor.formalParameters
        .where((p) => p.isSuperFormal)
        .map((p) => p.name3!)
        .toSet();

    if (widgetClass.constructors2.length == 1) {
      yield* _generateCellWidget(
          spec: spec,
          constructor: widgetClass.constructors2.first,
          genName: genName,
          baseClass: refer(spec.baseClass),
          soleClass: true,
          supers: supers
      );
    }
    else {
      yield _generateBaseClass(
          spec: spec,
          genName: genName,
          supers: supers
      );

      for (final constructor in widgetClass.constructors2) {
        yield* _generateCellWidget(
            spec: spec,
            constructor: constructor,
            genName: '_$genName\$${constructor.name3}',

            baseClass: TypeReference((b) => b..symbol = genName
              ..types.addAll(spec.typeArguments.map(refer))
            ),

            soleClass: false,
            supers: supers
        );
      }
    }
  }

  /// Generate the widget base class with a factory constructor for each constructor.
  Class _generateBaseClass({
    required _WidgetClassSpec spec,
    required String genName,
    required Set<String> supers,
  }) {
    final widgetClass = spec.widgetClass;
    final className = widgetClass.element3.name3!;

    return Class((b) {
      b.name = genName;
      b.types.addAll(spec.typeArguments.map(refer));
      b.abstract = true;
      b.extend = refer(spec.baseClass);

      b.docs.add(spec.documentation != null
          ? _makeDocComment(spec.documentation!)
          : _makeDefaultDocComment(className));

      if (spec.deprecationNotice != null) {
        b.annotations.add(
            refer('Deprecated')
                .call([literalString(spec.deprecationNotice!)])
        );
      }

      for (final constructor in widgetClass.constructors2) {
        b.constructors.add(
          Constructor((b) {
            if (constructor.name3 != 'new') {
              b.name = constructor.name3!;
            }

            b.factory = true;
            b.constant = true;

            final props = <_WidgetProperty>[];
            _generateConstructorArgs(
                builder: b,
                constructor: constructor,
                hasSuperKey: false,
                spec: spec,
                properties: props,
                supers: supers,
                isFactory: true
            );

            b.redirect = TypeReference((b) => b
              ..symbol = '_$genName\$${constructor.name3!}'
              ..types.addAll(spec.typeArguments.map(refer))
            );
          })
        );
      }

      b.constructors.add(
        Constructor((b) => b..name = '_internal'
            ..constant = true
            ..optionalParameters.add(
                Parameter((b) => b..name = 'key'
                    ..named = true
                    ..toSuper = true
                )
            )
        )
      );
    });
  }

  /// Generate a wrapper class for a widget defined as per [spec].
  ///
  /// The wrapper class builds the widget using a given [constructor].
  Iterable<Class> _generateCellWidget({
    required _WidgetClassSpec spec,
    required ConstructorElement2 constructor,
    required String genName,
    required Reference baseClass,
    required bool soleClass,
    required Set<String> supers
  }) sync* {
    final widgetClass = spec.widgetClass;

    final className = widgetClass.element3.name3!;
    final props = <_WidgetProperty>[];

    final stateClassName = '${genName}State';

    final stateClass = TypeReference((b) => b..symbol = stateClassName
        ..types.addAll(spec.typeArguments.map(refer))
    );

    final stateSuperClass = TypeReference((b) => b..symbol = 'State'
        ..types.add(
          TypeReference((b) => b..symbol = genName
              ..types.addAll(spec.typeArguments.map(refer))
          )
        )
    );

    yield Class((b) {
      b.name = genName;

      b.types.addAll(spec.typeArguments.map(refer));
      b.extend = baseClass;
      b.mixins.addAll(spec.mixins.map(refer));
      b.implements.addAll(spec.interfaces.map(refer));

      b.docs.add(spec.documentation != null
          ? _makeDocComment(spec.documentation!)
          : _makeDefaultDocComment(className)
      );

      if (spec.deprecationNotice != null) {
        b.annotations.add(
            refer('Deprecated')
                .call([literalString(spec.deprecationNotice!)])
        );
      }

      b.constructors.add(
          _generateConstructor(
              className: genName,
              constructor: constructor,
              properties: props,
              spec: spec,
              soleClass: soleClass,
              supers: supers
          )
      );

      b.fields.addAll(_generateProperties(props));

      if (spec.stateMixins.isNotEmpty) {
        b.methods.add(
            Method((b) => b..name = 'createState'
              ..annotations.add(refer('override'))
              ..returns = stateSuperClass
              ..body = stateClass.call([]).code
            )
        );
      }
      else {
        b.methods.add(
            _generateBuild(
                spec: spec,
                constructor: constructor,
                properties: props,
                isStatefulWidget: spec.stateMixins.isNotEmpty,
                supers: supers
            )
        );
      }
    });

    if (spec.stateMixins.isNotEmpty) {
      yield Class((b) {
        b.name = stateClassName;
        b.types.addAll(spec.typeArguments.map(refer));
        b.extend = stateSuperClass;
        b.mixins.addAll(spec.stateMixins.map(refer));

        b.methods.add(
            _generateBuild(
                spec: spec,
                constructor: constructor,
                properties: props,
                isStatefulWidget: spec.stateMixins.isNotEmpty,
                supers: supers
            )
        );
      });
    }
  }

  /// Generate a constructor for a widget wrapper as per [spec].
  /// 
  /// A constructor for the wrapper class [className] is generated. Additionally
  /// the list [properties] is populated with the properties which should be added
  /// to the wrapper class. These are deduced from the parameters of
  /// [constructor].
  Constructor _generateConstructor({
    required String className, 
    required ConstructorElement2 constructor,
    required List<_WidgetProperty> properties,
    required _WidgetClassSpec spec,
    required bool soleClass,
    required Set<String> supers
  }) {
    return Constructor((b) {
      b.constant = true;

      _generateConstructorArgs(
          builder: b,
          constructor: constructor,
          hasSuperKey: soleClass,
          spec: spec,
          properties: properties,
          supers: supers,
          isFactory: false
      );

      if (!soleClass) {
        b.initializers.add(
            refer('super')
                .property('_internal')
                .call([], {
                  'key': refer('key')
                })
                .code
        );
      }
    });
  }

  /// Generate the argument list for a constructor.
  ///
  /// The arguments are added to the constructor parameters using the given
  /// [builder].
  void _generateConstructorArgs({
    required ConstructorBuilder builder,
    required ConstructorElement2 constructor,
    required bool hasSuperKey,
    required bool isFactory,
    required _WidgetClassSpec spec,
    required List<_WidgetProperty> properties,
    required Set<String> supers
  }) {

    builder.optionalParameters.add(
        Parameter((b) {
          b.name = 'key';
          b.named = true;

          if (hasSuperKey) {
            b.toSuper = true;
          }
          else {
            b.type = TypeReference((b) => b..symbol = 'Key'
              ..isNullable = true
            );
          }
        })
    );

    for (final prop in spec.addProperties) {
      properties.add(prop);

      final param = Parameter((b) {
        b.name = prop.name;
        b.named = true;
        b.required = !prop.optional && prop.defaultValue == null;

        if (isFactory) {
          b.type = _cellPropType(prop, prop.optional);
        }
        else {
          b.toThis = true;

          if (prop.defaultValue != null) {
            b.defaultTo = declareConst('ValueCell')
                .property('value')
                .call([refer(prop.defaultValue!)])
                .code;
          }
        }
      });

      builder.optionalParameters.add(param);
    }

    for (final param in constructor.formalParameters) {
      final paramName = param.name3!;

      if (spec.excludeProperties.contains(paramName) ||
          (supers.contains(paramName) &&
              !spec.includeSuperProperties.contains(paramName))) {
        continue;
      }

      final hasDefault = param.hasDefaultValue ||
          spec.propertyDefaultValues.containsKey(paramName);

      final optional = !param.isRequired && !hasDefault;
      final propType = spec.propertyTypes[paramName];

      final prop = _WidgetProperty(
          name: paramName,

          type: propType != null
              ? _refType(propType)
              : param.type.accept(TypeExpressionVisitor()),

          optional: optional,
          mutable: spec.mutableProperties.contains(paramName),
          meta: false,
          isCell: spec.isCellProperty(paramName)
      );

      properties.add(prop);

      final genParam = Parameter((b) {
        b.name = paramName;
        b.named = true;
        b.required = param.isRequired;

        if (isFactory) {
          b.type = _cellPropType(prop, prop.optional);
        }
        else {
          b.toThis = true;

          if (hasDefault) {
            final defaultValue = spec.propertyDefaultValues[paramName]
                ?? param.defaultValueCode
                ?? 'null';

            if (!spec.isCellProperty(paramName)) {
              b.defaultTo = Code(defaultValue);
            }
            else {
              b.defaultTo = declareConst('ValueCell')
                  .property('value')
                  .call([refer(defaultValue)])
                  .code;
            }
          }
        }
      });

      builder.optionalParameters.add(genParam);
    }
  }

  /// Generate the code defining the properties of the wrapper class.
  Iterable<Field> _generateProperties(List<_WidgetProperty> properties) =>
    properties.map(_generateProperty);

  /// Generate a [Field] that defines a widget [property].
  Field _generateProperty(_WidgetProperty property) => Field((b) {
    b..name = property.name
      ..type = _cellPropType(property, property.optional)
      ..modifier = FieldModifier.final$;

    if (property.documentation != null) {
      b.docs.add(_makeDocComment(property.documentation!));
    }
  });

  /// Return a [Reference] to the cell type for a given property [prop].
  ///
  /// If [optional] is true a nullable cell type is returned, otherwise a non-
  /// nullable type is returned.
  Reference _cellPropType(_WidgetProperty prop, bool optional) {
    if (!prop.isCell) {
      return prop.type;
    }

    if (prop.isActionCell) {
      return TypeReference((b) => b..symbol = 'ActionCell'
          ..isNullable = optional
      );
    }

    return TypeReference((b) => b
      ..symbol = prop.mutable
            ? 'MutableCell' : prop.meta
            ? 'MetaCell' : 'ValueCell'
      ..types.add(prop.type)
      ..isNullable = optional
    );
  }

  /// Convert a string [type] descriptor to a [Reference].
  TypeReference _refType(String type) {
    final (name, nullable) = _parseType(type);

    return TypeReference((b) => b..symbol = name
        ..isNullable = nullable
    );
  }

  /// Parse a type from a string.
  ///
  /// Returns a recording containing the type without the nullability suffix,
  /// and a boolean that is true if [type] is a nullable type and false if it
  /// is not nullable.
  (String, bool) _parseType(String type) {
    if (type.endsWith('?')) {
      return (type.substring(0, type.length-1), true);
    }
    else {
      return (type, false);
    }
  }

  /// Generate the build method for a widget wrapper class as per [spec].
  ///
  /// The build method calls the widget [constructor] passing in the parameters
  /// defined by [properties].
  Method _generateBuild({
    required _WidgetClassSpec spec,
    required ConstructorElement2 constructor,
    required List<_WidgetProperty> properties,
    required bool isStatefulWidget,
    required Set<String> supers
  }) {
    Expression paramValue(FormalParameterElement param) {
      final name = param.name3!;
      
      if (spec.propertyValues.containsKey(name)) {
        return refer(spec.propertyValues[name]!);
      }

      final value = isStatefulWidget
          ? refer('widget').property(name)
          : refer(name);

      if (spec.isCellProperty(name)) {
        if (param.isRequired || param.hasDefaultValue) {
          return value.call([]);
        }

        return value.nullSafeProperty('call').call([]);
      }

      return value;
    }

    final className = spec.widgetClass.element3.name3!;

    final cls = TypeReference((b) => b..symbol = className
        ..types.addAll(spec.typeArguments.map(refer))
    );

    final constructFn = constructor.name3 == 'new'
        ? cls
        : cls.property(constructor.name3!);

    final params = constructor.formalParameters.where((param) {
      final name = param.name3!;

      if (!spec.propertyValues.containsKey(name) &&
          (spec.excludeProperties.contains(name) ||
              (supers.contains(name) &&
                  !spec.includeSuperProperties.contains(name)))) {
        return false;
      }

      return true;
    });

    final positional = params
        .where((p) => p.isPositional)
        .map(paramValue);

    final named = Map.fromEntries(
        params.where((p) => p.isNamed)
            .map((p) => MapEntry(p.name3!, paramValue(p)))
    );

    final widget = constructFn.call(positional, named);

    return Method((b) {
      b.name = spec.buildMethod;
      b.returns = refer('Widget');
      b.annotations.add(refer('override'));

      b.requiredParameters.add(
        Parameter((b) => b..name = 'context'
            ..type = refer('BuildContext')
        )
      );

      if (isStatefulWidget) {
        b.body = refer('CellWidget')
            .property('builder')
            .call([
              Method((b) => b
                  ..requiredParameters.add(
                      Parameter((b) => b..name = 'context')
                  )
                  ..lambda = true
                  ..body = widget.code
              ).closure
            ])
            .code;
      }
      else {
        b.body = widget.code;
      }
    });
  }

  /// Convert a multi-line string into a documentation comment
  String _makeDocComment(String documentation) {
    final splitter = LineSplitter();
    final lines = splitter.convert(documentation);

    if (lines.lastOrNull?.isEmpty ?? false) {
      lines.removeLast();
    }

    return lines.map((e) => '/// $e')
        .join(Platform.lineTerminator);
  }

  String _makeDefaultDocComment(String widgetClass) => _makeDocComment(
    '[$widgetClass] widget with its properties controlled by [ValueCell]s.\n'
        '\n'
        'The constructor takes the same arguments as the unnamed constructor of [$widgetClass],\n'
        "but as [ValueCell]'s. This binds each property value to the [ValueCell] given\n"
        'in the constructor. If the cell value is changed, the value of the corresponding\n'
        'property to which it is bound is automatically updated to reflect the value of\n'
        'the cell.'
  );
}

/// Specification for a widget wrapper class
class _WidgetClassSpec {
  /// The actual widget class for which the wrapper is generated
  final InterfaceType widgetClass;

  /// The name of the class to generate or null to use the default
  final String? genName;

  /// Type arguments to add to generated class
  final List<String> typeArguments;

  /// Set of properties which should be `MutableCell`'s
  final Set<String> mutableProperties;

  /// Set of properties to exclude from the generated wrapper class constructor
  final Set<String> excludeProperties;

  /// If non-null only these properties should be cells
  final Set<String>? cellProperties;

  /// Map from property names to the corresponding code computing the property values
  ///
  /// If a property appears as a key this map, the code in the corresponding value
  /// is inserted in the call to the widget constructor, otherwise the property
  /// is forwarded to the constructor.
  final Map<String, String> propertyValues;

  /// Map from property names to the corresponding code computing the property default values
  ///
  /// If a property appears as a key this map, the code in the corresponding value
  /// is used to compute the default value in the constructor.
  final Map<String, String> propertyDefaultValues;

  /// Map from property names to types
  ///
  /// If a property is a key in this map, its type is replaced with the type in
  /// the corresponding value.
  final Map<String, String> propertyTypes;

  /// Additional properties to add to generated class
  final List<_WidgetProperty> addProperties;

  /// Properties of the super class to include in the generated wrapper.
  final Set<String> includeSuperProperties;

  /// List of mixins to include in the generated class
  final List<String> mixins;

  /// List of interfaces that generated class should implement
  final List<String> interfaces;

  /// Name of the generated build method
  final String buildMethod;

  /// Name of the class that the generated class extends
  final String baseClass;

  /// Documentation comment for the generated class
  final String? documentation;

  /// List of mixins to mix into the generated widget [State] class.
  final List<String> stateMixins;

  /// The deprecation notice to add to generated class
  final String? deprecationNotice;

  _WidgetClassSpec({
    required this.widgetClass,
    required this.genName,
    required this.typeArguments,
    required this.mutableProperties,
    required this.excludeProperties,
    required this.cellProperties,
    required this.propertyValues,
    required this.propertyDefaultValues,
    required this.propertyTypes,
    required this.addProperties,
    required this.includeSuperProperties,
    required this.mixins,
    required this.interfaces,
    required this.buildMethod,
    required this.baseClass,
    required this.documentation,
    required this.stateMixins,
    required this.deprecationNotice
  });

  /// Parse a [_WidgetClassSpect] from the generic object [spec].
  factory _WidgetClassSpec.parse(DartObject spec) {
    final specType = spec.type as InterfaceType;
    final widgetClass = specType.typeArguments.single;

    if (widgetClass is DynamicType ||
        widgetClass is InvalidType) {
      throw InvalidGenerationSource('WidgetSpec type parameter must be a class');
    }

    final genName = spec.getField('as')?.toSymbolValue();

    final typeArgs = spec.getField('typeArguments')
        ?.toListValue()
        ?.map((e) => e.toStringValue()!)
        .toList();

    final mutableProps = spec.getField('mutableProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final excludedProps = spec.getField('excludeProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final cellProperties = spec.getField('cellProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final propertyValues = spec.getField('propertyValues')
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toSymbolValue()!, value!.toStringValue()!));

    final propertyDefaultValues = spec.getField('propertyDefaultValues')
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toSymbolValue()!, value!.toStringValue()!));

    final propertyTypes = spec.getField('propertyTypes')
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toSymbolValue()!, value!.toStringValue()!));

    final addProperties = spec.getField('addProperties')
        ?.toListValue()
        ?.map((e) => _WidgetProperty.parse(e)).toList();

    final superProps = spec.getField('includeSuperProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final mixins = spec.getField('mixins')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toList();

    final interfaces = spec.getField('interfaces')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toList();

    final buildMethod = spec.getField('buildMethod')!.toSymbolValue()!;
    final baseClass = spec.getField('baseClass')!.toSymbolValue()!;

    final documentation = spec.getField('documentation')?.toStringValue();

    final deprecationNotice = spec.getField('deprecationNotice')?.toStringValue();

    final stateMixins = spec.getField('stateMixins')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toList();

    return _WidgetClassSpec(
        widgetClass: widgetClass as InterfaceType,
        genName: genName,
        typeArguments: typeArgs ?? [],
        mutableProperties: mutableProps ?? {}, 
        excludeProperties: excludedProps ?? {},
        cellProperties: cellProperties,
        propertyValues: propertyValues ?? {},
        propertyDefaultValues: propertyDefaultValues ?? {},
        propertyTypes: propertyTypes ?? {},
        addProperties: addProperties ?? [],
        includeSuperProperties: superProps ?? {},
        mixins: mixins ?? [],
        interfaces: interfaces ?? [],
        buildMethod: buildMethod,
        baseClass: baseClass,
        documentation: documentation,
        stateMixins: stateMixins ?? [],
        deprecationNotice: deprecationNotice
    );
  }

  /// Is [name] a cell property?
  bool isCellProperty(String name) {
    return cellProperties?.contains(name) ?? true;
  }
}

/// Information about a widget property.
class _WidgetProperty {
  /// Property name
  final String name;

  /// Property value type
  final Reference type;

  /// Is this property optional or a required property?
  final bool optional;

  /// Is this a mutable property?
  final bool mutable;

  /// Should this property be held in a meta cell?
  final bool meta;

  /// Default value to initialize property to.
  ///
  /// If null the property does not have a default value.
  final String? defaultValue;

  /// Documentation for this property
  final String? documentation;

  /// Is this a cell property
  final bool isCell;

  /// Is this property an ActionCell?
  final bool isActionCell;

  _WidgetProperty({
    required this.name,
    required this.type,
    required this.optional,
    required this.mutable,
    required this.meta,
    required this.isCell,
    this.isActionCell = false,
    this.defaultValue,
    this.documentation
  });

  /// Parse a _WidgetProperty from [spec] which encodes a [WidgetPropertySpec].
  factory _WidgetProperty.parse(DartObject spec) {
    final specType = spec.type as InterfaceType;

    final type = specType.typeArguments.single;
    final name = spec.getField('name')!.toSymbolValue()!;
    final defaultValue = spec.getField('defaultValue')?.toStringValue();
    final optional = spec.getField('optional')!.toBoolValue()!;
    final mutable = spec.getField('mutable')!.toBoolValue()!;
    final meta = spec.getField('meta')!.toBoolValue()!;

    final documentation = spec.getField('documentation')?.toStringValue();

    return _WidgetProperty(
        name: name,
        type: type.accept(TypeExpressionVisitor()),
        optional: optional,
        mutable: mutable,
        meta: meta,
        isCell: true,
        isActionCell: type is VoidType && mutable,
        defaultValue: defaultValue,
        documentation: documentation
    );
  }
}