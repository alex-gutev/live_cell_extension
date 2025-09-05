import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that accessors are generated on the ValueCell extension even if the
// class does not have a constructor with field formal parameters, provided
// `mutable` is `false`.

@ShouldGenerate(
  r'''
/// Extends ValueCell with accessors for MyClass2 properties
extension MyClass2CellExtension on ValueCell<MyClass2> {
  ValueCell<int> get a => apply(
    (value) => value.a,
    key: _$ValueCellPropKeyMyClass2(this, #a),
  ).store(changesOnly: true);
  ValueCell<int> get b => apply(
    (value) => value.b,
    key: _$ValueCellPropKeyMyClass2(this, #b),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyMyClass2 {
  _$ValueCellPropKeyMyClass2(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyMyClass2 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$MyClass2Equals(MyClass2 a, Object b) =>
    identical(a, b) || (b is MyClass2 && a.a == b.a && a.b == b.b);
int _$MyClass2HashCode(MyClass2 o) => Object.hashAll([o.a, o.b]);
'''
)
@CellExtension()
class MyClass2 {
  final int a;
  final int b;

  MyClass2(int c) : a = c + c, b = c * c;
}