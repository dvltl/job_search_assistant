import 'package:flutter/material.dart';
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

  @HiveField(4)
  final String source;

  // 'No results yet' (default), 'No offer', 'Accepted offer', 'Rejected offer'
  @HiveField(5)
  final String interviewRes;

  /*
    TODO: Add following fields:
     (1) salary interval,
   */

  JobApplicationInfo({
                       @required this.companyName,
                       @required this.position,
                       @required this.whenApplied,
                       @required this.whenAnswered,
                       @required this.source,
                       @required this.interviewRes
                     });
}
