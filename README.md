This package provides a code generator which generates extensions on `ValueCell` and `MutableCell`,
from the [live_cells](https://pub.dev/packages/live_cells) package, that provide accessors for
the class's properties.

## Features

+ Extends `ValueCell` and `MutableCell` with accessors for annotated class. 
+ Options for whether to generated `MutableCell` accessors or not.
+ Allows you to write the following:

  ```dart
  final prop = cell.prop;
  ```
  
  instead of:

  ```dart
  final prop = ValueCell.computed(() => cell().prop);
  ```
+ Allows you to write the following:

  ```dart
  final prop = cell.prop;
  ```
  
  instead of:

  ```dart
  final prop = MutableCell.computed(() => cell().prop, (value) {
    cell.value = MyClass(prop: value);
  });
  ```

## Getting started

To use this package you'll need to add the following to the `dependencies` of your `pubspec.yaml`:

```yaml
dependencies:
  live_cells: ^0.10.0
  ...
```

You'll also need to add this package and `build_runner` to the `dev_dependencies` of your 
`pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner:
  live_cell_extension: ^0.1.0
```

See the example in the `example` directory for more details on how to setup your project.

## Usage

Annotate your classes with `CellExtension()` from the `live_cells` package:

```dart
import 'package:live_cells/live_cells.dart';

part 'person.g.dart';

@CellExtension()
class Person {
  final String firstName;
  final String lastName;
  final int age;
  
  String get fullName => '$firstName $lastName';
  
  const Person({
    this.firstName,
    this.lastName,
    this.age
  });
}
```

Then run the following command:

```shell
flutter pub run build_runner build
```

This will generate an extension for `ValueCell<Person>`, called `PersonCellExtension` which
provides the properties of the `Person` class:

* `firstName`
* `lastName`
* `age`
* `fullName`

This allows you to access properties of `Person` objects held on the cell instance.

For example say you have a `ValueCell` holding a `Person`:

```dart
final ValueCell<Person> person;
```

The properties of the `Person` held in the cell can be accessed directly using:

```dart
final firstName = person.firstName;
final lastName = person.lastName;
final fullName = person.fullName;
final age = person.age;
```

Each generated property, of the generated `ValueCell` extension, returns a `ValueCell` that accesses
the value of the property of the instance of the class held in the cell, on which the property is
referenced. The returned `ValueCell`'s are computed cells which update their own values whenever the
values of the referenced properties of the instance change.

`person.firstName` is in effect equivalent to the following:

```dart
ValueCell.computed(() => person().firstName);
```

Example:

```dart
final fullName = person.fullName();
final age = person.age();

ValueCell.watch(() {
  print('Person ${fullName()} - ${age()}');
});

// Prints: Person John Smith - 25
person = Person(firstName: 'John', lastName: 'Smith', age: 25);

// Prints: Person John Smith - 25
person = Person(firstName: 'John', lastName: 'Smith', age: 25);
```

**NOTE**:

+ Only accessors for public properties are generated.
+ Only accessors for `final` properties and properties without a setter are generated.

  This restriction exists because modifying a non final property directly on the instance will not
  notify the observers of the cells created using the generated properties, which may lead to
  confusion.

  To allow modifying individual properties use `CellExtension(mutable: true)` more on this in the
  next section.
+ The properties of the class must not have the same name as an existing property on `ValueCell`
  provided by the `live_cells` package. Accessors are not generated for such properties.

## Mutable properties

When a class is annotated with `CellExtension(mutable: true)` an extension on `MutableCell` is
also generated. The generated extension is like the extension generated for `ValueCell` but the
generated property accessors return `MutableCell`'s instead of `ValueCell`'s. This allows individual
properties to be modified via the `MutableCell`'s.

Using the class from the previous example:

```dart
import 'package:live_cells/live_cells.dart';

part 'person.g.dart';

@CellExtension(mutable: true)
class Person {
  final String firstName;
  final String lastName;
  final int age;
  
  String get fullName => '$firstName $lastName';
  
  const Person({
    this.firstName,
    this.lastName,
    this.age
  });
}
```

Accessors for the following properties will be generated:

+ `firstName`
+ `lastName`
+ `age`

Each generated accessor returns a `MutableCell` which when set, set's the value of the property.
**NOTE**, this does not actually modify the instance held in the cell on which the property was
accessed but creates a new instance, using the class's unnamed constructor, and assigns the cell's
value to it. That's why, as you may have noticed, an accessor for `fullName` is not generated.

Example:

```dart
final person = MutableCell(Person(firstName: 'John', lastName: 'Smith', age: 25));

final firstName = person.firstName;
final lastName = person.lastName;
final age = person.age;

final fullName = person.fullName;

ValueCell.watch(() {
  print('Person ${fullName()} - ${age()}');
});

// Prints: Person John Smith 30
age.value = 30;

// Prints: Person Jane Doe 30
MutableCell.batch(() {
  firstName.value = 'Jane';
  lastName.value = 'Doe';
});
```

**NOTE**:

1. The restriction on the properties being final or without a setter still applies.

   `mutable: true` allows the property values to be set via the `MutableCell`'s returned by the
   properties of the generated extension, however directly modifying a property on the instance will
   not notify the observers of the cell even if `mutable: true` is provided in the annotation.
2. `MutableCell` accessors are generated only for which there is a field formal parameter in the
   unnamed constructor of the class. That's why an accessor for `fullName` is not generated.
3. A `ValueCell` extension is still generated even when `mutable: true` is given. That's why in the
   above you can still access the `fullName` property directly on the cell and observe it, but you
   cannot set its value directly as you can for `firstName`, `lastName` and `age`.
4. The properties of the class must not have the same name as an existing property on either
   `ValueCell` or `MutableCell` provided by the `live_cells` package. 
   Accessors are not generated for such properties.

## Additional information

Check the example in the `example/` directory for a complete example from setting up the project's
dependencies to a demonstration of the generated property accessors.

If you discover any issues or have any feature requests, please open an issue on the package's Github
repository.
