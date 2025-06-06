import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';

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
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final specs = annotation.read('specs').listValue;

    final buffer = StringBuffer();

    for (final spec in specs) {
      final widgetSpec = _WidgetClassSpec.parse(spec);

      _generateWidgetClasses(
          spec: widgetSpec,
          buffer: buffer
      );
    }

    return buffer.toString();
  }

  /// Generate the widget classes for each constructor of a widget
  ///
  /// The class are generated according to the widget [spec] with the code
  /// written to [buffer].
  void _generateWidgetClasses({
    required _WidgetClassSpec spec,
    required StringBuffer buffer
  }) {
    final widgetClass = spec.widgetClass;

    final className = widgetClass.getDisplayString(withNullability: false)
        .replaceAll(RegExp(r'<(.*)>'), '');

    final genName = spec.genName ?? 'Live$className';

    final defaultConstructor = widgetClass.constructors
        .firstWhere((e) => e.name.isEmpty);

    final supers = defaultConstructor.parameters
        .where((p) => p.isSuperFormal)
        .map((p) => p.name)
        .toSet();

    if (widgetClass.constructors.length == 1) {
      buffer.writeln(
          _generateCellWidget(
            spec: spec,
            constructor: widgetClass.constructors.first,
            genName: genName,
            baseClass: spec.baseClass,
            soleClass: true,
            supers: supers
          )
      );
    }
    else {
      _generateBaseClass(
          spec: spec,
          genName: genName,
          buffer: buffer,
          supers: supers
      );

      final typeArgs = spec.typeArguments.isNotEmpty
          ? '<${spec.typeArguments.join(',')}>'
          : '';

      for (final constructor in widgetClass.constructors) {
        final cname = constructor.name.isEmpty ? '' : '\$${constructor.name}';
        buffer.writeln(
            _generateCellWidget(
                spec: spec,
                constructor: constructor,
                genName: '_$genName$cname',
                baseClass: '$genName$typeArgs',
                soleClass: false,
                supers: supers
            )
        );
      }
    }
  }

  /// Generate the widget base class with a factory constructor for each constructor.
  void _generateBaseClass({
    required _WidgetClassSpec spec,
    required String genName,
    required StringBuffer buffer,
    required Set<String> supers,
  }) {
    final widgetClass = spec.widgetClass;

    final className = widgetClass.getDisplayString(withNullability: false)
        .replaceAll(RegExp(r'<(.*)>'), '');

    final typeArgs = spec.typeArguments.isNotEmpty
        ? '<${spec.typeArguments.join(',')}>'
        : '';

    if (spec.documentation != null) {
      buffer.writeln(_makeDocComment(spec.documentation!));
    }
    else {
      buffer.writeln(_makeDefaultDocComment(className));
    }

    if (spec.deprecationNotice != null) {
      buffer.writeln('@Deprecated("${spec.deprecationNotice}")');
    }

    buffer.writeln('abstract class $genName$typeArgs extends ${spec.baseClass} {');

    for (final constructor in widgetClass.constructors) {
      buffer.write('const factory $genName');

      if (constructor.name.isNotEmpty) {
        buffer.write('.${constructor.name}');
      }

      final props = <_WidgetProperty>[];
      _generateConstructorArgs(
          buffer: buffer,
          constructor: constructor,
          hasSuperKey: false,
          spec: spec,
          properties: props,
          supers: supers,
          isFactory: true
      );

      if (constructor.name.isEmpty) {
        buffer.writeln(' = _$genName$typeArgs;');
      }
      else {
        buffer.writeln(' = _$genName\$${constructor.name}$typeArgs;');
      }
    }

    buffer.writeln('const $genName._internal({super.key});');

    buffer.writeln('}');
  }

  /// Generate a wrapper for a widget defined as per [spec].
  String _generateCellWidget({
    required _WidgetClassSpec spec,
    required ConstructorElement constructor,
    required String genName,
    required String baseClass,
    required bool soleClass,
    required Set<String> supers
  }) {
    final widgetClass = spec.widgetClass;

    final className = widgetClass.getDisplayString(withNullability: false)
        .replaceAll(RegExp(r'<(.*)>'), '');

    final buffer = StringBuffer();

    final props = <_WidgetProperty>[];

    final typeArgs = spec.typeArguments.isNotEmpty
        ? '<${spec.typeArguments.join(',')}>'
        : '';

    if (spec.documentation != null) {
      buffer.writeln(_makeDocComment(spec.documentation!));
    }
    else {
      buffer.writeln(_makeDefaultDocComment(className));
    }

    if (spec.deprecationNotice != null) {
      buffer.writeln('@Deprecated("${spec.deprecationNotice}")');
    }

    final mixins = spec.mixins.isNotEmpty
        ? 'with ${spec.mixins.join(',')}'
        : '';

    final interfaces = spec.interfaces.isNotEmpty
        ? 'implements ${spec.interfaces.join(',')}'
        : '';

    buffer.writeln('class $genName$typeArgs extends $baseClass $mixins $interfaces {');

    buffer.write(_generateConstructor(
        className: genName, 
        constructor: constructor, 
        properties: props, 
        spec: spec,
        soleClass: soleClass,
        supers: supers
    ));
    
    buffer.writeln();
    buffer.write(_generateProperties(props));

    if (spec.stateMixins.isNotEmpty) {
      final mixins = spec.stateMixins.join(',');
      final stateClass = '_${genName}State$typeArgs';
      final stateSuperClass = 'State<$genName$typeArgs>';

      buffer.writeln('@override');
      buffer.writeln('$stateSuperClass createState() => $stateClass();');

      buffer.writeln('}');
      buffer.writeln('class $stateClass extends $stateSuperClass with $mixins {');
    }

    buffer.writeln();
    buffer.write(_generateBuild(
        spec: spec,
        constructor: constructor,
        properties: props,
        isStatefulWidget: spec.stateMixins.isNotEmpty,
        supers: supers
    ));

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a constructor for a widget wrapper as per [spec].
  /// 
  /// A constructor for the wrapper class [className] is generated. Additionally
  /// the list [properties] is populated with the properties which should be added
  /// to the wrapper class. These are deduced from the parameters of
  /// [constructor].
  String _generateConstructor({
    required String className, 
    required ConstructorElement constructor, 
    required List<_WidgetProperty> properties,
    required _WidgetClassSpec spec,
    required bool soleClass,
    required Set<String> supers
  }) {
    final buffer = StringBuffer();

    buffer.writeln('const $className');

    _generateConstructorArgs(
        buffer: buffer,
        constructor: constructor,
        hasSuperKey: soleClass,
        spec: spec,
        properties: properties,
        supers: supers,
        isFactory: false
    );

    if (soleClass) {
      buffer.writeln(';');
    }
    else {
      buffer.writeln(': super._internal(key: key);');
    }

    return buffer.toString();
  }

  /// Generate the argument list for a constructor
  void _generateConstructorArgs({
    required StringBuffer buffer,
    required ConstructorElement constructor,
    required bool hasSuperKey,
    required bool isFactory,
    required _WidgetClassSpec spec,
    required List<_WidgetProperty> properties,
    required Set<String> supers
  }) {
    buffer.writeln('({');

    if (hasSuperKey) {
      buffer.writeln('super.key,');
    }
    else {
      buffer.writeln('Key? key,');
    }

    for (final prop in spec.addProperties) {
      properties.add(prop);

      if (!prop.optional && prop.defaultValue == null) {
        buffer.write('required ');
      }

      if (isFactory) {
        buffer.write('${_cellPropType(prop, prop.optional)} ${prop.name}');
      }
      else {
        buffer.write('this.${prop.name}');

        if (prop.defaultValue != null) {
          buffer.write(' = const ValueCell.value(${prop.defaultValue})');
        }
      }

      buffer.writeln(',');
    }

    for (final param in constructor.parameters) {
      if (spec.excludeProperties.contains(param.name) ||
          (supers.contains(param.name) &&
              !spec.includeSuperProperties.contains(param.name))) {
        continue;
      }

      final hasDefault = param.hasDefaultValue ||
          spec.propertyDefaultValues.containsKey(param.name);

      final optional = !param.isRequired && !hasDefault;
      final nullable = [NullabilitySuffix.question, NullabilitySuffix.star]
          .contains(param.type.nullabilitySuffix);

      final prop = _WidgetProperty(
          name: param.name,
          type: spec.propertyTypes[param.name]
              ?? param.type.getDisplayString(withNullability: nullable),
          optional: optional,
          mutable: spec.mutableProperties.contains(param.name),
          meta: false,
          isCell: spec.isCellProperty(param.name)
      );

      properties.add(prop);

      if (param.isRequired) {
        buffer.write('required ');
      }

      if (isFactory) {
        buffer.write('${_cellPropType(prop, prop.optional)} ${prop.name}');
      }
      else {
        buffer.write('this.${param.name}');

        if (hasDefault) {
          final defaultValue = spec.propertyDefaultValues[param.name]
              ?? param.defaultValueCode;

          if (!spec.isCellProperty(param.name)) {
            buffer.write(' = $defaultValue');
          }
          else {
            buffer.write(' = const ValueCell.value($defaultValue)');
          }
        }
      }

      buffer.writeln(',');
    }

    buffer.write('})');
  }

  /// Generate the code defining the properties of the wrapper class.
  String _generateProperties(List<_WidgetProperty> properties) {
    final buffer = StringBuffer();

    for (final prop in properties) {
      if (prop.documentation != null) {
        buffer.writeln(_makeDocComment(prop.documentation!));
      }

      buffer.writeln('final ${_cellPropType(prop, prop.optional)} ${prop.name};');
    }

    return buffer.toString();
  }

  /// Return the cell type for a given property [prop].
  ///
  /// If [optional] is true a nullable cell type is returned, otherwise a non-
  /// null type is returned.
  String _cellPropType(_WidgetProperty prop, bool optional) {
    final name = prop.type;

    if (!prop.isCell) {
      return optional && !name.endsWith('?')
          ? '$name?'
          : name;
    }

    final suffix = optional ? '?' : '';

    if (prop.isActionCell) {
      return 'ActionCell$suffix';
    }

    final cell = prop.mutable
        ? 'MutableCell' : prop.meta
        ? 'MetaCell' : 'ValueCell';

    return '$cell<$name>$suffix';
  }

  /// Generate the build method for a widget wrapper class as per [spec].
  ///
  /// The build method calls the widget [constructor] passing in the parameters
  /// defined by [properties].
  String _generateBuild({
    required _WidgetClassSpec spec,
    required ConstructorElement constructor,
    required List<_WidgetProperty> properties,
    required bool isStatefulWidget,
    required Set<String> supers
  }) {
    final buffer = StringBuffer();
    final className = spec.widgetClass.getDisplayString(withNullability: false);
    
    buffer.writeln('@override');
    buffer.writeln('Widget ${spec.buildMethod}(BuildContext context) {');

    if (spec.stateMixins.isNotEmpty) {
      buffer.writeln('return CellWidget.builder((context) {');
    }

    if (constructor.name.isEmpty) {
      buffer.writeln('return $className(');
    }
    else {
      buffer.writeln('return $className.${constructor.name}(');
    }

    for (final param in constructor.parameters) {
      if (!spec.propertyValues.containsKey(param.name) &&
          (spec.excludeProperties.contains(param.name) ||
              (supers.contains(param.name) &&
                  !spec.includeSuperProperties.contains(param.name)))) {
        continue;
      }

      if (param.isNamed) {
        buffer.write('${param.name}: ');
      }

      if (spec.propertyValues.containsKey(param.name)) {
        buffer.write(spec.propertyValues[param.name]);
      }
      else {
        if (isStatefulWidget) {
          buffer.write('widget.');
        }
        buffer.write(param.name);

        if (spec.isCellProperty(param.name)) {
          if (param.isRequired || param.hasDefaultValue) {
            buffer.write('()');
          }
          else {
            buffer.write('?.call()');
          }
        }
      }

      buffer.writeln(',');
    }

    buffer.writeln(');');

    if (spec.stateMixins.isNotEmpty) {
      buffer.writeln('});');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate the bind method for wrapper class [genName].
  String _generateBindMethod(String genName, List<_WidgetProperty> props) {
    final buffer = StringBuffer();

    buffer.writeln('${genName} bind({');

    for (final prop in props) {
      final type = _cellPropType(prop, true);
      buffer.writeln('$type ${prop.name},');
    }

    buffer.writeln('}) => $genName(');

    for (final prop in props) {
      buffer.writeln('${prop.name}: ${prop.name} ?? this.${prop.name},');
    }

    buffer.writeln(');');

    return buffer.toString();
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
  final String type;

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
        type: type.getDisplayString(
          withNullability: [NullabilitySuffix.star, NullabilitySuffix.question].contains(type.nullabilitySuffix)
        ),
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