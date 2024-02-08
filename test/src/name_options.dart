import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class.
// Also tests that an extension on MutableCell is generated with accessors
// for every field in the constructor

@ShouldGenerate(
    r'''
// Extends ValueCell with accessors for Person properties
extension ThePersonCell on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName,
      key: _$ValueCellPropKeyPerson(this, 'firstName'));
  ValueCell<String> get lastName => apply((value) => value.lastName,
      key: _$ValueCellPropKeyPerson(this, 'lastName'));
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
extension TheMutablePersonCell on MutableCell<Person> {
  static Person _copyWith(
    Person _instance, {
    String? firstName,
    String? lastName,
  }) {
    return Person(
      firstName: firstName ?? _instance.firstName,
      lastName: lastName ?? _instance.lastName,
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
@CellExtension(
    name: #ThePersonCell,
    mutableName: #TheMutablePersonCell,
    mutable: true
)
class Person {
  final String firstName;
  final String lastName;

  Person({
    required this.firstName,
    required this.lastName,
  });
}