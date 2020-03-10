import 'package:job_search_assistant/models/job_application_info.dart';
import 'package:job_search_assistant/utils/source_view.dart';

class JobAppInfoHelper {
  static final String _companyKey = 'Company name';
  static final String _positionKey = 'Position';
  static final String _appliedKey = 'When applied';
  static final String _answeredKey = 'When answered';
  static final String _sourceKey = 'Vacancy source';
  static final String _resultKey = 'Interview result';

  static final String sourceName = _sourceKey + ' name';
  static final String sourceLink = _sourceKey + ' link';

  static final List<String> _validResValues = [
    'No results yet', 'No offer', 'Accepted offer', 'Rejected offer'
  ];

  static Iterable<FieldInfo> getFieldsInfo() {
    return <FieldInfo>[
      FieldInfo(_companyKey, FieldType.string, true),
      FieldInfo(_positionKey, FieldType.string, true),
      FieldInfo(_appliedKey, FieldType.date, true),
      FieldInfo(_answeredKey, FieldType.date, false),
      FieldInfo(_sourceKey, FieldType.source, false),
      FieldInfo(_resultKey, FieldType.interviewRes, false),
    ];
  }

  static JobApplicationInfo fromMap(Map<String, String> info) {
    DateTime applied = DateTime.tryParse(info[_appliedKey]);
    DateTime answered = DateTime.tryParse(info[_answeredKey]);
    SourceView source = SourceView.fromStrings(
        info[sourceName], info[sourceLink]);

    return JobApplicationInfo(
      companyName: info[_companyKey],
      position: info[_positionKey],
      whenApplied: applied,
      whenAnswered: answered,
      source: source.toString(),
      interviewRes: info[_resultKey],
    );
  }

  static Map<String, Object> asMap(JobApplicationInfo info) {
    Map<String, Object> result = Map();
    result[_companyKey] = info.companyName;
    result[_positionKey] = info.position;
    result[_appliedKey] = info.whenApplied;
    result[_answeredKey] = info.whenAnswered;
    result[_sourceKey] = info.source;
    result[_resultKey] = info.interviewRes;

    result.removeWhere((key, value) => (value == null));

    return result;
  }

  static List<String> validInterviewResValues() {
    return _validResValues;
  }
}

enum FieldType { string, date, source, interviewRes }

class FieldInfo {
  final String fieldName;
  final FieldType fieldType;
  final bool required;

  FieldInfo(this.fieldName, this.fieldType, this.required);
}
