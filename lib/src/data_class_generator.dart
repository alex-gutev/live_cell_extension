import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:live_cell_extension/src/class_prop_visitor.dart';
import 'package:source_gen/source_gen.dart';

/// Generates hashCode and equals functions for classes annotates with [DataClass].
class DataClassGenerator extends GeneratorForAnnotation<DataClass> {
  /// Identifiers reserved for [Object] properties.
  static const ignoredFields = {
    'hashCode'
  };

  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'The DataClass annotation is only applicable to classes.',
          todo: 'Remove the DataClass annotation',
          element: element
      );
    }
    
    return generateEqualsHashCode(element);
  }
  
  /// Generate the equals and hashCode functions for a given class [element].
  static String generateEqualsHashCode(ClassElement element) {
    final visitor = ClassPropVisitor(
        publicOnly: false,
        immutableOnly: false,
        includeSynthetic: false
    );

    element.visitChildren(visitor);

    final buffer = StringBuffer();

    _generateEquals(
        className: element.name,
        fields: visitor.fields,
        buffer: buffer
    );

    _generateHashCode(
        className: element.name,
        fields: visitor.fields,
        buffer: buffer
    );

    return buffer.toString();
  }

  /// Generate equals function.
  static void _generateEquals({
    required String className,
    required List<FieldElement> fields,
    required StringBuffer buffer
  }) {
    buffer.write('bool _\$${className}Equals($className a, Object b) => ');
    buffer.write('identical(a, b) || (b is $className');

    for (final field in fields) {
      if (ignoredFields.contains(field.name)) {
        continue;
      }

      final name = field.name;
      final spec = _getDataFieldAnnotation(field);

      if (spec?.equals != null) {
        buffer.write('&& ${spec!.equals!.name}(a.$name, b.$name)');
      }
      else {
        buffer.write('&& a.$name == b.$name');
      }
    }

    buffer.writeln(');');
  }

  /// Generate hash code function.
  static void _generateHashCode({
    required String className,
    required List<FieldElement> fields,
    required StringBuffer buffer
  }) {
    buffer.write('int _\$${className}HashCode($className o) => Object.hashAll([');

    for (final field in fields) {
      if (ignoredFields.contains(field.name)) {
        continue;
      }

      final name = field.name;
      final spec = _getDataFieldAnnotation(field);

      if (spec?.hash != null) {
        buffer.write('${spec!.hash!.name}(o.$name),');
      }
      else {
        buffer.write('o.$name,');
      }
    }

    buffer.writeln(']);');
  }

  /// Get the [DataField] annotation applying to a given [field], if any.
  static _DataFieldSpec? _getDataFieldAnnotation(FieldElement field) {
    for (final annotation in field.metadata) {
      final obj = annotation.computeConstantValue();
      
      if (obj != null && obj.type?.getDisplayString(withNullability: false) == 'DataField') {
        return _DataFieldSpec.parse(obj);
      }
    }

    return null;
  }
}

/// Parsed [DataField] annotation
class _DataFieldSpec {
  final ExecutableElement? equals;
  final ExecutableElement? hash;

  const _DataFieldSpec({
    required this.equals,
    required this.hash
  });

  factory _DataFieldSpec.parse(DartObject object) => _DataFieldSpec(
    equals: object.getField('equals')?.toFunctionValue(),
    hash: object.getField('hash')?.toFunctionValue()
  );
}