import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@CellExtension(
    nullable: true,
    mutable: true
)
@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get name =>
      apply((value) => value.name, key: _$ValueCellPropKeyPerson(this, #name))
          .store(changesOnly: true);
  ValueCell<int?> get age =>
      apply((value) => value.age, key: _$ValueCellPropKeyPerson(this, #age))
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

/// Extends ValueCell with accessors for Person properties
extension PersonCellExtensionN on ValueCell<Person?> {
  ValueCell<String?> get name =>
      apply((value) => value?.name, key: _$ValueCellPropKeyPersonN(this, #name))
          .store(changesOnly: true);
  ValueCell<int?> get age =>
      apply((value) => value?.age, key: _$ValueCellPropKeyPersonN(this, #age))
          .store(changesOnly: true);
}

class _$ValueCellPropKeyPersonN {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyPersonN(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPersonN &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Person properties
extension PersonMutableCellExtension on MutableCell<Person> {
  MutableCell<String> get name => mutableApply((value) => value.name, (p) {
        final $value = value;
        value = Person(
          name: p,
          age: $value.age,
        );
      }, key: _$MutableCellPropKeyPerson(this, #name), changesOnly: true);
  MutableCell<int?> get age => mutableApply((value) => value.age, (p) {
        final $value = value;
        value = Person(
          name: $value.name,
          age: p,
        );
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

bool _$PersonEquals(Person a, Object b) =>
    identical(a, b) || (b is Person && a.name == b.name && a.age == b.age);
int _$PersonHashCode(Person o) => Object.hashAll([
      o.name,
      o.age,
    ]);
'''
)
class Person {
  final String name;
  final int? age;

  Person({
    required this.name,
    required this.age
  });
}