import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that the extensions are generated correctly if the constructor takes
// unnamed field formal parameters.

@ShouldGenerate(
    r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName,
          key: _$ValueCellPropKeyPerson(this, #firstName))
      .store(changesOnly: true);
  ValueCell<String> get lastName => apply((value) => value.lastName,
          key: _$ValueCellPropKeyPerson(this, #lastName))
      .store(changesOnly: true);
  ValueCell<int> get age =>
      apply((value) => value.age, key: _$ValueCellPropKeyPerson(this, #age))
          .store(changesOnly: true);
  ValueCell<String> get fullName => apply((value) => value.fullName,
          key: _$ValueCellPropKeyPerson(this, #fullName))
      .store(changesOnly: true);
}

class _$ValueCellPropKeyPerson {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyPerson(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

// Extends MutableCell with accessors for Person properties
extension PersonMutableCellExtension on MutableCell<Person> {
  static Person _copyWith(
    Person $instance, {
    String? firstName,
    String? lastName,
    int? age,
  }) {
    return Person(
      firstName ?? $instance.firstName,
      lastName ?? $instance.lastName,
      age: age ?? $instance.age,
    );
  }

  MutableCell<String> get firstName =>
      mutableApply((value) => value.firstName, (p) {
        value = _copyWith(value, firstName: p);
      }, key: _$MutableCellPropKeyPerson(this, #firstName), changesOnly: true);
  MutableCell<String> get lastName =>
      mutableApply((value) => value.lastName, (p) {
        value = _copyWith(value, lastName: p);
      }, key: _$MutableCellPropKeyPerson(this, #lastName), changesOnly: true);
  MutableCell<int> get age => mutableApply((value) => value.age, (p) {
        value = _copyWith(value, age: p);
      }, key: _$MutableCellPropKeyPerson(this, #age), changesOnly: true);
}

class _$MutableCellPropKeyPerson {
  final ValueCell _cell;
  final Symbol _prop;
  _$MutableCellPropKeyPerson(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
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

  static final key = 'personKey';

  Person(this.firstName, this.lastName, {
    required this.age,
    int id = 0,
  }) : _id = id;
}