import 'package:flutter/material.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/utils/DateStringFormatter.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/info_helper.dart';

class AppInfoDetailsPage extends StatelessWidget {
  final String _boxName;
  final int _index;
  final String _locale;

  AppInfoDetailsPage(this._boxName, this._index, this._locale);

  @override
  Widget build(BuildContext context) {
    Widget infoList = _getBody(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Application Details'),
      ),
      body: ListView(
        children: <Widget>[
          infoList,
        ],
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
    JobApplicationInfo info = ioHelper.getAt(_index);

    Map<String, Object> infoMap = JobAppInfoHelper.asMap(info);

    DataTable table = DataTable(
      columns: [
        DataColumn(label: Text('Field name')),
        DataColumn(label: Text('Value'))
      ],
      rows: [],
    );

    for (var entry in infoMap.entries) {
      var widget;
      if (entry.value is DateTime) {
        widget = Text(DateStringFormatter.getDateAsString(entry.value));
      } else {
        widget = Text(entry.value.toString());
      }

      table.rows.add(DataRow(cells: [
        DataCell(Text(
          entry.key,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataCell(widget)
      ]));
    }

    return table;
  }
}
