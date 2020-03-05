import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_search_assistant/app_theme/app_theme_data.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/info_helper.dart';

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

  CRUAppInfoPageState(
      this._formKey, this._boxName, this._locale, this._index, this._editMode) {
    _formWrappers[FieldType.string] = (fieldName, required, initialVal) {
      return TextFormField(
        controller: TextEditingController(text: initialVal),
        decoration: InputDecoration(labelText: fieldName),
        keyboardType: TextInputType.text,
        readOnly: !_inEditMode(),
        validator: (value) {
          if (required && value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onSaved: (String text) {
          this._newInfo[fieldName] = text;
        },
      );
    };

    _formWrappers[FieldType.date] = (fieldName, required, initialVal) {
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
          this._newInfo[fieldName] = value != null ? value.toString() : '';
        },
        validator: (value) {
          if (required && (value == null)) {
            return 'Please choose a date';
          }
          return null;
        },
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    _newInfo.clear();
    Iterable<Widget> formFields = _getFormWidgetFields(_formKey);

    return Scaffold(
      appBar: AppBar(
        title: _getModeDependentTitle(),
        actions: _getModeDependentActions(),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: formFields,
            ),
          )),
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

  Iterable<Widget> _getFormWidgetFields(GlobalKey<FormState> formKey) {
    List<Widget> fields = <Widget>[];
    Map<String, Object> infoMap;

    if (_index != AssistantIOHelper.invalidIndex) {
      AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
      infoMap = JobAppInfoHelper.asMap(ioHelper.getAt(_index));
    }

    for (var fieldInfo in JobAppInfoHelper.getFieldsInfo()) {
      Function initWrapper = _formWrappers[fieldInfo.fieldType];
      if (initWrapper != null) {
        var initVal;
        if (infoMap != null) {
          initVal = infoMap[fieldInfo.fieldName];
        }
        Widget toAdd =
            initWrapper(fieldInfo.fieldName, fieldInfo.required, initVal);
        fields.add(toAdd);
        fields.add(new Padding(padding: EdgeInsets.all(4.0)));
      }
    }

    if (_inEditMode()) {
      fields.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _getModeDependentButtons(formKey)))));
    }

    return fields;
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
            _exitEditMode();
          } else {
            ioHelper.addInfo(info);
            Navigator.pop(context);
          }
        }
      },
      child: Text('Submit'),
    );
  }

  RaisedButton _getCancelButton(GlobalKey<FormState> formKey) {
    return RaisedButton(
      color: AppThemeData.cancelColor(),
      onPressed: () {
        formKey.currentState.reset();
        _exitEditMode();
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
}
