import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class.
// Also tests that an extension on MutableCell is generated with accessors
// for every field in the constructor

@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person2 properties
extension Person2CellExtension on ValueCell<Person2> {
  ValueCell<String> get firstName => apply(
    (value) => value.firstName,
    key: _$ValueCellPropKeyPerson2(this, #firstName),
  ).store(changesOnly: true);
  ValueCell<String> get lastName => apply(
    (value) => value.lastName,
    key: _$ValueCellPropKeyPerson2(this, #lastName),
  ).store(changesOnly: true);
  ValueCell<int> get age => apply(
    (value) => value.age,
    key: _$ValueCellPropKeyPerson2(this, #age),
  ).store(changesOnly: true);
  ValueCell<String> get fullName => apply(
    (value) => value.fullName,
    key: _$ValueCellPropKeyPerson2(this, #fullName),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson2 {
  _$ValueCellPropKeyPerson2(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson2 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Person2 properties
extension Person2MutableCellExtension on MutableCell<Person2> {
  MutableCell<String> get firstName => mutableApply(
    (value) => value.firstName,
    (p) {
      final $value = value;
      value = Person2(firstName: p, lastName: $value.lastName, age: $value.age);
    },
    key: _$MutableCellPropKeyPerson2(this, #firstName),
    changesOnly: true,
  );
  MutableCell<String> get lastName => mutableApply(
    (value) => value.lastName,
    (p) {
      final $value = value;
      value = Person2(
        firstName: $value.firstName,
        lastName: p,
        age: $value.age,
      );
    },
    key: _$MutableCellPropKeyPerson2(this, #lastName),
    changesOnly: true,
  );
  MutableCell<int> get age => mutableApply(
    (value) => value.age,
    (p) {
      final $value = value;
      value = Person2(
        firstName: $value.firstName,
        lastName: $value.lastName,
        age: p,
      );
    },
    key: _$MutableCellPropKeyPerson2(this, #age),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyPerson2 {
  _$MutableCellPropKeyPerson2(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson2 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person2Equals(Person2 a, Object b) =>
    identical(a, b) ||
    (b is Person2 &&
        a.firstName == b.firstName &&
        a.lastName == b.lastName &&
        a.age == b.age &&
        a.address == b.address &&
        a._id == b._id &&
        a.value == b.value &&
        a.previous == b.previous);
int _$Person2HashCode(Person2 o) => Object.hashAll([
  o.firstName,
  o.lastName,
  o.age,
  o.address,
  o._id,
  o.value,
  o.previous,
]);
''',
    expectedLogItems: [
      'value is reserved for ValueCell properties. Accessor not generated.',
      'previous is reserved for ValueCell properties. Accessor not generated.',
      'value is reserved for MutableCell properties. Accessor not generated.',
      'previous is reserved for MutableCell properties. Accessor not generated.'
    ]
)
@CellExtension(mutable: true)
class Person2 {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  // Accessors not generated for properties with reserved names

  final String value;
  final Person2? previous;

  // Accessors not generated for static properties

  static final key = 'personKey';

  Person2({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.value = '',
    this.previous,
    int id = 0,
  }) : _id = id;
}