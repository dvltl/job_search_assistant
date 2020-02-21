import 'package:hive/hive.dart';

part 'job_application_info.g.dart';

@HiveType(typeId: 0)
class JobApplicationInfo {
  @HiveField(0)
  final String companyName;
  @HiveField(1)
  final String position;

//  Range salary;

  // TODO: make whenApplied final
  @HiveField(2)
  final DateTime whenApplied;
  @HiveField(3)
  final DateTime whenAnswered;

  JobApplicationInfo(this.companyName, this.position, this.whenApplied,
      this.whenAnswered);
}
