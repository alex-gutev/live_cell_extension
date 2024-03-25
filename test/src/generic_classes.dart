import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(
r'''
/// Extends ValueCell with accessors for Wrapper1 properties
extension Wrapper1CellExtension<T> on ValueCell<Wrapper1<T>> {
  ValueCell<T> get wrappedValue => apply((value) => value.wrappedValue,
          key: _$ValueCellPropKeyWrapper1(this, #wrappedValue))
      .store(changesOnly: true);
  ValueCell<int> get wrapperId => apply((value) => value.wrapperId,
          key: _$ValueCellPropKeyWrapper1(this, #wrapperId))
      .store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper1 {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyWrapper1(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper1 &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
'''
)
@CellExtension()
class Wrapper1<T> {
  final T wrappedValue;
  final int wrapperId;

  const Wrapper1({
    required this.wrappedValue,
    required this.wrapperId
  });
}


@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Wrapper2 properties
extension Wrapper2CellExtension<T extends List<dynamic>>
    on ValueCell<Wrapper2<T>> {
  ValueCell<T> get wrappedValue => apply((value) => value.wrappedValue,
          key: _$ValueCellPropKeyWrapper2(this, #wrappedValue))
      .store(changesOnly: true);
  ValueCell<int> get wrapperId => apply((value) => value.wrapperId,
          key: _$ValueCellPropKeyWrapper2(this, #wrapperId))
      .store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper2 {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyWrapper2(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper2 &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
'''
)
@CellExtension()
class Wrapper2<T extends List> {
  final T wrappedValue;
  final int wrapperId;

  const Wrapper2({
    required this.wrappedValue,
    required this.wrapperId
  });
}


@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Wrapper3 properties
extension Wrapper3CellExtension<T extends List<dynamic>?>
    on ValueCell<Wrapper3<T>> {
  ValueCell<T> get wrappedValue => apply((value) => value.wrappedValue,
          key: _$ValueCellPropKeyWrapper3(this, #wrappedValue))
      .store(changesOnly: true);
  ValueCell<int> get wrapperId => apply((value) => value.wrapperId,
          key: _$ValueCellPropKeyWrapper3(this, #wrapperId))
      .store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper3 {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyWrapper3(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper3 &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
'''
)
@CellExtension()
class Wrapper3<T extends List?> {
  final T wrappedValue;
  final int wrapperId;

  const Wrapper3({
    required this.wrappedValue,
    required this.wrapperId
  });
}


@ShouldGenerate(
    r'''
/// Extends ValueCell with accessors for Wrapper4 properties
extension Wrapper4CellExtension<T extends Object, U extends List<dynamic>>
    on ValueCell<Wrapper4<T, U>> {
  ValueCell<T> get wrappedValue1 => apply((value) => value.wrappedValue1,
          key: _$ValueCellPropKeyWrapper4(this, #wrappedValue1))
      .store(changesOnly: true);
  ValueCell<U> get wrappedValue2 => apply((value) => value.wrappedValue2,
          key: _$ValueCellPropKeyWrapper4(this, #wrappedValue2))
      .store(changesOnly: true);
  ValueCell<int> get wrapperId => apply((value) => value.wrapperId,
          key: _$ValueCellPropKeyWrapper4(this, #wrapperId))
      .store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper4 {
  final ValueCell _cell;
  final Symbol _prop;
  _$ValueCellPropKeyWrapper4(this._cell, this._prop);
  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper4 &&
      _cell == other._cell &&
      _prop == other._prop;
  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}
'''
)
@CellExtension()
class Wrapper4<T extends Object, U extends List> {
  final T wrappedValue1;
  final U wrappedValue2;
  final int wrapperId;

  const Wrapper4({
    required this.wrappedValue1,
    required this.wrappedValue2,
    required this.wrapperId
  });
}