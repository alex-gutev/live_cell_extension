import 'package:live_cell_annotations/live_cell_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(
r'''
/// Extends ValueCell with accessors for Wrapper1 properties
extension Wrapper1CellExtension<T> on ValueCell<Wrapper1<T>> {
  ValueCell<T> get wrappedValue => apply(
    (value) => value.wrappedValue,
    key: _$ValueCellPropKeyWrapper1(this, #wrappedValue),
  ).store(changesOnly: true);
  ValueCell<int> get wrapperId => apply(
    (value) => value.wrapperId,
    key: _$ValueCellPropKeyWrapper1(this, #wrapperId),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper1 {
  _$ValueCellPropKeyWrapper1(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper1 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Wrapper1 properties
extension Wrapper1MutableCellExtension<T> on MutableCell<Wrapper1<T>> {
  MutableCell<T> get wrappedValue => mutableApply(
    (value) => value.wrappedValue,
    (p) {
      final $value = value;
      value = Wrapper1(wrappedValue: p, wrapperId: $value.wrapperId);
    },
    key: _$MutableCellPropKeyWrapper1(this, #wrappedValue),
    changesOnly: true,
  );
  MutableCell<int> get wrapperId => mutableApply(
    (value) => value.wrapperId,
    (p) {
      final $value = value;
      value = Wrapper1(wrappedValue: $value.wrappedValue, wrapperId: p);
    },
    key: _$MutableCellPropKeyWrapper1(this, #wrapperId),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyWrapper1 {
  _$MutableCellPropKeyWrapper1(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyWrapper1 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Wrapper1Equals(Wrapper1 a, Object b) =>
    identical(a, b) ||
    (b is Wrapper1 &&
        a.wrappedValue == b.wrappedValue &&
        a.wrapperId == b.wrapperId);
int _$Wrapper1HashCode(Wrapper1 o) =>
    Object.hashAll([o.wrappedValue, o.wrapperId]);
'''
)
@CellExtension(mutable: true)
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
  ValueCell<T> get wrappedValue => apply(
    (value) => value.wrappedValue,
    key: _$ValueCellPropKeyWrapper2(this, #wrappedValue),
  ).store(changesOnly: true);
  ValueCell<int> get wrapperId => apply(
    (value) => value.wrapperId,
    key: _$ValueCellPropKeyWrapper2(this, #wrapperId),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper2 {
  _$ValueCellPropKeyWrapper2(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper2 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Wrapper2 properties
extension Wrapper2MutableCellExtension<T extends List<dynamic>>
    on MutableCell<Wrapper2<T>> {
  MutableCell<T> get wrappedValue => mutableApply(
    (value) => value.wrappedValue,
    (p) {
      final $value = value;
      value = Wrapper2(wrappedValue: p, wrapperId: $value.wrapperId);
    },
    key: _$MutableCellPropKeyWrapper2(this, #wrappedValue),
    changesOnly: true,
  );
  MutableCell<int> get wrapperId => mutableApply(
    (value) => value.wrapperId,
    (p) {
      final $value = value;
      value = Wrapper2(wrappedValue: $value.wrappedValue, wrapperId: p);
    },
    key: _$MutableCellPropKeyWrapper2(this, #wrapperId),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyWrapper2 {
  _$MutableCellPropKeyWrapper2(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyWrapper2 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Wrapper2Equals(Wrapper2 a, Object b) =>
    identical(a, b) ||
    (b is Wrapper2 &&
        a.wrappedValue == b.wrappedValue &&
        a.wrapperId == b.wrapperId);
int _$Wrapper2HashCode(Wrapper2 o) =>
    Object.hashAll([o.wrappedValue, o.wrapperId]);
'''
)
@CellExtension(mutable: true)
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
  ValueCell<T> get wrappedValue => apply(
    (value) => value.wrappedValue,
    key: _$ValueCellPropKeyWrapper3(this, #wrappedValue),
  ).store(changesOnly: true);
  ValueCell<int> get wrapperId => apply(
    (value) => value.wrapperId,
    key: _$ValueCellPropKeyWrapper3(this, #wrapperId),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper3 {
  _$ValueCellPropKeyWrapper3(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper3 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Wrapper3 properties
extension Wrapper3MutableCellExtension<T extends List<dynamic>?>
    on MutableCell<Wrapper3<T>> {
  MutableCell<T> get wrappedValue => mutableApply(
    (value) => value.wrappedValue,
    (p) {
      final $value = value;
      value = Wrapper3(wrappedValue: p, wrapperId: $value.wrapperId);
    },
    key: _$MutableCellPropKeyWrapper3(this, #wrappedValue),
    changesOnly: true,
  );
  MutableCell<int> get wrapperId => mutableApply(
    (value) => value.wrapperId,
    (p) {
      final $value = value;
      value = Wrapper3(wrappedValue: $value.wrappedValue, wrapperId: p);
    },
    key: _$MutableCellPropKeyWrapper3(this, #wrapperId),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyWrapper3 {
  _$MutableCellPropKeyWrapper3(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyWrapper3 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Wrapper3Equals(Wrapper3 a, Object b) =>
    identical(a, b) ||
    (b is Wrapper3 &&
        a.wrappedValue == b.wrappedValue &&
        a.wrapperId == b.wrapperId);
int _$Wrapper3HashCode(Wrapper3 o) =>
    Object.hashAll([o.wrappedValue, o.wrapperId]);
'''
)
@CellExtension(mutable: true)
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
  ValueCell<T> get wrappedValue1 => apply(
    (value) => value.wrappedValue1,
    key: _$ValueCellPropKeyWrapper4(this, #wrappedValue1),
  ).store(changesOnly: true);
  ValueCell<U> get wrappedValue2 => apply(
    (value) => value.wrappedValue2,
    key: _$ValueCellPropKeyWrapper4(this, #wrappedValue2),
  ).store(changesOnly: true);
  ValueCell<int> get wrapperId => apply(
    (value) => value.wrapperId,
    key: _$ValueCellPropKeyWrapper4(this, #wrapperId),
  ).store(changesOnly: true);
}

class _$ValueCellPropKeyWrapper4 {
  _$ValueCellPropKeyWrapper4(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$ValueCellPropKeyWrapper4 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

/// Extends MutableCell with accessors for Wrapper4 properties
extension Wrapper4MutableCellExtension<
  T extends Object,
  U extends List<dynamic>
>
    on MutableCell<Wrapper4<T, U>> {
  MutableCell<T> get wrappedValue1 => mutableApply(
    (value) => value.wrappedValue1,
    (p) {
      final $value = value;
      value = Wrapper4(
        wrappedValue1: p,
        wrappedValue2: $value.wrappedValue2,
        wrapperId: $value.wrapperId,
      );
    },
    key: _$MutableCellPropKeyWrapper4(this, #wrappedValue1),
    changesOnly: true,
  );
  MutableCell<U> get wrappedValue2 => mutableApply(
    (value) => value.wrappedValue2,
    (p) {
      final $value = value;
      value = Wrapper4(
        wrappedValue1: $value.wrappedValue1,
        wrappedValue2: p,
        wrapperId: $value.wrapperId,
      );
    },
    key: _$MutableCellPropKeyWrapper4(this, #wrappedValue2),
    changesOnly: true,
  );
  MutableCell<int> get wrapperId => mutableApply(
    (value) => value.wrapperId,
    (p) {
      final $value = value;
      value = Wrapper4(
        wrappedValue1: $value.wrappedValue1,
        wrappedValue2: $value.wrappedValue2,
        wrapperId: p,
      );
    },
    key: _$MutableCellPropKeyWrapper4(this, #wrapperId),
    changesOnly: true,
  );
}

class _$MutableCellPropKeyWrapper4 {
  _$MutableCellPropKeyWrapper4(this._cell, this._prop);

  final ValueCell _cell;

  final Symbol _prop;

  @override
  bool operator ==(other) =>
      other is _$MutableCellPropKeyWrapper4 &&
      _cell == other._cell &&
      _prop == other._prop;

  @override
  int get hashCode => Object.hash(runtimeType, _cell, _prop);
}

bool _$Wrapper4Equals(Wrapper4 a, Object b) =>
    identical(a, b) ||
    (b is Wrapper4 &&
        a.wrappedValue1 == b.wrappedValue1 &&
        a.wrappedValue2 == b.wrappedValue2 &&
        a.wrapperId == b.wrapperId);
int _$Wrapper4HashCode(Wrapper4 o) =>
    Object.hashAll([o.wrappedValue1, o.wrappedValue2, o.wrapperId]);
'''
)
@CellExtension(mutable: true)
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