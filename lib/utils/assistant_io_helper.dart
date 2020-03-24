import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssistantIOHelper<T> {
  final String _boxName;

  static final int invalidIndex = -1;

  AssistantIOHelper(this._boxName);

  Box openBox() => Hive.box(_boxName);

  void addElem(T elem) async {
    Box infoBox = openBox();
    await infoBox.add(elem);
  }

  void updateElem(T newElem, int index) async {
    Box infoBox = openBox();
    await infoBox.putAt(index, newElem);
  }

  T getAt(int index) {
    Box infoBox = openBox();
    return infoBox.getAt(index) as T;
  }

  Future<void> deleteAt(int index) async {
    Box infoBox = openBox();
    await infoBox.deleteAt(index);
  }

  ValueListenable getListenable() {
    return openBox().listenable();
  }

  bool isBoxEmpty() {
    return openBox().isEmpty;
  }

  Future<void> clear() async {
    await openBox().clear();
  }

  Iterable<T> getAll() {
    var box = openBox();
    return List<T>.from(box.values);
  }
}
