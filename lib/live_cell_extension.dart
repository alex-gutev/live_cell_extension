library live_cell_extension;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/cell_extension_generator.dart';
import 'src/cell_widget_generator.dart';

Builder generateCellExtension(BuilderOptions options) {
  return SharedPartBuilder(
      [CellExtensionGenerator()],
      'cell_extension_generator'
  );
}

Builder generateCellWidgets(BuilderOptions options) {
  return SharedPartBuilder(
    [CellWidgetGenerator()],
    'cell_widget_generator'
  );
}