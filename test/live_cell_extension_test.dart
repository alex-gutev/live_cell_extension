import 'package:live_cell_extension/src/cell_extension_generator.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  initializeBuildLogTracking();

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
        'test/src',
        'computed_properties.dart'
    ),
    CellExtensionGenerator(),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
        'test/src',
        'mutable_properties.dart'
    ),
    CellExtensionGenerator(),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
        'test/src',
        'unnamed_constructor_params.dart'
    ),
    CellExtensionGenerator(),
  );
}