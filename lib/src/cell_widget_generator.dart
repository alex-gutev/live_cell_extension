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
      final specType = spec.type as InterfaceType;
      final widgetClass = specType.typeArguments.single;

      if (widgetClass is DynamicType ||
          widgetClass is InvalidType) {
        // Stop generating
        return '';
      }

      buffer.writeln("// A [${widgetClass.getDisplayString(withNullability: false)}] "
          "widget which takes the values of its properties from [ValueCell]'s.");

      buffer.write(_generateCellWidget(widgetClass as InterfaceType));
    }

    return buffer.toString();
  }

  /// Generate a crapper for the widget class given by [widgetClass].
  String _generateCellWidget(InterfaceType widgetClass) {
    final className = widgetClass.getDisplayString(withNullability: false);
    final genName = 'Cell$className';
    final buffer = StringBuffer();

    final props = <_WidgetProperty>[];

    buffer.writeln('class $genName extends StatelessWidget {');

    for (final constructor in widgetClass.constructors) {
      buffer.write(_generateConstructor(genName, constructor, props));
    }

    buffer.writeln();
    buffer.write(_generateProperties(props));

    buffer.writeln();
    buffer.write(_generateBindMethod(genName, props));

    buffer.writeln();
    buffer.write(_generateBuild(widgetClass, props));

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a constructor for a widget wrapper.
  /// 
  /// A constructor for the wrapper class [className] is generated. Additionally
  /// the list [props] is populated with the properties which should be added
  /// to the wrapper class. These are deduced from the parameters of
  /// [constructor].
  String _generateConstructor(String className, ConstructorElement constructor, List<_WidgetProperty> props) {
    final buffer = StringBuffer();

    if (constructor.name.isEmpty) {
      buffer.writeln('const ${className}({');

      buffer.writeln('super.key,');

      for (final param in constructor.parameters) {
        if (param.isSuperFormal) {
          continue;
        }

        props.add(_WidgetProperty(
            name: param.name,
            type: param.type,
            optional: !param.isRequired && !param.hasDefaultValue
        ));

        if (param.isRequired) {
          buffer.write('required ');
        }

        buffer.write('this.${param.name}');

        if (param.hasDefaultValue) {
          buffer.write(' = ValueCell.value(${param.defaultValueCode}');
        }

        buffer.writeln(',');
      }

      buffer.writeln('});');
    }

    return buffer.toString();
  }

  /// Generate the code defining the properties of the wrapper class.
  String _generateProperties(List<_WidgetProperty> properties) {
    final buffer = StringBuffer();

    for (final prop in properties) {
      buffer.writeln('final ${_cellPropType(prop.type, prop.optional)} ${prop.name};');
    }

    return buffer.toString();
  }

  /// Return the cell type for a given property [type].
  ///
  /// If [optional] is true a nullable cell type is returned, otherwise a non-
  /// null type is returned.
  String _cellPropType(DartType type, bool optional) {
    final nullable = [NullabilitySuffix.question, NullabilitySuffix.star]
        .contains(type.nullabilitySuffix);

    final name = type.getDisplayString(withNullability: nullable);
    final suffix = optional ? '?' : '';

    return 'ValueCell<$name>$suffix';
  }

  /// Generate the build method for a wrapper class for widget [widgetClass].
  String _generateBuild(InterfaceType widgetClass, List<_WidgetProperty> props) {
    final buffer = StringBuffer();
    final constructor = _findConstructor(widgetClass);

    buffer.writeln('@override');
    buffer.writeln('Widget build(BuildContext \$context) {');
    buffer.writeln('return CellWidget.builder((\$context) => ${widgetClass.name}(');

    for (final param in constructor.parameters) {
      if (param.isSuperFormal) {
        continue;
      }
      if (param.isNamed) {
        buffer.write('${param.name}: ');
      }

      buffer.write(param.name);

      if (param.isRequired || param.hasDefaultValue) {
        buffer.write('()');
      }
      else {
        buffer.write('?.call()');
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
      final type = _cellPropType(prop.type, true);
      buffer.writeln('$type ${prop.name},');
    }

    buffer.writeln('}) => $genName(');

    for (final prop in props) {
      buffer.writeln('${prop.name}: ${prop.name} ?? this.${prop.name},');
    }

    buffer.writeln(');');

    return buffer.toString();
  }

  /// Find the default constructor of [widgetClass].
  ConstructorElement _findConstructor(InterfaceType widgetClass) {
    for (final constructor in widgetClass.constructors) {
      if (constructor.name.isEmpty) {
        return constructor;
      }
    }

    throw InvalidGenerationSource('Widget class does not have a default constructor.');
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

  _WidgetProperty({
    required this.name,
    required this.type,
    required this.optional
  });
}