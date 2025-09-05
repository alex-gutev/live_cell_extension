import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'class_prop_visitor.dart';

/// Generates hashCode and equals functions for classes annotates with [DataClass].
class DataClassGenerator extends GeneratorForAnnotation<DataClass> {
  /// Identifiers reserved for [Object] properties.
  static const ignoredFields = {
    'hashCode'
  };

  @override
  String generateForAnnotatedElement(Element2 element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
          'The DataClass annotation is only applicable to classes.',
          todo: 'Remove the DataClass annotation',
          element: element
      );
    }
    
    return generateEqualsHashCode(element);
  }
  
  /// Generate the equals and hashCode functions for a given class [element].
  static String generateEqualsHashCode(ClassElement2 element) {
    final visitor = ClassPropVisitor(
        publicOnly: false,
        immutableOnly: false,
        includeSynthetic: false
    );

    element.visitChildren2(visitor);

    final buffer = StringBuffer();

    final equals = _generateEquals(
        className: element.name3!,
        fields: visitor.fields,
    );

    final hash = _generateHashCode(
        className: element.name3!,
        fields: visitor.fields,
    );

    final lib = Library((b) => b..body.addAll([
      equals,
      hash
    ]));

    final emitter = DartEmitter(useNullSafetySyntax: true);

    buffer.write(lib.accept(emitter));

    return buffer.toString();
  }

  /// Generate equals function.
  static Method _generateEquals({
    required String className,
    required List<FieldElement2> fields,
  }) {
    final name = '_\$${className}Equals';

    Expression comparison = refer('b').isA(refer(className));

    for (final field in fields) {
      if (ignoredFields.contains(field.name3!)) {
        continue;
      }

      final name = field.name3!;
      final spec = _getDataFieldAnnotation(field);

      final lhs = refer('a').property(name);
      final rhs = refer('b').property(name);
      
      final expr = spec?.equals != null 
          ? refer(spec!.equals!.name3!).call([lhs, rhs])
          : lhs.equalTo(rhs);

      comparison = comparison.and(expr);
    }
    
    final idCheck = refer('identical').call([refer('a'), refer('b')]);
    final body = idCheck.or(comparison.parenthesized);

    return Method((b) => b..name = name
        ..requiredParameters.addAll([
          Parameter((b) => b..name = 'a'
              ..type = refer(className)
          ),
          Parameter((b) => b..name = 'b'
              ..type = refer('Object')
          )
        ])
        ..returns = refer('bool')
        ..body = body.code
    );
  }

  /// Generate hash code function.
  static Method _generateHashCode({
    required String className,
    required List<FieldElement2> fields,
  }) {
    final name = '_\$${className}HashCode';

    final hashes = fields.where((f) => !ignoredFields.contains(f))
        .map((field) {
          final name = field.name3!;
          final spec = _getDataFieldAnnotation(field);

          if (spec?.hash != null) {
            return refer(spec!.hash!.name3!).call([refer('o').property(name)]);
          }
          else {
            return refer('o').property(name);
          }
        });

    return Method((b) => b..name = name
        ..requiredParameters.add(
            Parameter((b) => b..name = 'o'
                ..type = refer(className)
            )
        )
        ..returns = refer('int')
        ..body = refer('Object')
            .property('hashAll')
            .call([
              literalList(hashes)
            ])
            .code
    );
  }

  /// Get the [DataField] annotation applying to a given [field], if any.
  static _DataFieldSpec? _getDataFieldAnnotation(FieldElement2 field) {
    for (final annotation in field.metadata2.annotations) {
      final obj = annotation.computeConstantValue();
      
      if (obj != null && obj.type?.getDisplayString() == 'DataField') {
        return _DataFieldSpec.parse(obj);
      }
    }

    return null;
  }
}

/// Parsed [DataField] annotation
class _DataFieldSpec {
  final ExecutableElement2? equals;
  final ExecutableElement2? hash;

  const _DataFieldSpec({
    required this.equals,
    required this.hash
  });

  factory _DataFieldSpec.parse(DartObject object) => _DataFieldSpec(
    equals: object.getField('equals')?.toFunctionValue2(),
    hash: object.getField('hash')?.toFunctionValue2()
  );
}