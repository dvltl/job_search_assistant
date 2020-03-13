import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_search_assistant/app_theme/app_theme_data.dart';
import 'package:job_search_assistant/job_applications_page.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var locale = ui.window.locale.toString();
  initializeDateFormatting(locale);
  final appDocsDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocsDirectory.path);
  Hive.registerAdapter(JobApplicationInfoAdapter());
  runApp(Assistant(locale));
}

class Assistant extends StatefulWidget {
  final String _locale;

  Assistant(this._locale);

  @override
  State<StatefulWidget> createState() => AssistantState(_locale);
}

class AssistantState extends State<Assistant> {
  static final String _boxName = 'job_applications';
  final String _locale;

  AssistantState(this._locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Search Assistant',
      home: FutureBuilder(
        future: Hive.openBox(_boxName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return JobApplicationsPage(_boxName, _locale);
          } else
            return Scaffold(
                body: Column(
                  children: <Widget>[
                    Center(child: CircularProgressIndicator(),)
                  ],
                )
            );
        },
      ),
      theme: AppThemeData.getData(),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
