import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class.
// Also tests that an extension on MutableCell is generated with accessors
// for every field in the constructor

@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person properties
extension ThePersonCell on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName,
          key: _$ValueCellPropKeyPerson(this, #firstName))
      .store(changesOnly: true);
  ValueCell<String> get lastName => apply((value) => value.lastName,
          key: _$ValueCellPropKeyPerson(this, #lastName))
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

/// Extends MutableCell with accessors for Person properties
extension TheMutablePersonCell on MutableCell<Person> {
  MutableCell<String> get firstName =>
      mutableApply((value) => value.firstName, (p) {
        final $value = value;
        value = Person(
          firstName: p,
          lastName: $value.lastName,
        );
      }, key: _$MutableCellPropKeyPerson(this, #firstName), changesOnly: true);
  MutableCell<String> get lastName =>
      mutableApply((value) => value.lastName, (p) {
        final $value = value;
        value = Person(
          firstName: $value.firstName,
          lastName: p,
        );
      }, key: _$MutableCellPropKeyPerson(this, #lastName), changesOnly: true);
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

bool _$PersonEquals(Person a, Object b) =>
    identical(a, b) ||
    (b is Person && a.firstName == b.firstName && a.lastName == b.lastName);
int _$PersonHashCode(Person o) => Object.hashAll([
      o.firstName,
      o.lastName,
    ]);
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