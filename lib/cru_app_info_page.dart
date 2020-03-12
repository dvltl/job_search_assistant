import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/info_helper.dart';
import 'package:job_search_assistant/utils/source_view.dart';
import 'package:url_launcher/url_launcher.dart';

// Create-Read-Update Application Info Page
class CRUAppInfoPage extends StatefulWidget {
  final String _boxName;
  final String _locale;
  final int _index;
  final _formKey = GlobalKey<FormState>();
  final bool _editMode;

  CRUAppInfoPage(this._boxName, this._locale, index, editing)
      : this._index = index ?? -1,
        this._editMode = editing ?? false;

  @override
  State<StatefulWidget> createState() =>
      CRUAppInfoPageState(_formKey, _boxName, _locale, _index, _editMode);
}

class CRUAppInfoPageState extends State<CRUAppInfoPage> {
  // All of the form fields return their values as Strings
  final Map<String, String> _newInfo = Map();
  final Map<FieldType, Function> _formWrappers = Map();

  final String _boxName;
  final _formKey;
  final String _locale;
  final int _index;

  bool _editMode;
  String _curSelectedVal;

  CRUAppInfoPageState(
      this._formKey, this._boxName, this._locale, this._index, this._editMode) {
    _formWrappers[FieldType.string] =
        (String fieldName, bool required, String initialVal) {
      return _getTextFormField(
        fieldName: fieldName,
        required: required,
        editModeOn: !_inEditMode(),
        initialVal: initialVal,
      );
    };

    _formWrappers[FieldType.date] =
        (String fieldName, bool required, DateTime initialVal) {
      return DateTimeField(
        format: new DateFormat('dd.MM.yyyy', _locale),
        decoration: InputDecoration(labelText: fieldName),
        initialValue: initialVal,
        resetIcon: _inEditMode() ? Icon(Icons.clear) : null,
        onShowPicker: (context, currentValue) async {
          if (!_inEditMode()) {
            return null;
          } else {
            return showDatePicker(
                context: context,
                initialDate: currentValue ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));
          }
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
      _curSelectedVal = _curSelectedVal ?? (initialVal ?? values[0]);
      Widget result;

      if ( _inEditMode() ) {
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
      } else {
        result = TextField(
          controller: TextEditingController(
              text: _curSelectedVal
          ),
          decoration: InputDecoration(labelText: fieldName),
          readOnly: true,
        );
      }

      return result;
    };

    _formWrappers[FieldType.source] =
        (String fieldName, bool required, String initialVal) {
      var source = SourceView.fromString(initialVal);
      var nameField = JobAppInfoHelper.sourceName;
      var linkField = JobAppInfoHelper.sourceLink;

      if ( _inEditMode() ) {
        return Row(
          children: <Widget>[
            Expanded(
              child: _getTextFormField(
                fieldName: nameField,
                required: false,
                editModeOn: !_inEditMode(),
                initialVal: source.getName(),
              ),
            ),
            Expanded(
                child: _getTextFormField(
                  fieldName: linkField,
                  required: false,
                  editModeOn: !_inEditMode(),
                  initialVal: source.getLink(),
                )
            ),
          ],
        );
      } else if ( source != null && source
          .getName()
          .isNotEmpty ) {
        return RaisedButton(
          child: Text('Go to source: ' + source.getName()),
          onPressed: () {
            _launchUrl(source.getLink());
          },
        );
      } else {
        return TextField(
          controller: TextEditingController(text: 'No source provided'),
          decoration: InputDecoration(labelText: fieldName),
          readOnly: true,
        );
      }
    };
  }

  TextFormField _getTextFormField({String fieldName, bool required,
                                    bool editModeOn, String initialVal}) {
    return TextFormField(
      controller: TextEditingController(text: initialVal),
      decoration: InputDecoration(labelText: fieldName),
      keyboardType: TextInputType.text,
      readOnly: editModeOn,
      validator: (value) {
        if ( required && value.isEmpty ) {
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
        actions: _getModeDependentActions(),
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

  List<Widget> _getModeDependentActions() {
    if (!_inEditMode()) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _enterEditMode();
          },
        ),
      ];
    } else {
      return null;
    }
  }

  Text _getModeDependentTitle() {
    String message;
    String postfix = 'Job Application Info';
    if (_index == AssistantIOHelper.invalidIndex) {
      message = 'Add ' + postfix;
    } else if (!_inEditMode()) {
      message = postfix;
    } else {
      message = 'Edit ' + postfix;
    }
    return Text(message);
  }

  ListView _getFormWidgetFields(GlobalKey<FormState> formKey) {
    List<Widget> fields = <Widget>[];
    Map<String, Object> infoMap;

    if (_index != AssistantIOHelper.invalidIndex) {
      AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
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

    if (_inEditMode()) {
      fields.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _getModeDependentButtons(formKey)
              )
          )
      ));
    }

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

          AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
          var info = JobAppInfoHelper.fromMap(_newInfo);

          if (_index != AssistantIOHelper.invalidIndex) {
            ioHelper.updateInfo(info, _index);
          } else {
            ioHelper.addInfo(info);
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

  bool _inEditMode() {
    return this._editMode;
  }

  void _enterEditMode() {
    setState(() {
      this._editMode = true;
    });
  }

  void _exitEditMode() {
    setState(() {
      this._editMode = false;
    });
  }

  void _launchUrl(String link) async {
    try {
      if ( await canLaunch(link) ) {
        await launch(
          link, forceWebView: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Couldn\'t launch $link';
      }
    } catch ( exception ) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Couldn\' open $link'),
            content: Text('Please check whether the link is correct'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
        barrierDismissible: true,
      );
    }
  }
}
