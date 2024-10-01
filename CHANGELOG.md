## 0.5.7

* Fix issues with extensions on class with inheritance.

## 0.5.6

* Remove `live_cells_core` dependency.

  In future `live_cell_extension` will be tied to a specific `live_cells_core` version via
  the `live_cell_annotation` dependency.

## 0.5.5

* Increase `live_cells_core` dependency version to `0.23.0`

## 0.5.4

No new user-facing features:

* Add support for `stateMixins` property of `WidgetSpec` annotation.

## 0.5.3

* Increase `live_cells_core` dependency version to `0.22.0`

## 0.5.2

* Increase `live_cells_core` dependency version to `0.21.0`

## 0.5.1

Bug Fixes:

* Add support for `CellExtension` on generic classes.

## 0.5.0

* Add support for `nullable` property of `CellExtension` annotation.

## 0.4.13

* Update live_cells_core dependency version to 0.19.0

## 0.4.12

* Update live_cells_core dependency version to 0.18.1

## 0.4.11

* Update live_cells_core dependency version to 0.17.0

## 0.4.10

* [Internal fix] Fix bug in widget wrapper generator, for widget classes with generic type arguments. 

## 0.4.9

* Update live_cells_core dependency to 0.16.0

## 0.4.8

* Revert dependency in example back to path dependency

## 0.4.7

* Remove flutter lints.

## 0.4.6

* Fix analysis issue

## 0.4.5

* Reduce `analyzer` dependency version back to 6.2.0

## 0.4.4

* Update `live_cells_core` dependency version to 0.15.0

## 0.4.3

* Update `live_cells_core` dependency version to 0.14.0

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
