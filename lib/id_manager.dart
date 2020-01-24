class IdManager {
  static Map<String, int> _counter = Map();

  static int generate(String key) {
    if (!_counter.containsKey(key)) {
      _counter[key] = 0;
    }

    return _counter[key]++;
  }
}
