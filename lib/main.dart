import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_search_assistant/job_application_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final String _appName = 'Job Search Assistant';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appName,
      theme: ThemeData.dark(),
      home: JobApplications(),
    );
  }
}

class JobApplications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JobApplicationState();
}

class JobApplicationState extends State<JobApplications> {
  final List<JobApplicationInfo> _applications = _getApplications();

  Map<String, String> _newInfo = Map();

  static List<JobApplicationInfo> _getApplications() {
    return List<JobApplicationInfo>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Job Applications'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _pushAddApplication();
            },
          )
        ],
      ),
      body: _buildJobApplicationsInfo(),
    );
  }

  _pushAddApplication() async {
    final formKey = GlobalKey<FormState>();
    _newInfo.clear();
    Iterable<Widget> formFields = _getFormWidgetFields(formKey);

    JobApplicationInfo newApplication = await Navigator.push(context,
        MaterialPageRoute<JobApplicationInfo>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Job application information'),
        ),
        body: Form(
          key: formKey,
          child: Column(
            children: formFields,
          ),
        ),
      );
    }));

    if (newApplication != null) {
      setState(() {
        _applications.add(newApplication);
        print('Updated applications: ' + _applications.toString());
      });
    }
  }

  Iterable<Widget> _getFormWidgetFields(GlobalKey<FormState> formKey) {
    List<Widget> fields = <Widget>[];

    Map<FieldType, Function> formWrappers = Map();

    formWrappers[FieldType.string] = (fieldName) {
      return TextFormField(
        controller: TextEditingController(),
        decoration: InputDecoration(hintText: fieldName),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onSaved: (String text) {
          this._newInfo[fieldName] = text;
        },
      );
    };

    formWrappers[FieldType.date] = (fieldName) {
      return DateTimeField(
        format: new DateFormat('dd.MM.yyyy'),
        decoration: InputDecoration(
          hintText: fieldName,
        ),
        onShowPicker: (context, currentValue) async {
          return showDatePicker(
              context: context,
              initialDate: currentValue ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100));
        },
        onSaved: (DateTime value) {
          this._newInfo[fieldName] = value.toString();
        },
      );
    };

    for (var fieldInfo in JobApplicationInfo.getFieldsInfo()) {
      Function initWrapper = formWrappers[fieldInfo.fieldType];
      if (initWrapper != null) {
        Widget toAdd = initWrapper(fieldInfo.fieldName);
        fields.add(toAdd);
      }
    }

    fields.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          color: Colors.blueGrey,
          onPressed: () {
            // Validate will return true if the form is valid, or false if
            // the form is invalid.
            if (formKey.currentState.validate()) {
              formKey.currentState.save();

              Navigator.pop(context, JobApplicationInfo.fromMap(_newInfo));
            }
          },
          child: Text('Submit'),
        ),
      ),
    );

    return fields;
  }

  Widget _buildJobApplicationsInfo() {
    if (_applications.isEmpty) {
      return _getEmptyApplicationsMessage();
    } else {
      return ListView.builder(
        itemCount: 2 * _applications.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;

          return _buildRow(index, _applications.elementAt(index));
        },
      );
    }
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
    ));
  }

  Widget _buildRow(int index, JobApplicationInfo info) {
    String year, month, day;
    if (info.whenApplied != null) {
      var fixedLengthStringFromInt = (int number) {
        if (number < 10) {
          return '0' + number.toString();
        } else {
          return number.toString();
        }
      };
      year = info.whenApplied.year.toString();
      month = fixedLengthStringFromInt(info.whenApplied.month);
      day = fixedLengthStringFromInt(info.whenApplied.day);
    }
    return ListTile(
      title: Text(info.position + ' at ' + info.companyName),
      subtitle: info.whenApplied != null
          ? Text('Applied at $day.$month.$year')
          : Text(''),
      onTap: () {
        _pushShowDetails(info);
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          setState(() {
            _applications.removeAt(index);
          });
        },
      ),
    );
  }

  _pushShowDetails(JobApplicationInfo info) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      Map<String, Object> infoMap = info.asMap();

      List<ListTile> tiles = List();
      for (var entry in infoMap.entries) {
        tiles.add(ListTile(
          title: Text(entry.key + ': ' + entry.value.toString()),
        ));
      }

      tiles.add(ListTile(
        title: Text(''),
      ));

      final List<Widget> infoList =
          ListTile.divideTiles(context: context, tiles: tiles).toList();

      return Scaffold(
        appBar: AppBar(
          title: Text('Job Application Details'),
        ),
        body: ListView(
          children: infoList,
        ),
      );
    }));
  }
}
