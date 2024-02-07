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

      buffer.writeln("// A [${widgetSpec.widgetClass.getDisplayString(withNullability: false)}] "
          "widget which takes the values of its properties from [ValueCell]'s.");

      buffer.write(_generateCellWidget(widgetSpec));
    }

    return buffer.toString();
  }

  /// Generate a wrapper for a widget defined as per [spec]..
  String _generateCellWidget(_WidgetClassSpec spec) {
    final widgetClass = spec.widgetClass;
    final className = widgetClass.getDisplayString(withNullability: false);
    final genName = spec.genName ?? 'Cell$className';
    final buffer = StringBuffer();

    final props = <_WidgetProperty>[];

    final constructor = widgetClass.constructors
        .firstWhere((element) => element.name.isEmpty);
    
    buffer.write('class $genName extends StatelessWidget {');

    buffer.write(_generateConstructor(
        className: genName, 
        constructor: constructor, 
        properties: props, 
        spec: spec
    ));
    
    buffer.writeln();
    buffer.write(_generateProperties(props));

    buffer.writeln();
    buffer.write(_generateBindMethod(genName, props));

    buffer.writeln();
    buffer.write(_generateBuild(
        spec: spec,
        constructor: constructor,
        properties: props
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
    required _WidgetClassSpec spec
  }) {
    final buffer = StringBuffer();

    buffer.writeln('const ${className}({');
    buffer.writeln('super.key,');

    for (final param in constructor.parameters) {
      if (param.isSuperFormal || spec.excludeProperties.contains(param.name)) {
        continue;
      }

      properties.add(_WidgetProperty(
          name: param.name,
          type: param.type,
          optional: !param.isRequired && !param.hasDefaultValue,
          mutable: spec.mutableProperties.contains(param.name)
      ));

      if (param.isRequired) {
        buffer.write('required ');
      }

      buffer.write('this.${param.name}');

      if (param.hasDefaultValue) {
        buffer.write(' = const ValueCell.value(${param.defaultValueCode})');
      }

      buffer.writeln(',');
    }

    buffer.writeln('});');

    return buffer.toString();
  }

  /// Generate the code defining the properties of the wrapper class.
  String _generateProperties(List<_WidgetProperty> properties) {
    final buffer = StringBuffer();

    for (final prop in properties) {
      buffer.writeln('final ${_cellPropType(prop, prop.optional)} ${prop.name};');
    }

    return buffer.toString();
  }

  /// Return the cell type for a given property [prop].
  ///
  /// If [optional] is true a nullable cell type is returned, otherwise a non-
  /// null type is returned.
  String _cellPropType(_WidgetProperty prop, bool optional) {
    final nullable = [NullabilitySuffix.question, NullabilitySuffix.star]
        .contains(prop.type.nullabilitySuffix);

    final name = prop.type.getDisplayString(withNullability: nullable);
    final suffix = optional ? '?' : '';

    final cell = prop.mutable ? 'MutableCell' : 'ValueCell';

    return '$cell<$name>$suffix';
  }

  /// Generate the build method for a widget wrapper class as per [spec].
  ///
  /// The build method calls the widget [constructor] passing in the parameters
  /// defined by [properties].
  String _generateBuild({
    required _WidgetClassSpec spec,
    required ConstructorElement constructor,
    required List<_WidgetProperty> properties
  }) {
    final buffer = StringBuffer();
    final className = spec.widgetClass.getDisplayString(withNullability: false);
    
    buffer.writeln('@override');
    buffer.writeln('Widget build(BuildContext \$context) {');
    buffer.writeln('return CellWidget.builder((\$context) => $className(');

    for (final param in constructor.parameters) {
      if (param.isSuperFormal ||
          (spec.excludeProperties.contains(param.name) &&
          !spec.propertyValues.containsKey(param.name))) {
        continue;
      }

      if (param.isNamed) {
        buffer.write('${param.name}: ');
      }

      if (spec.excludeProperties.contains(param.name)) {
        buffer.write(spec.propertyValues[param.name]);
      }
      else {
        buffer.write(param.name);

        if (param.isRequired || param.hasDefaultValue) {
          buffer.write('()');
        }
        else {
          buffer.write('?.call()');
        }
      }

      buffer.writeln(',');
    }

    buffer.writeln('));');
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
}

/// Specification for a widget wrapper class
class _WidgetClassSpec {
  /// The actual widget class for which the wrapper is generated
  final InterfaceType widgetClass;

  /// The name of the class to generate or null to use the default
  final String? genName;

  /// Set of properties which should be `MutableCell`'s
  final Set<String> mutableProperties;

  /// Set of properties to exclude from the generated wrapper class constructor
  final Set<String> excludeProperties;

  /// Map from property names to the corresponding code computing the property values
  ///
  /// If a property appears as a key this map, the code in the corresponding value
  /// is inserted in the call to the widget constructor, otherwise the property
  /// is forwarded to the constructor.
  final Map<String, String> propertyValues;

  _WidgetClassSpec({
    required this.widgetClass,
    required this.genName,
    required this.mutableProperties,
    required this.excludeProperties,
    required this.propertyValues
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
    final mutableProps = spec.getField('mutableProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final excludedProps = spec.getField('excludeProperties')
        ?.toListValue()
        ?.map((e) => e.toSymbolValue()!)
        .toSet();

    final propertyValues = spec.getField('propertyValues')
        ?.toMapValue()
        ?.map((key, value) => MapEntry(key!.toSymbolValue()!, value!.toStringValue()!));

    return _WidgetClassSpec(
        widgetClass: widgetClass as InterfaceType,
        genName: genName,
        mutableProperties: mutableProps ?? {}, 
        excludeProperties: excludedProps ?? {},
        propertyValues: propertyValues ?? {}
    );
  }
}

/// Information about a widget property.
class _WidgetProperty {
  /// Property name
  final String name;

  /// Property value type
  final DartType type;

  /// Is this property optional or a required property?
  final bool optional;

  /// Is this a mutable property?
  final bool mutable;

  _WidgetProperty({
    required this.name,
    required this.type,
    required this.optional,
    required this.mutable
  });
}