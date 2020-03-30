import 'dart:core';

import 'package:flutter/material.dart';
import 'package:job_search_assistant/notification_manager.dart';
import 'package:job_search_assistant/settings_elements/notification_settings.dart';
import 'package:job_search_assistant/settings_elements/updated_widget.dart';

class SettingsPage extends StatelessWidget {
  final String locale;
  final NotificationManager notificationManager;
  final String settingsBoxName;

  final _pageName = 'Settings';

  SettingsPage(
      {@required this.locale,
      @required this.notificationManager,
      @required this.settingsBoxName})
      : assert(locale != null),
        assert(notificationManager != null),
        assert(settingsBoxName != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_pageName)),
        body: ListView(children: _getPageElements()));
  }

  Iterable<Widget> _getPageElements() {
    List<Widget> children = [];
    List<UpdatedWidget> needUpdate = [];

    needUpdate.add(NotificationSettings(
      settingsBoxName: settingsBoxName,
      manager: notificationManager,
    ));

    for (var item in needUpdate) {
      children.add(item.getChild());
    }

    children.add(SaveButton(onPressed: () {
      _saveAll(needUpdate);
    }));

    return children;
  }

  void _saveAll(List<UpdatedWidget> shouldBeSaved) {
    for (var item in shouldBeSaved) {
      item.update();
    }
  }
}

class SaveButton extends StatelessWidget {
  final Function onPressed;

  SaveButton({@required this.onPressed}) : assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Spacer(),
      RaisedButton(
        child: Text('Save'),
        onPressed: onPressed,
      ),
      Spacer(),
    ]);
  }
}
