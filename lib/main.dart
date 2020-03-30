import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_search_assistant/app_theme/app_theme_data.dart';
import 'package:job_search_assistant/job_applications_page.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/notification_manager.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var locale = ui.window.locale.toString();
  initializeDateFormatting(locale);

  final appDocsDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocsDirectory.path);
  Hive.registerAdapter(JobApplicationInfoAdapter());

  final appTitle = 'Job Search Assistant';
  final notificationManager = NotificationManager(appName: appTitle);
  await notificationManager.init();

  runApp(
      Assistant(
          appTitle, 'job_applications', 'settings', locale, notificationManager)
  );
}

class Assistant extends StatefulWidget {
  final String appName;
  final String infoBoxName;
  final String settingsBoxName;
  final String _locale;
  final NotificationManager _notificationManager;

  Assistant(this.appName, this.infoBoxName, this.settingsBoxName,
            this._locale, this._notificationManager);

  @override
  State<StatefulWidget> createState() =>
      AssistantState(_locale, _notificationManager);
}

class AssistantState extends State<Assistant> {
  final String _locale;
  final NotificationManager _notificationManager;

  AssistantState(this._locale, this._notificationManager);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.appName,
      home: FutureBuilder(
        future: openBoxes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return JobApplicationsPage(widget.infoBoxName,
                  widget.settingsBoxName, _locale, _notificationManager);
          } else
            return Scaffold(
                appBar: AppBar(
                  title: Text('Current Job Applications'),
                ),
                body: Center(
                    child: CircularProgressIndicator()
                )
            );
        },
      ),
      theme: AppThemeData.getData(),
    );
  }

  Future<void> openBoxes() async {
    await Hive.openBox(widget.infoBoxName);
    await Hive.openBox(widget.settingsBoxName);
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
