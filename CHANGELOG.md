## 2025/9/7

`clas Objects` の内部メソッド `keys`, `values`, `entries` に
関数呼び出しの微小なオーバーヘッドを完全に取り除くための取り組み

```dart
/// objects.dart
//before
static List<K> keys<K extends Object, V>(Map<K, V> map) => map.keys.toList();

//after
static Iterable<K> keys<K extends Object, V>(Map<K, V> map) => map.keys;
```

---

`clas Objects` の内部メソッド `_indexedEntries` の戻り値を変更。

`MapEntry<...>` が `(...)` に変変更。

これは [Records](https://dart.dev/language/records) 型というようで、ほかの言語のタプルと同じ。

`MapEntry` 作成分の追加オーバーヘッドがなくなる。

```dart
/// objects.dart
//before
static Iterable<MapEntry<int, MapEntry<K, V>>> _indexedEntries<K, V>(
    Map<K, V> map,
) sync* {
  int index = 0;
  for (final entry in map.entries) {
    yield MapEntry(index++, entry);
  }
}

//after
static Iterable<(int, MapEntry<K, V>)> _indexedEntries<K, V>(Map<K, V> map) =>
    entries(map).indexed.map((e) => (e.$1, e.$2));
```