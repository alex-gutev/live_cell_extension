import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';

/// Generate an extension which provides the `.cell` property.
///
/// For example, for the annotation:
///
/// ```dart
/// @GenerateValueExtensions([
///   ExtensionSpec<MyClass>()
/// ])
/// ```
///
/// the following extension is generated:
///
/// ```dart
/// extension MyClassCellValueExtension on MyClass {
///   ValueCell<MyClass> get cell => ValueCell.value(this);
/// }
/// ```
class CellValueExtensionGenerator extends GeneratorForAnnotation<GenerateValueExtensions> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final specs = annotation.read('specs').listValue;

    final buffer = StringBuffer();

    for (final spec in specs) {
      final extensionSpec = _ExtensionSpec.parse(spec);
      buffer.write(_generateExtension(extensionSpec));
    }

    return buffer.toString();
  }

  /// Generate the extension as per [spec]..
  String _generateExtension(_ExtensionSpec spec) {
    final type = spec.forSubclasses ? 'T' : spec.className;
    final genName = '${spec.className}CellValueExtension';
    final buffer = StringBuffer();

    buffer.writeln('/// Extends [${spec.className}] with the [cell] property.');
    buffer.write('extension $genName');

    if (spec.forSubclasses) {
      buffer.write('<T extends ${spec.className}>');
    }

    buffer.writeln(' on $type {');
    buffer.writeln('/// Create a constant [ValueCell] holding [this].');
    buffer.writeln('ValueCell<$type> get cell => ValueCell.value(this);');
    buffer.writeln('}');

    return buffer.toString();
  }
}

/// Specification for an extension to generate
class _ExtensionSpec {
  /// Name of the class to extend
  final String className;

  /// Should the subclasses of [className] be extended as well?
  final bool forSubclasses;

  _ExtensionSpec({
    required this.className,
    required this.forSubclasses
  });

  factory _ExtensionSpec.parse(DartObject object) {
    final specType = object.type as InterfaceType;
    final valueType = specType.typeArguments.first;

    final forSubclasses = object.getField('forSubclasses')!.toBoolValue()!;

    return _ExtensionSpec(
        className: valueType.getDisplayString(withNullability: false),
        forSubclasses: forSubclasses
    );
  }
}