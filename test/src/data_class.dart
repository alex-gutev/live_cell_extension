import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

bool myEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }

  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }

  return true;
}

@ShouldGenerate(
  r'''
bool _$TestDataClassEquals(TestDataClass a, Object b) =>
    identical(a, b) ||
    (b is TestDataClass &&
        a.field1 == b.field1 &&
        a.field2 == b.field2 &&
        myEqual(a.field3, b.field3));
int _$TestDataClassHashCode(TestDataClass o) =>
    Object.hashAll([o.field1, o.field2, hashAll(o.field3)]);
'''
)
@DataClass()
class TestDataClass {
  final int field1;
  final String field2;

  @DataField(
    equals: myEqual,
    hash: Object.hashAll
  )
  final List<int> field3;

  // This field should be ignored in both the generated comparator and hash
  // function
  int get field4 => field1 + 1;

  const TestDataClass({
    required this.field1,
    required this.field2,
    required this.field3
  });
}