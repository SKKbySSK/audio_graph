/// IdManager is used by internal classes
class IdManager {
  static final _counter = <String, int>{};

  static int generate(String key) {
    if (!_counter.containsKey(key)) {
      _counter[key] = 0;
    }

    return _counter[key]++;
  }
}
