import 'dart:collection';
import 'package:collection/collection.dart';

class RequiredMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map;

  RequiredMap(this._map);

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);

  Map<K, V> pick(List<K> fields) {
    final result = <K, V>{};
    for (final field in fields) {
      final value = this[field];
      if (value != null) {
        result[field] = value;
      }
    }
    return result;
  }
}

/// A utility class for working with Map objects.
///
/// This class is written using the recommended syntax for Dart v3.0 and later.
/// The generic type [<K extends Object, V>] used throughout ensures that
///  K is a type that does not permit null values within Dart's type system.
class Objects {
  /// Returns a lazy iterable of tuples, each containing the index and
  /// the corresponding map entry.
  ///
  /// For record types, see below.
  /// > https://dart.dev/language/records
  ///
  /// Example:
  /// ```dart
  /// final myMap = {'hoge': 1, 'fuga': 2, 'piyo': 3};
  /// final indexedEntries = Objects._indexedEntries(myMap);
  /// print(indexedEntries)
  /// // ((0, MapEntry('hoge', 1)), (1, MapEntry('fuga', 2)), (2, MapEntry('piyo', 3)))
  /// ```
  static Iterable<(int, MapEntry<K, V>)> _indexedEntries<K extends Object, V>(
    Map<K, V> map,
  ) => entries(map).indexed.map((e) => (e.$1, e.$2));

  /// Get the keys of the map
  ///
  /// `K` must extend `Object` to ensure non-nullability
  /// This effectively becomes a constraint that “K is not a null-allowed type.”
  ///
  /// Example:
  /// ```dart
  /// final myMap = {'name': 'Hoge', 'age': 77};
  /// final keys = Objects.keys(myMap);
  /// print(keys)
  /// // ('name', 'age')
  /// ```
  static Iterable<K> keys<K extends Object, V>(Map<K, V> map) => map.keys;

  /// Get the values of the map
  static Iterable<V> values<K, V>(Map<K, V> map) => map.values;

  /// Get the entries of the map
  ///
  /// `K` must extend `Object` to ensure non-nullability
  /// This effectively becomes a constraint that “K is not a null-allowed type.”
  ///
  /// Example:
  /// ```dart
  /// final myMap = {'name': 'Hoge', 'age': 77};
  /// final entries = Objects.entries(myMap);
  /// print(entries)
  /// // (MapEntry('name', 'Hoge'), MapEntry('age', 77))
  /// ```
  static Iterable<MapEntry<K, V>> entries<K extends Object, V>(Map<K, V> map) =>
      map.entries;

  /// Create a map from entries
  ///
  /// Example:
  /// ```dart
  /// final entries = Objects.entries(myMap);
  /// final newMap = Objects.fromEntries(entries);
  /// print(newMap)
  /// // {'name': 'Hoge', 'age': 77}
  /// ```
  static Map<K, V> fromEntries<K, V>(Iterable<MapEntry<K, V>> entries) =>
      Map.fromEntries(entries);

  /// Map over the map's entries
  ///
  /// The mapper function receives both the entry and its index.
  /// Example:
  /// ```dart
  /// final myMap = {'name': 'Hoge', 'age': 77};
  /// final mapped = Objects.map<String, dynamic, String>(
  ///   myMap,
  ///   (entry, index) => '${entry.value} (index: $index)',
  /// );
  /// print(mapped);
  /// // {'name': 'Hoge (index: 0)', 'age': '77 (index: 1)'}
  /// ```
  static Map<K, R> map<K extends Object, V, R>(
    Map<K, V> map,
    R Function(MapEntry<K, V> entry, int index) mapper,
  ) => fromEntries(
    _indexedEntries(
      map,
    ).map((record) => MapEntry(record.$2.key, mapper(record.$2, record.$1))),
  );

  /// Filter the map's entries
  ///
  /// The predicate function receives both the entry and its index.
  /// Example:
  /// ```dart
  /// final myMap = {'name': 'Hoge', 'age': 77, 'city': 'Tokyo', 'country': 'Japan'};
  /// final filtered = Objects.filter(
  ///   myMap,
  ///   (entry, index) => entry.value is String && entry.value.toString().length > 4,
  /// );
  /// print(filtered);
  /// // {'country': 'Japan', 'city': 'Tokyo'}
  /// ```
  static Map<K, V> filter<K extends Object, V>(
    Map<K, V> map,
    bool Function(MapEntry<K, V> entry, int index) predicate,
  ) => fromEntries(
    _indexedEntries(map)
        .where((idxEntry) => predicate(idxEntry.$2, idxEntry.$1))
        .map((idxEntry) => idxEntry.$2),
  );

  /// Find the first entry that matches the predicate
  ///
  /// The predicate function receives both the entry and its index.
  /// Example:
  /// ```dart
  /// final myMap = {'name': 'Hoge', 'age': 77, 'city': 'Tokyo', 'country': 'Japan'};
  /// final found = Objects.find(myMap, (entry, index) => entry.value == 77);
  /// print(found);
  /// // MapEntry('age', 77)
  /// ```
  static MapEntry<K, V>? find<K extends Object, V>(
    Map<K, V> map,
    bool Function(MapEntry<K, V> entry, int index) predicate,
  ) => _indexedEntries(
    map,
  ).firstWhereOrNull((idxEntry) => predicate(idxEntry.$2, idxEntry.$1))?.$2;

