import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that the extensions are generated correctly if the constructor takes
// unnamed field formal parameters.

@ShouldGenerate(
    r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName);
  ValueCell<String> get lastName => apply((value) => value.lastName);
  ValueCell<int> get age => apply((value) => value.age);
  ValueCell<String> get fullName => apply((value) => value.fullName);
}

// Extends MutableCell with accessors for Person properties
extension PersonMutableCellExtension on MutableCell<Person> {
  static Person _copyWith(
    Person instance, {
    String? firstName,
    String? lastName,
    int? age,
  }) {
    return Person(
      firstName ?? instance.firstName,
      lastName ?? instance.lastName,
      age: age ?? instance.age,
    );
  }

  MutableCell<String> get firstName =>
      [this].mutableComputeCell(() => value.firstName, (p) {
        value = _copyWith(value, firstName: p);
      });
  MutableCell<String> get lastName =>
      [this].mutableComputeCell(() => value.lastName, (p) {
        value = _copyWith(value, lastName: p);
      });
  MutableCell<int> get age => [this].mutableComputeCell(() => value.age, (p) {
        value = _copyWith(value, age: p);
      });
}
'''
)
@CellExtension(mutable: true)
class Person {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  Person(this.firstName, this.lastName, {
    required this.age,
    int id = 0,
  }) : _id = id;
}