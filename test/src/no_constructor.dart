import 'package:live_cells/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that accessors are generated on the ValueCell extension even if the
// class does not have a constructor with field formal parameters, provided
// `mutable` is `false`.

@ShouldGenerate(
  r'''
// Extends ValueCell with accessors for MyClass properties
extension MyClassCellExtension on ValueCell<MyClass> {
  ValueCell<int> get a => apply((value) => value.a);
  ValueCell<int> get b => apply((value) => value.b);
}
'''
)
@CellExtension()
class MyClass {
  final int a;
  final int b;

  MyClass(int c) : a = c + c, b = c * c;
}