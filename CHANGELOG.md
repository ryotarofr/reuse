## 2025/9/7

`clas Objects` の内部メソッド `keys`, `values`, `entries` に
関数呼び出しの微小なオーバーヘッドを完全に取り除くための取り組みを実施。

```dart
//before
static List<K> keys<K extends Object, V>(Map<K, V> map) => map.keys.toList();

//after
static Iterable<K> keys<K extends Object, V>(Map<K, V> map) => map.keys;
```