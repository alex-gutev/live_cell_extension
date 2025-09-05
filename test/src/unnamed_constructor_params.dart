import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that the extensions are generated correctly if the constructor takes
// unnamed field formal parameters.

@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person6 properties
extension Person6CellExtension on ValueCell<Person6> {
  ValueCell<String> get firstName => apply(
    (value) => value.firstName,
    key: _$ValueCellPropKeyPerson6(this, #firstName),
  ).store(changesOnly: true);
  ValueCell<String> get lastName => apply(
    (value) => value.lastName,
    key: _$ValueCellPropKeyPerson6(this, #lastName),
  ).store(changesOnly: true);
  ValueCell<int> get age => apply(
    (value) => value.age,
    key: _$ValueCellPropKeyPerson6(this, #age),
  ).store(changesOnly: true);
  ValueCell<String> get fullName => apply(
    (value) => value.fullName,
    key: _$ValueCellPropKeyPerson6(this, #fullName),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson6 {
  _$ValueCellPropKeyPerson6(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson6 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Person6 properties
extension Person6MutableCellExtension on MutableCell<Person6> {
  MutableCell<String> get firstName => mutableApply(
    (value) => value.firstName,
    (p) {
      final $value = value;
      value = Person6(p, $value.lastName, age: $value.age);
    },
    key: _$MutableCellPropKeyPerson6(this, #firstName),
    changesOnly: true,
  );
  MutableCell<String> get lastName => mutableApply(
    (value) => value.lastName,
    (p) {
      final $value = value;
      value = Person6($value.firstName, p, age: $value.age);
    },
    key: _$MutableCellPropKeyPerson6(this, #lastName),
    changesOnly: true,
  );
  MutableCell<int> get age => mutableApply(
    (value) => value.age,
    (p) {
      final $value = value;
      value = Person6($value.firstName, $value.lastName, age: p);
    },
    key: _$MutableCellPropKeyPerson6(this, #age),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyPerson6 {
  _$MutableCellPropKeyPerson6(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson6 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person6Equals(Person6 a, Object b) =>
    identical(a, b) ||
    (b is Person6 &&
        a.firstName == b.firstName &&
        a.lastName == b.lastName &&
        a.age == b.age &&
        a.address == b.address &&
        a._id == b._id);
int _$Person6HashCode(Person6 o) =>
    Object.hashAll([o.firstName, o.lastName, o.age, o.address, o._id]);
'''
)
@CellExtension(mutable: true)
class Person6 {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  static final key = 'personKey';

  Person6(this.firstName, this.lastName, {
    required this.age,
    int id = 0,
  }) : _id = id;
}