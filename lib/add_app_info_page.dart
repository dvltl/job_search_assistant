import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_search_assistant/utils/assistant_io_helper.dart';
import 'package:job_search_assistant/utils/info_helper.dart';

class AddAppInfoPage extends StatefulWidget {
  final String _boxName;
  final String _locale;
  final _formKey = GlobalKey<FormState>();

  AddAppInfoPage(this._boxName, this._locale);

  @override
  State<StatefulWidget> createState() =>
      AddAppInfoPageState(_formKey, _boxName, _locale);
}

class AddAppInfoPageState extends State<AddAppInfoPage> {
  // All of the form fields return their values as Strings
  final Map<String, String> _newInfo = Map();
  final String _boxName;
  final _formKey;
  final String _locale;

  AddAppInfoPageState(this._formKey, this._boxName, this._locale);

  @override
  Widget build(BuildContext context) {
    _newInfo.clear();
    Iterable<Widget> formFields = _getFormWidgetFields(_formKey);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Job application information'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: formFields,
        ),
      ),
    );
  }

  Iterable<Widget> _getFormWidgetFields(GlobalKey<FormState> formKey) {
    List<Widget> fields = <Widget>[];

    Map<FieldType, Function> formWrappers = Map();

    formWrappers[FieldType.string] = (fieldName, required) {
      return TextFormField(
        controller: TextEditingController(),
        decoration: InputDecoration(hintText: fieldName),
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

    formWrappers[FieldType.date] = (fieldName, required) {
      return DateTimeField(
        format: new DateFormat('dd.MM.yyyy', _locale),
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

    for (var fieldInfo in JobAppInfoHelper.getFieldsInfo()) {
      Function initWrapper = formWrappers[fieldInfo.fieldType];
      if (initWrapper != null) {
        Widget toAdd = initWrapper(fieldInfo.fieldName, fieldInfo.required);
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
              AssistantIOHelper ioHelper = AssistantIOHelper(_boxName);
              ioHelper.addInfo(JobAppInfoHelper.fromMap(_newInfo));
              Navigator.pop(
                context,
              );
            }
          },
          child: Text('Submit'),
        ),
      ),
    );

    return fields;
  }
}
