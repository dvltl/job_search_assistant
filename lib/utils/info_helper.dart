import 'package:job_search_assistant/models/job_application_info.dart';

class JobAppInfoHelper {
  static final String _companyKey = 'Company name';
  static final String _positionKey = 'Position';
  static final String _appliedKey = 'When applied';
  static final String _answeredKey = 'When answered';

  static Iterable<FieldInfo> getFieldsInfo() {
    return <FieldInfo>[
      FieldInfo(_companyKey, FieldType.string, true),
      FieldInfo(_positionKey, FieldType.string, true),
      FieldInfo(_appliedKey, FieldType.date, true),
      FieldInfo(_answeredKey, FieldType.date, false),
    ];
  }

  static JobApplicationInfo fromMap(Map<String, String> info) {
    DateTime applied = DateTime.tryParse(info[_appliedKey]);
    DateTime answered = DateTime.tryParse(info[_answeredKey]);
    return JobApplicationInfo(
        info[_companyKey], info[_positionKey], applied, answered);
  }

  static Map<String, Object> asMap(JobApplicationInfo info) {
    Map<String, Object> result = Map();
    result[_companyKey] = info.companyName;
    result[_positionKey] = info.position;
    result[_appliedKey] = info.whenApplied;
    result[_answeredKey] = info.whenAnswered;

    result.removeWhere((key, value) => (value == null));

    return result;
  }
}

enum FieldType { string, date }

class FieldInfo {
  final String fieldName;
  final FieldType fieldType;
  final bool required;

  FieldInfo(this.fieldName, this.fieldType, this.required);
}
