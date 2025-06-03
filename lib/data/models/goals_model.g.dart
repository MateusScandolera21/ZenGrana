// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalsModelAdapter extends TypeAdapter<GoalsModel> {
  @override
  final int typeId = 3;

  @override
  GoalsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalsModel(
      id: fields[0] as int,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      dueDate: fields[4] as DateTime,
      isCompleted: fields[5] as bool,
      completionDate: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
