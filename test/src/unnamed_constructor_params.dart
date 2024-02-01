import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that the extensions are generated correctly if the constructor takes
// unnamed field formal parameters.

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