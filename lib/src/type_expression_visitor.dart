import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:code_builder/code_builder.dart' as cb;

/// [Generates] a [cb.Reference] that refers to the visited [DartType].
class TypeExpressionVisitor extends UnifyingTypeVisitor<cb.Reference> {
  /// Should a nullable reference be generated?
  ///
  /// If true a nullable reference is generated regardless of whether the visited
  /// type is nullable or not. If false a nullable type reference is only
  /// generated if the visited type is itself nullable.
  final bool nullable;

  const TypeExpressionVisitor({
    this.nullable = false
  });

  @override
  cb.Reference visitDartType(DartType type) =>
      cb.refer('dynamic');

  @override
  cb.Reference visitFunctionType(FunctionType type) =>
      cb.FunctionType((b) {
        b.isNullable = type.isNullable || nullable;
        b.returnType = type.returnType.accept(this);
        
        for (final param in type.formalParameters) {
          final name = param.name3;
          final type = param.type.accept(this);
          
          if (param.isRequiredPositional) {
            b.requiredParameters.add(type);
          }
          else if (param.isOptionalPositional) {
            b.optionalParameters.add(type);
          }
          else if (param.isRequiredNamed) {
            b.namedRequiredParameters[name!] = type;
          }
          else if (param.isOptionalNamed) {
            b.namedParameters[name!] = type;
          }
        }
      },);

  @override
  cb.Reference visitInterfaceType(InterfaceType type) =>
      cb.TypeReference((b) {
        b.symbol = type.element3.name3!;
        b.isNullable = type.isNullable || nullable;

        for (final param in type.typeArguments) {
          b.types.add(param.accept(this));
        }
      });

  @override
  cb.Reference visitRecordType(RecordType type) =>
      cb.RecordType((b) {
        b.isNullable = type.isNullable || nullable;

        for (final field in type.positionalFields) {
          b.positionalFieldTypes.add(field.type.accept(this));
        }

        for (final field in type.namedFields) {
          b.namedFieldTypes[field.name] = field.type.accept(this);
        }
      });
  
  @override
  cb.Reference visitTypeParameterType(TypeParameterType type) =>
      cb.refer(type.element3.name3!);

  @override
  cb.Reference visitVoidType(VoidType type) => cb.refer('void');
}

extension NullabilityExtension on DartType {
  bool get isNullable => [
    NullabilitySuffix.star,
    NullabilitySuffix.question
  ].contains(nullabilitySuffix);
}