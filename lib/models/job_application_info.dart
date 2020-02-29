import 'package:hive/hive.dart';

part 'job_application_info.g.dart';

@HiveType(typeId: 0)
class JobApplicationInfo {
  @HiveField(0)
  final String companyName;
  @HiveField(1)
  final String position;

  @HiveField(2)
  final DateTime whenApplied;
  @HiveField(3)
  final DateTime whenAnswered;

  /*
    TODO: Add fields following fields:
     (1) salary interval,
     (2) vacancy source,
     (3) got the offer?
   */

  JobApplicationInfo(this.companyName, this.position, this.whenApplied,
      this.whenAnswered);
}
