import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:job_search_assistant/cru_app_info_page.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/date_string_formatter.dart';

class JobApplicationsPage extends StatelessWidget {
  final String _boxName;
  final String _locale;

  JobApplicationsPage(this._boxName, this._locale);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Job Applications'),
      ),
      body: _getMainPage(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          _pushAddAppInfo(context);
        },
      ),
    );
  }

  Widget _getMainPage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildListView(),
        ),
      ],
    );
  }

  Widget _getEmptyApplicationsMessage() {
    return Center(
        child: Container(
          child: Text(
            'There are no saved job applications at the moment',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
        )
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box(_boxName).listenable(),
      builder: (context, jobsBox, child) {
        if ( jobsBox.isEmpty ) {
          return _getEmptyApplicationsMessage();
        } else {
          return ListView.builder(
            itemCount: 2 * jobsBox.length,
            itemBuilder: (context, i) {
              if ( i.isOdd ) return Divider();

              final index = i ~/ 2;
              return _buildRow(index, context);
            },
          );
        }
      },
    );
  }

  Widget _buildRow(int index, BuildContext context) {
    AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
    final JobApplicationInfo info = ioHelper.getAt(index);

    var applicationDateString = _getApplicationDateString(info);

    return ListTile(
      title: Text(info.position + ' at ' + info.companyName),
      subtitle: info.whenApplied != null
          ? Text('Applied at $applicationDateString')
          : null,
      onTap: () {
        _pushAppInfoDetail(context, index);
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          _removeAppInfo(index);
        },
      ),
    );
  }

  Future<void> _removeAppInfo(int index) async {
    AssistantIOHelper helper = AssistantIOHelper(_boxName);
    helper.deleteAt(index);
  }

  void _pushAddAppInfo(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return CRUAppInfoPage(
              _boxName, _locale, AssistantIOHelper.invalidIndex, true);
    }));
  }

  void _pushAppInfoDetail(BuildContext context, int index) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return CRUAppInfoPage(_boxName, _locale, index, false);
          //return AppInfoDetailsPage(_boxName, index, _locale);
    }));
  }

  String _getApplicationDateString(JobApplicationInfo info) {
    return DateStringFormatter.getDateAsString(info.whenApplied);
  }
}
