## 0.4.2

* Fix issues with generating cell extensions for classes which override `hashCode`.
* Fix issues with warnings in generated mutable cell extensions.

## 0.4.1

* Increase `live_cells_core` dependency version to 0.13.0

## 0.4.0

* Add `changesOnly` to the generated cell accessors.

  This ensures that when only a single property is modified, only the observers of the cell,
  which accesses that property, are notified.

## 0.3.0

No new user facing features:

* Add generators for `GenerateCellWidgets` and `GenerateValueExtensions` annotations.

## 0.2.0

* Add support for `name` and `mutableName` properties of `CellExtension` annotation.

## 0.1.5

* Fix typos in README.

## 0.1.4

* Improve README.

## 0.1.3

* Fix issues with package analysis:

  * Remove dependencies on Flutter
  * Replace live_cells dependency with live_cell_annotations

## 0.1.2

* Fix issues with pubspec.

## 0.1.1

* Remove flutter dependency from pubspec.

## 0.1.0

Initial Release:

* Supports generating ValueCell/MutableCell property accessors for classes annotated with
  `@CellAnnotation()`.
