// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_mutation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockMutationModelAdapter extends TypeAdapter<StockMutationModel> {
  @override
  final int typeId = 1;

  @override
  StockMutationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockMutationModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      resultingQuantity: fields[2] as int,
      type: fields[3] as String,
      timestamp: fields[4] as DateTime,
      changedBy: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockMutationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.resultingQuantity)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.changedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMutationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
