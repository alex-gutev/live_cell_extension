import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@CellExtension(
    nullable: true,
    mutable: true
)
@ShouldGenerate(
    r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person?> {
  ValueCell<String?> get name =>
      apply((value) => value?.name, key: _$ValueCellPropKeyPerson(this, #name))
          .store(changesOnly: true);
  ValueCell<int?> get age =>
      apply((value) => value?.age, key: _$ValueCellPropKeyPerson(this, #age))
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

// Extends MutableCell with accessors for Person properties
extension PersonMutableCellExtension on MutableCell<Person> {
  static Person _copyWith(
    Person $instance, {
    String? name,
    int? age,
  }) {
    return Person(
      name: name ?? $instance.name,
      age: age ?? $instance.age,
    );
  }

  MutableCell<String> get name => mutableApply((value) => value.name, (p) {
        value = _copyWith(value, name: p);
      }, key: _$MutableCellPropKeyPerson(this, #name), changesOnly: true);
  MutableCell<int?> get age => mutableApply((value) => value.age, (p) {
        value = _copyWith(value, age: p);
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