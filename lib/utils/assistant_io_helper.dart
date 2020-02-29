import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:job_search_assistant/models/job_application_info.dart';

class AssistantIOHelper {
  final String _boxName;

  static final int invalidIndex = -1;

  AssistantIOHelper(this._boxName) {
    if (!Hive.box(_boxName).isOpen) {
      Hive.openBox(_boxName);
    }
  }

  void addInfo(JobApplicationInfo info) async {
    Box infoBox = Hive.box(_boxName);
    await infoBox.add(info);
  }

  void updateInfo(JobApplicationInfo info, int index) async {
    Box infoBox = Hive.box(_boxName);
    await infoBox.putAt(index, info);
  }

  JobApplicationInfo getAt(int index) {
    Box infoBox = Hive.box(_boxName);
    return infoBox.getAt(index) as JobApplicationInfo;
  }

  void deleteAt(int index) async {
    Box infoBox = Hive.box(_boxName);
    await infoBox.deleteAt(index);
  }

  getListenable() {
    return (Hive.box(_boxName)).listenable();
  }

  bool isBoxEmpty() {
    return Hive.box(_boxName).isEmpty;
  }
}
