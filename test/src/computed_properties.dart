import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

// Test that an extension is generated for every public and final property of a class

@ShouldGenerate(
  r'''
// Extends ValueCell with accessors for Person properties
extension PersonCellExtension on ValueCell<Person> {
  ValueCell<String> get firstName => apply((value) => value.firstName,
          key: _$ValueCellPropKeyPerson(this, #firstName))
      .store(changesOnly: true);
  ValueCell<String> get lastName => apply((value) => value.lastName,
          key: _$ValueCellPropKeyPerson(this, #lastName))
      .store(changesOnly: true);
  ValueCell<int> get age =>
      apply((value) => value.age, key: _$ValueCellPropKeyPerson(this, #age))
          .store(changesOnly: true);
  ValueCell<String> get fullName => apply((value) => value.fullName,
          key: _$ValueCellPropKeyPerson(this, #fullName))
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
''',
  expectedLogItems: [
    'value is reserved for ValueCell properties. Accessor not be generated.',
    'previous is reserved for ValueCell properties. Accessor not be generated.'
  ]
)
@CellExtension()
class Person {
  final String firstName;
  final String lastName;
  final int age;

  String get fullName => '$firstName $lastName';

  // Accessors not generated for variable and private properties

  String? address;
  final int _id;

  // Accessors not generated for properties with reserved names

  final String value;
  final Person? previous;

  // Accessors not generated for static properties

  static final key = 'personKey';

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.value = '',
    this.previous = null,
    int id = 0,
  }) : _id = id;
}