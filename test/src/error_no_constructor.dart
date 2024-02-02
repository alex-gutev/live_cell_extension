import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an exception is thrown if CellExtension(mutable: true) is applied
// to a class a constructor that does not accept any field formal parameters

@ShouldThrow(
    'The constructor of class MyClass does not have any field formal parameters.',
    todo: 'Add field formal parameters to the constructor of MyClass or remove '
        '`mutable: true` from the CellExtension annotation.'
)
@CellExtension(mutable: true)
class MyClass {
  final int a;
  final int b;

  MyClass(int c) : a = c + c, b = c * c;
}