import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class.
// Also tests that an extension on MutableCell is generated with accessors
// for every field in the constructor

@ShouldGenerate(
    r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName,
      key: _$ValueCellPropKeyPerson(this, 'firstName'));
  ValueCell<String> get lastName => apply((value) => value.lastName,
      key: _$ValueCellPropKeyPerson(this, 'lastName'));
  ValueCell<int> get age =>
      apply((value) => value.age, key: _$ValueCellPropKeyPerson(this, 'age'));
  ValueCell<String> get fullName => apply((value) => value.fullName,
      key: _$ValueCellPropKeyPerson(this, 'fullName'));
}

class _$ValueCellPropKeyPerson {
  final ValueCell _cell;
  final String _prop;
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
    Person _instance, {
    String? firstName,
    String? lastName,
    int? age,
  }) {
    return Person(
      firstName: firstName ?? _instance.firstName,
      lastName: lastName ?? _instance.lastName,
      age: age ?? _instance.age,
    );
  }

  MutableCell<String> get firstName => MutableCellView(
      argument: this,
      key: _$MutableCellPropKeyPerson(this, 'firstName'),
      compute: () => value.firstName,
      reverse: (p) {
        value = _copyWith(value, firstName: p);
      });
  MutableCell<String> get lastName => MutableCellView(
      argument: this,
      key: _$MutableCellPropKeyPerson(this, 'lastName'),
      compute: () => value.lastName,
      reverse: (p) {
        value = _copyWith(value, lastName: p);
      });
  MutableCell<int> get age => MutableCellView(
      argument: this,
      key: _$MutableCellPropKeyPerson(this, 'age'),
      compute: () => value.age,
      reverse: (p) {
        value = _copyWith(value, age: p);
      });
}

class _$MutableCellPropKeyPerson {
  final ValueCell _cell;
  final String _prop;
  _$MutableCellPropKeyPerson(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
''',
    expectedLogItems: [
      'value is reserved for ValueCell properties. Accessor not be generated.',
      'previous is reserved for ValueCell properties. Accessor not be generated.',
      'value is reserved for MutableCell properties. Accessor not be generated.',
      'previous is reserved for MutableCell properties. Accessor not be generated.'
    ]
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

  // Accessors not generated for properties with reserved names

  final String value;
  final Person? previous;

  // Accessors not generated for static properties

  static final key = 'personKey';

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.value = '',
    this.previous = null,
    int id = 0,
  }) : _id = id;
}