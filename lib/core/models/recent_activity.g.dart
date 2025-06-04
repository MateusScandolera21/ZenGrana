// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentActivityAdapter extends TypeAdapter<RecentActivity> {
  @override
  final int typeId = 7;

  @override
  RecentActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentActivity(
      id: fields[0] as String,
      type: fields[1] as String,
      description: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentActivity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
