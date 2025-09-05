import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@CellExtension(
    nullable: true,
    mutable: true
)
@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Person5 properties
extension Person5CellExtension on ValueCell<Person5> {
  ValueCell<String> get name => apply(
    (value) => value.name,
    key: _$ValueCellPropKeyPerson5(this, #name),
  ).store(changesOnly: true);
  ValueCell<int?> get age => apply(
    (value) => value.age,
    key: _$ValueCellPropKeyPerson5(this, #age),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson5 {
  _$ValueCellPropKeyPerson5(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson5 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends ValueCell with accessors for Person5 properties
extension Person5CellExtensionN on ValueCell<Person5?> {
  ValueCell<String?> get name => apply(
    (value) => value?.name,
    key: _$ValueCellPropKeyPerson5N(this, #name),
  ).store(changesOnly: true);
  ValueCell<int?> get age => apply(
    (value) => value?.age,
    key: _$ValueCellPropKeyPerson5N(this, #age),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson5N {
  _$ValueCellPropKeyPerson5N(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson5N &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Person5 properties
extension Person5MutableCellExtension on MutableCell<Person5> {
  MutableCell<String> get name => mutableApply(
    (value) => value.name,
    (p) {
      final $value = value;
      value = Person5(name: p, age: $value.age);
    },
    key: _$MutableCellPropKeyPerson5(this, #name),
    changesOnly: true,
  );
  MutableCell<int?> get age => mutableApply(
    (value) => value.age,
    (p) {
      final $value = value;
      value = Person5(name: $value.name, age: p);
    },
    key: _$MutableCellPropKeyPerson5(this, #age),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyPerson5 {
  _$MutableCellPropKeyPerson5(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyPerson5 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person5Equals(Person5 a, Object b) =>
    identical(a, b) || (b is Person5 && a.name == b.name && a.age == b.age);
int _$Person5HashCode(Person5 o) => Object.hashAll([o.name, o.age]);
'''
)
class Person5 {
  final String name;
  final int? age;

  Person5({
    required this.name,
    required this.age
  });
}