## 2025/9/25

悪い型の作り方

`<K extends Object, V>` などのジェネリクス型を型エイリアスとして定義する。

```dart
typedef SafeKeyMap<K extends Object, V> = Map<K, V>;
typedef SafeEntry<K extends Object, V> = MapEntry<K, V>;
```

次のように使う。

```dart
SafeKeyMap<String?, int> nullableKeyMap = {}; // コンパイルエラー！
SafeKeyMap<String, int> normalMap = {}; // OK
```

混乱を招くコードの完成。

つまり、

型エイリアスは、
- 複雑な型を簡潔にする目的で使用
- 制約を強制する目的では使わない

---