import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that accessors are generated on the ValueCell extension even if the
// class does not have a constructor with field formal parameters, provided
// `mutable` is `false`.

@ShouldGenerate(
  r'''
/// Extends ValueCell with accessors for MyClass properties
extension MyClassCellExtension on ValueCell<MyClass> {
  ValueCell<int> get a =>
      apply((value) => value.a, key: _$ValueCellPropKeyMyClass(this, #a))
          .store(changesOnly: true);
  ValueCell<int> get b =>
      apply((value) => value.b, key: _$ValueCellPropKeyMyClass(this, #b))
          .store(changesOnly: true);
}

class _$ValueCellPropKeyMyClass {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyMyClass(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyMyClass &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$MyClassEquals(MyClass a, Object b) =>
    identical(a, b) || (b is MyClass && a.a == b.a && a.b == b.b);
int _$MyClassHashCode(MyClass o) => Object.hashAll([
      o.a,
      o.b,
    ]);
'''
)
@CellExtension()
class MyClass {
  final int a;
  final int b;

  MyClass(int c) : a = c + c, b = c * c;
}