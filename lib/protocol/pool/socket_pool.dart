import 'dart:io';

import 'package:observable/observable.dart';

SocketPool pool = SocketPool();

class SocketPool with ChangeNotifier {
  Map<String, List<WebSocket>> _pool = {};
  containsKey(String key) => _pool.containsKey(key);
  putIfAbsent(String key, List<WebSocket> Function() ifAbsent) =>
      _pool.putIfAbsent(key, ifAbsent);
  get keys => _pool.keys;
  get values => _pool.values;
  get length => _pool.length;
  get isEmpty => _pool.isEmpty;
  get isNotEmpty => _pool.isNotEmpty;
  clear() {
    _pool.clear();
    notifyChange();
  }

  remove(String key) {
    var re = _pool.remove(key);
    notifyChange();
    return re;
  }

  removeWhere(bool Function(String s, List<WebSocket> list) predicate) {
    _pool.removeWhere(predicate);
    notifyChange();
  }

  forEach(void Function(String s, List<WebSocket> list) f) => _pool.forEach(f);
}