  /// Check if all values are non-null and return a RequiredMap
  ///
  /// If any value is null, return null
  /// Example:
  /// ```dart
  /// final Map<String, int?> nullableMap = {'a': 1, 'b': 2, 'c': null};
  /// final requiredMap = Objects.required(nullableMap);
  /// print(requiredMap); // null (because 'c' is null)
  /// final Map<String, int?> nonNullMap = {'a': 1, 'b': 2, 'c': 3};
  /// final requiredMap2 = Objects.required(nonNullMap);
  /// print(requiredMap2); // RequiredMap({'a': 1, 'b': 2, 'c': 3})
  /// ```
  static RequiredMap<K, V>? required<K, V>(Map<K, V?> map) =>
      /// The argument type `Map<K, V?> map` adopts the most common form.
      map.values.contains(null) ? null : RequiredMap<K, V>(map.cast<K, V>());
  static Map<K, V>? pick<K, V>(Map<K, V?> map, dynamic fields) {
    if (fields is K) {
      // For a single field
      final value = map[fields];
      if (value == null) {
        return null;
      }
      return {fields: value};
    } else if (fields is List<K>) {
      // for lists
      final result = <K, V>{};
      for (final field in fields) {
        final value = map[field];
        if (value == null) {
          return null;
        }
        result[field] = value;
      }
      return result;
    } else {
      throw ArgumentError('fields must be either K or List<K>');
    }
  }
}

extension MapObjectsExtension<K, V> on Map<K, V> {
  /// Map over the map's values
  Map<K, R> mapValues<R>(R Function(MapEntry<K, V> entry, int index) mapper) {
    return Objects.map(this, mapper);
  }

  /// Filter the map's entries
  Map<K, V> filterEntries(
    bool Function(MapEntry<K, V> entry, int index) predicate,
  ) {
    return Objects.filter(this, predicate);
  }

  /// Find the first entry that matches
  MapEntry<K, V>? findEntry(
    bool Function(MapEntry<K, V> entry, int index) predicate,
  ) {
    return Objects.find(this, predicate);
  }
}

// nullableなMapに対して拡張を提供
extension NullableMapExtension<K, V> on Map<K, V?> {
  /// すべての値がnon-nullかチェックし、non-nullのMapを返す
  RequiredMap<K, V>? get required => Objects.required(this);

  /// 指定されたフィールドを抽出（すべて存在する場合のみ）
  Map<K, V>? pick(List<K> fields) => Objects.pick(this, fields);
}

// non-nullableなMapに対しても安全にpickを使えるようにする拡張
extension MapPickExtension<K, V> on Map<K, V> {
  /// 指定されたフィールドを抽出
  Map<K, V> pick(List<K> fields) {
    final result = <K, V>{};
    for (final field in fields) {
      final value = this[field];
      if (value != null) {
        result[field] = value;
      }
    }
    return result;
  }
}

typedef DataRecord = ({int a, int b, int? c});

// Example usage
void main() {
  final myMap = {
    'name': 'John',
    'age': 30,
    'city': 'Tokyo',
    'country': 'Japan',
  };

  // Get keys
  // DataRecord myMap2 = (a: 1, b: 2, c: null);
  final mapKeys = Objects.keys(myMap);
  print('Keys: $mapKeys'); // [name, age, city, country]

  // Get values
  final mapValues = Objects.values(myMap);
  print('Values: $mapValues'); // [John, 30, Tokyo, Japan]

  // Map over entries
  final mapped = Objects.map<String, dynamic, String>(
    myMap,
    (entry, index) => '${entry.value} (index: $index)',
  );
  print('Mapped: $mapped');

  // Filter entries
  final filtered = Objects.filter(
    myMap,
    (entry, index) =>
        entry.value is String && entry.value.toString().length > 4,
  );
  print('Filtered: $filtered'); // {country: Japan, city: Tokyo}

  // Find entry
  final found = Objects.find(myMap, (entry, index) => entry.value == 31);
  print('Found: $found'); // MapEntry(age: 30)

  // Using extension methods
  final mapped2 = myMap.mapValues((entry, index) => '${entry.value}!');
  print('Mapped with extension: $mapped2');

  // Required example
  final Map<String, int?> nullableMap = {'a': 1, 'b': 2, 'c': null};
  // DataRecord nullableMap = (a: 1, b: 2, c: null);

  final requiredMap = Objects.required(nullableMap)?.pick(['a', 'b']);
  print('Required map: $requiredMap'); // null (because 'c' is null)

  final nonNullMap = {'a': 1, 'b': 2, 'c': 3};

  final requiredMap2 = Objects.required(nonNullMap)?.pick(['a', 'b']);
  print('Required map 2: $requiredMap2'); // {a: 1, b: 2}
}
