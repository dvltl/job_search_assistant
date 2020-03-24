import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_search_assistant/notification_manager.dart';
import 'package:job_search_assistant/settings_elements/updated_widget.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';

class NotificationSettings extends UpdatedWidget {
  static final _key = GlobalKey<_NotificationTimesChipsState>();
  final _NotificationTimesChips _child;

  NotificationSettings(
      {@required String settingsBoxName, @required NotificationManager manager})
      : assert(settingsBoxName != null),
        assert(manager != null),
        _child = _NotificationTimesChips(settingsBoxName, manager, _key);

  @override
  Widget getChild() {
    return _child;
  }

  @override
  void update() {
    print(_key.currentState == null);
    _key.currentState?.saveSettings();
  }
}

class _NotificationTimesChips extends StatefulWidget {
  final String settingsBoxName;
  final NotificationManager manager;

  _NotificationTimesChips(this.settingsBoxName, this.manager, key)
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var initialChoices = _getCurrentNotificationTimes();
    return _NotificationTimesChipsState(times: initialChoices);
  }

  List<TimeOfDay> _getCurrentNotificationTimes() {
    var ioHelper = AssistantIOHelper<String>(settingsBoxName);
    if (ioHelper.isBoxEmpty()) {
      return [];
    } else {
      var boxContents = ioHelper.getAll();
      var buf = boxContents.map((e) => e.split(':'));

      return List<TimeOfDay>.from(buf.map(
          (e) => TimeOfDay(hour: int.parse(e[0]), minute: int.parse(e[1]))));
    }
  }
}

class _NotificationTimesChipsState extends State<_NotificationTimesChips> {
  List<TimeOfDay> _timeChoices;

  _NotificationTimesChipsState({List<TimeOfDay> times})
      : _timeChoices = times ?? [];

  @override
  Widget build(BuildContext context) {
    List<Widget> pageElements = [];

    pageElements.add(Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          'Daily Notifications',
          style: Theme.of(context).textTheme.title,
        )));

    pageElements.add(Divider());

    var chips = _getChipsChoice();

    pageElements.add(chips);

    pageElements.add(Divider());

    return Column(
      children: pageElements,
    );
  }

  Widget _getChipsChoice() {
    List<TimeOfDay> options = [];

    for (int i = 0; i < 11; ++i) {
      options.add(new TimeOfDay(hour: 10 + i, minute: 0));
    }

    var chips = ChipsChoiceOption.listFrom<TimeOfDay, TimeOfDay>(
        source: options,
        value: (ind, val) => val,
        label: (ind, val) => val.format(context));

    var theme = Theme.of(context);
    var chipsWidget = ChipsChoice.multiple(
      value: _timeChoices,
      options: chips,
      onChanged: (Iterable<TimeOfDay> val) {
        setState(() => _timeChoices = val);
      },
      isWrapped: true,
      itemConfig: ChipsChoiceItemConfig(
        selectedBrightness: theme.brightness,
        unselectedBrightness: theme.brightness,
        selectedColor: theme.accentColor,
        unselectedColor: theme.textSelectionColor,
        showCheckmark: true,
      ),
    );

    return Wrap(direction: Axis.horizontal, children: <Widget>[
      FormField<Iterable<TimeOfDay>>(builder: (state) {
        return chipsWidget;
      })
    ]);
  }

  void saveSettings() {
    widget.manager.cancelAllNotifications();

    for (var i = 0; i < _timeChoices.length; ++i) {
      widget.manager.scheduleDailyNotificationAt(_timeChoices[i], i);
    }

    var ioHelper = AssistantIOHelper<String>(widget.settingsBoxName);
    ioHelper.clear().then((value) => _saveTimeChoices(ioHelper));
  }

  void _saveTimeChoices(AssistantIOHelper<String> ioHelper) {
    for (var val in _timeChoices) {
      ioHelper.addElem(val.format(context));
    }
  }
}
