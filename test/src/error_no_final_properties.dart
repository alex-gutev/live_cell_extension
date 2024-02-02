import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an exception is thrown if CellExtension is applied to a class with
// no final properties

@ShouldThrow(
  'No public final properties found on class Person.',
  todo: 'Make the properties of class Person public and final or remove the '
      'CellExtension annotation.'
)
@CellExtension()
class Person {
  String? firstName;
  String? lastName;
  int? age;

  Person({
    this.firstName,
    this.lastName,
    this.age,
  });
}