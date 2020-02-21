// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobApplicationInfoAdapter extends TypeAdapter<JobApplicationInfo> {
  @override
  final typeId = 0;

  @override
  JobApplicationInfo read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplicationInfo(
      fields[0] as String,
      fields[1] as String,
      fields[2] as DateTime,
      fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplicationInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.whenApplied)
      ..writeByte(3)
      ..write(obj.whenAnswered);
  }
}
