import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class.
// Also tests that an extension on MutableCell is generated with accessors
// for every field in the constructor

@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person3 properties
extension ThePersonCell on ValueCell<Person3> {
  ValueCell<String> get firstName => apply(
    (value) => value.firstName,
    key: _$ValueCellPropKeyPerson3(this, #firstName),
  ).store(changesOnly: true);
  ValueCell<String> get lastName => apply(
    (value) => value.lastName,
    key: _$ValueCellPropKeyPerson3(this, #lastName),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson3 {
  _$ValueCellPropKeyPerson3(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson3 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Person3 properties
extension TheMutablePersonCell on MutableCell<Person3> {
  MutableCell<String> get firstName => mutableApply(
    (value) => value.firstName,
    (p) {
      final $value = value;
      value = Person3(firstName: p, lastName: $value.lastName);
    },
    key: _$MutableCellPropKeyPerson3(this, #firstName),
    changesOnly: true,
  );
  MutableCell<String> get lastName => mutableApply(
    (value) => value.lastName,
    (p) {
      final $value = value;
      value = Person3(firstName: $value.firstName, lastName: p);
    },
    key: _$MutableCellPropKeyPerson3(this, #lastName),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyPerson3 {
  _$MutableCellPropKeyPerson3(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson3 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person3Equals(Person3 a, Object b) =>
    identical(a, b) ||
    (b is Person3 && a.firstName == b.firstName && a.lastName == b.lastName);
int _$Person3HashCode(Person3 o) => Object.hashAll([o.firstName, o.lastName]);
'''
)
@CellExtension(
    name: #ThePersonCell,
    mutableName: #TheMutablePersonCell,
    mutable: true
)
class Person3 {
  final String firstName;
  final String lastName;

  Person3({
    required this.firstName,
    required this.lastName,
  });
}