import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@CellExtension(
  nullable: true
)
@ShouldGenerate(
  r'''
/// Extends ValueCell with accessors for Person4 properties
extension Person4CellExtension on ValueCell<Person4> {
  ValueCell<String> get name => apply(
    (value) => value.name,
    key: _$ValueCellPropKeyPerson4(this, #name),
  ).store(changesOnly: true);
  ValueCell<int?> get age => apply(
    (value) => value.age,
    key: _$ValueCellPropKeyPerson4(this, #age),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson4 {
  _$ValueCellPropKeyPerson4(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson4 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends ValueCell with accessors for Person4 properties
extension Person4CellExtensionN on ValueCell<Person4?> {
  ValueCell<String?> get name => apply(
    (value) => value?.name,
    key: _$ValueCellPropKeyPerson4N(this, #name),
  ).store(changesOnly: true);
  ValueCell<int?> get age => apply(
    (value) => value?.age,
    key: _$ValueCellPropKeyPerson4N(this, #age),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyPerson4N {
  _$ValueCellPropKeyPerson4N(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyPerson4N &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Person4Equals(Person4 a, Object b) =>
    identical(a, b) || (b is Person4 && a.name == b.name && a.age == b.age);
int _$Person4HashCode(Person4 o) => Object.hashAll([o.name, o.age]);
'''
)
class Person4 {
  final String name;
  final int? age;

  Person4({
    required this.name,
    required this.age
  });
}