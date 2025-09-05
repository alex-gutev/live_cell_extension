import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class

@ShouldGenerate(
  r'''
/// Extends ValueCell with accessors for Person1 properties
extension Person1CellExtension on ValueCell<Person1> {
  ValueCell<String> get firstName => apply(
    (value) => value.firstName,
    key: _$ValueCellPropKeyPerson1(this, #firstName),
  ).store(changesOnly: true);
  ValueCell<String> get lastName => apply(
    (value) => value.lastName,
    key: _$ValueCellPropKeyPerson1(this, #lastName),
  ).store(changesOnly: true);
  ValueCell<int> get age => apply(
    (value) => value.age,
    key: _$ValueCellPropKeyPerson1(this, #age),
  ).store(changesOnly: true);
  ValueCell<String> get fullName => apply(
    (value) => value.fullName,
    key: _$ValueCellPropKeyPerson1(this, #fullName),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson1 {
  _$ValueCellPropKeyPerson1(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson1 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person1Equals(Person1 a, Object b) =>
    identical(a, b) ||
    (b is Person1 &&
        a.firstName == b.firstName &&
        a.lastName == b.lastName &&
        a.age == b.age &&
        a.address == b.address &&
        a._id == b._id &&
        a.value == b.value &&
        a.previous == b.previous);
int _$Person1HashCode(Person1 o) => Object.hashAll([
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
    'previous is reserved for ValueCell properties. Accessor not generated.'
  ]
)
@CellExtension()
class Person1 {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  // Accessors not generated for properties with reserved names

  final String value;
  final Person1? previous;

  @override
  int get hashCode => Object.hash(firstName, lastName, age);

  // Accessors not generated for static properties

  static final key = 'personKey';

  Person1({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.value = '',
    this.previous,
    int id = 0,
  }) : _id = id;
}