import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that accessors are generated on the ValueCell extension even if the
// class does not have a constructor with field formal parameters, provided
// `mutable` is `false`.

@ShouldGenerate(
  r'''
// Extends ValueCell with accessors for MyClass properties
extension MyClassCellExtension on ValueCell<MyClass> {
  ValueCell<int> get a =>
      apply((value) => value.a, key: _$ValueCellPropKeyMyClass(this, 'a'));
  ValueCell<int> get b =>
      apply((value) => value.b, key: _$ValueCellPropKeyMyClass(this, 'b'));
}

class _$ValueCellPropKeyMyClass {
  final ValueCell _cell;
  final String _prop;
  _$ValueCellPropKeyMyClass(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyMyClass &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
'''
)
@CellExtension()
class MyClass {
  final int a;
  final int b;

  MyClass(int c) : a = c + c, b = c * c;
}