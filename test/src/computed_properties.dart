import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class

@ShouldGenerate(
  r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName);
  ValueCell<String> get lastName => apply((value) => value.lastName);
  ValueCell<int> get age => apply((value) => value.age);
  ValueCell<String> get fullName => apply((value) => value.fullName);
}
'''
)
@CellExtension()
class Person {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
    int id = 0,
  }) : _id = id;
}