library live_cell_extension;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/cell_extension_generator.dart';

Builder generateCellExtension(BuilderOptions options) {
  return SharedPartBuilder(
      [CellExtensionGenerator()],
      'cell_extension_generator'
  );
}