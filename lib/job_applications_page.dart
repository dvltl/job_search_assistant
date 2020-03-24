import 'package:flutter/material.dart';
import 'package:job_search_assistant/cu_app_info_page.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/notification_manager.dart';
import 'package:job_search_assistant/settings_page.dart';
import 'package:job_search_assistant/utils/app_info_tile.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';

class JobApplicationsPage extends StatelessWidget {
  final String _jobsBoxName;
  final String _settingsBoxName;
  final String _locale;
  final NotificationManager _notificationManager;

  JobApplicationsPage(this._jobsBoxName, this._settingsBoxName,
                      this._locale, this._notificationManager);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Job Applications'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showSettings(context);
            },
          )
        ],
      ),
      body: _getMainPage(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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

  Widget _getEmptyApplicationsMessage(BuildContext context) {
    return Center(
        child: Container(
          child: Text(
            'There are no saved job applications at the moment',
            style: TextStyle(
              color: Theme
                  .of(context)
                  .accentColor,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
        )
    );
  }

  Widget _buildListView() {
    var ioHelper = AssistantIOHelper<JobApplicationInfo>(_jobsBoxName);
    return ValueListenableBuilder(
      valueListenable: ioHelper.getListenable(),
      builder: (context, jobsBox, child) {
        if ( jobsBox.isEmpty ) {
          return _getEmptyApplicationsMessage(context);
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
    var ioHelper = AssistantIOHelper<JobApplicationInfo>(_jobsBoxName);
    final JobApplicationInfo info = ioHelper.getAt(index);

    return AppInfoTile(
      info: info,
      onPushClear: () {
        _showDeleteDialog(context, index);
      },
      onPushEdit: () {
        _pushEditAppInfo(context, index);
      },
      cellSize: Size(MediaQuery
          .of(context)
          .size
          .width, 110),
      edgeInsets: EdgeInsets.all(10),
      animationDuration: Duration(milliseconds: 200),
      borderRadius: 10,
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Remove the vacancy?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () async {
              await _removeAppInfo(index);
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _removeAppInfo(int index) async {
    var helper = AssistantIOHelper<JobApplicationInfo>(_jobsBoxName);
    await helper.deleteAt(index);
  }

  void _pushAddAppInfo(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return CUAppInfoPage(
              _jobsBoxName, _locale, AssistantIOHelper.invalidIndex);
    }));
  }

  void _pushEditAppInfo(BuildContext context, int index) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return CUAppInfoPage(_jobsBoxName, _locale, index);
    }));
  }

  _showSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return SettingsPage(
            locale: _locale,
            notificationManager: _notificationManager,
            settingsBoxName: _settingsBoxName,
          );
        }));
  }
}
