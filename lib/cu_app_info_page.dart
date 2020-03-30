import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/info_helper.dart';
import 'package:job_search_assistant/utils/source_view.dart';

// Create-Read-Update Application Info Page
class CUAppInfoPage extends StatefulWidget {
  final String _boxName;
  final String _locale;
  final int _index;

  CUAppInfoPage(this._boxName, this._locale, index) : this._index = index ?? -1;

  @override
  State<StatefulWidget> createState() =>
      CUAppInfoPageState(_boxName, _locale, _index);
}

class CUAppInfoPageState extends State<CUAppInfoPage> {
  // All of the form fields return their values as Strings
  final Map<String, String> _newInfo = Map();
  final Map<FieldType, Function> _formWrappers = Map();

  final String _boxName;
  final String _locale;
  final int _index;
  final _formKey = GlobalKey<FormState>();

  String _curSelectedVal;

  CUAppInfoPageState(this._boxName, this._locale, this._index) {
    _formWrappers[FieldType.string] =
        (String fieldName, bool required, String initialVal) {
      return _getTextFormField(
        fieldName: fieldName,
        requiredField: required,
        initialVal: initialVal,
      );
    };

    _formWrappers[FieldType.date] =
        (String fieldName, bool required, DateTime initialVal) {
      return DateTimeField(
        format: new DateFormat('dd.MM.yyyy', _locale),
        decoration: InputDecoration(labelText: fieldName),
        initialValue: initialVal,
        resetIcon: Icon(Icons.clear),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              initialDate: currentValue ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100));
        },
        onSaved: (DateTime value) {
          _newInfo[fieldName] = value != null ? value.toString() : '';
        },
        validator: (value) {
          if (required && (value == null)) {
            return 'Please choose a date';
          }
          return null;
        },
      );
    };

    _formWrappers[FieldType.interviewRes] =
        (String fieldName, bool required, String initialVal) {
      var values = JobAppInfoHelper.validInterviewResValues();
      _curSelectedVal = _curSelectedVal ??
          (initialVal ?? JobAppInfoHelper.defaultRes());
      Widget result;

      Iterable<DropdownMenuItem> items = values.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
      result = DropdownButtonFormField(
        value: _curSelectedVal,
        decoration: InputDecoration(labelText: fieldName),
        items: items,
        onChanged: (String newVal) {
          // TODO: find another solution
          // because it resets changes to other fields
          setState(() {
            _curSelectedVal = newVal;
          });
        },
        onSaved: (String newVal) {
          _newInfo[fieldName] = newVal;
        },
      );

      return result;
    };

    _formWrappers[FieldType.source] =
        (String fieldName, bool required, String initialVal) {
      var source = SourceView.fromString(initialVal);
      var nameField = JobAppInfoHelper.sourceName;
      var linkField = JobAppInfoHelper.sourceLink;

      return Row(
        children: <Widget>[
          Expanded(
            child: _getTextFormField(
              fieldName: nameField,
              requiredField: false,
              initialVal: source.getName(),
            ),
          ),
          Expanded(
              child: _getTextFormField(
                fieldName: linkField,
                requiredField: false,
                initialVal: source.getLink(),
              )
          ),
        ],
      );
    };
  }

  TextFormField _getTextFormField({String fieldName, bool requiredField,
                                    String initialVal}) {
    return TextFormField(
      controller: TextEditingController(text: initialVal),
      decoration: InputDecoration(labelText: fieldName),
      keyboardType: TextInputType.text,
      readOnly: false,
      validator: (value) {
        if ( requiredField && value.isEmpty ) {
          return 'Please enter ' + fieldName.toLowerCase();
        }
        return null;
      },
      onSaved: (String text) {
        this._newInfo[fieldName] = text;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _newInfo.clear();
    var formFields = _getFormWidgetFields(_formKey);

    return Scaffold(
      appBar: AppBar(
        title: _getModeDependentTitle(),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: formFields,
          )
      ),
    );
  }

  Text _getModeDependentTitle() {
    String message;
    String postfix = 'Job Application Info';
    if (_index == AssistantIOHelper.invalidIndex) {
      message = 'Add ' + postfix;
    } else {
      message = 'Edit ' + postfix;
    }
    return Text(message);
  }

  ListView _getFormWidgetFields(GlobalKey<FormState> formKey) {
    List<Widget> fields = <Widget>[];
    Map<String, Object> infoMap;

    if (_index != AssistantIOHelper.invalidIndex) {
      var ioHelper = AssistantIOHelper<JobApplicationInfo>(_boxName);
      infoMap = JobAppInfoHelper.asMap(ioHelper.getAt(_index));
    }

    for (var fieldInfo in JobAppInfoHelper.getFieldsInfo()) {
      if ( _index == AssistantIOHelper.invalidIndex
          && fieldInfo.fieldType == FieldType.interviewRes ) {
        /*
        For now it clears all of the changes to the fields, so skip it during
        the creation of job application information. It can be edited afterward.
        This is done to minimize input data loss and user annoyance.
         */
        continue;
      }
      Function initWrapper = _formWrappers[fieldInfo.fieldType];
      if (initWrapper != null) {
        var initVal;
        if (infoMap != null) {
          initVal = infoMap[fieldInfo.fieldName];
        }
        Widget toAdd =
        initWrapper(fieldInfo.fieldName, fieldInfo.required, initVal);
        fields.add(toAdd);
        if ( toAdd != null ) {
          fields.add(new Padding(padding: EdgeInsets.all(4.0)));
        }
      }
    }

    fields.add(
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _getModeDependentButtons(formKey)
                )
            )
        )
    );

    fields.removeWhere((element) => (element == null));

    return ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, i) {
          return fields[i];
        }
    );
  }

  List<Widget> _getModeDependentButtons(GlobalKey<FormState> formKey) {
    List<Widget> buttons = List();

    buttons.add(_getSubmitButton(formKey));
    if (_index != AssistantIOHelper.invalidIndex) {
      buttons.add(_getCancelButton(formKey));
    }

    return buttons;
  }

  RaisedButton _getSubmitButton(GlobalKey<FormState> formKey) {
    return RaisedButton(
      onPressed: () {
        // Validate will return true if the form is valid, or false if
        // the form is invalid.
        if (formKey.currentState.validate()) {
          formKey.currentState.save();

          var ioHelper = AssistantIOHelper<JobApplicationInfo>(_boxName);
          var info = JobAppInfoHelper.fromMap(_newInfo);

          if (_index != AssistantIOHelper.invalidIndex) {
            ioHelper.updateElem(info, _index);
          } else {
            ioHelper.addElem(info);
          }
          Navigator.pop(context);
        }
      },
      child: Text('Submit'),
    );
  }

  RaisedButton _getCancelButton(GlobalKey<FormState> formKey) {
    return RaisedButton(
      color: Theme
          .of(context)
          .errorColor,
      onPressed: () {
        formKey.currentState.reset();
        _curSelectedVal = null;
      },
      child: Text('Cancel'),
    );
  }
}
