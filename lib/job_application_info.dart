class JobApplicationInfo {
  static final String _companyKey = 'Company name';
  static final String _positionKey = 'Position';
  static final String _appliedKey = 'When applied';
  static final String _answeredKey = 'When answered';

  final String companyName;
  final String position;

//  Range salary;

  // TODO: make whenApplied final
  DateTime whenApplied;
  DateTime whenAnswered;

  static Iterable<FieldInfo> getFieldsInfo() {
    return <FieldInfo>[
      FieldInfo(_companyKey, FieldType.string),
      FieldInfo(_positionKey, FieldType.string),
      FieldInfo(_appliedKey, FieldType.date),
      FieldInfo(_answeredKey, FieldType.date),
    ];
  }

  JobApplicationInfo(this.companyName, this.position, this.whenApplied);

  JobApplicationInfo.fullInfo(
      this.companyName, this.position, this.whenApplied, this.whenAnswered);

  static JobApplicationInfo fromMap(Map<String, String> info) {
    DateTime applied =
        info[_appliedKey] != null ? DateTime.tryParse(info[_appliedKey]) : null;
    DateTime answered = info[_answeredKey] != null
        ? DateTime.tryParse(info[_answeredKey])
        : null;
    return JobApplicationInfo.fullInfo(
        info[_companyKey], info[_positionKey], applied, answered);
  }

  Map<String, Object> asMap() {
    Map<String, Object> result = Map();
    result[_companyKey] = companyName;
    result[_positionKey] = position;
    result[_appliedKey] = whenApplied;
    result[_answeredKey] = whenAnswered;

    result.removeWhere((key, value) => (value == null));

    return result;
  }
}

enum FieldType { string, date }

class FieldInfo {
  final String fieldName;
  final FieldType fieldType;

  FieldInfo(this.fieldName, this.fieldType);
}
