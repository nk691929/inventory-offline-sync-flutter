// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncOperationModelAdapter extends TypeAdapter<SyncOperationModel> {
  @override
  final int typeId = 2;

  @override
  SyncOperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncOperationModel(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      status: fields[2] as String,
      retryCount: fields[3] as int,
      operationType: fields[4] as String,
      mutation: fields[5] as StockMutationModel?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncOperationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.operationType)
      ..writeByte(5)
      ..write(obj.mutation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
