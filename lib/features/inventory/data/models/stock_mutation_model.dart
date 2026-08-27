import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:hive/hive.dart';

part 'stock_mutation_model.g.dart';

@HiveType(typeId: 1)
class StockMutationModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final int resultingQuantity;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final DateTime timestamp;
  @HiveField(5)
  final String changedBy;
  @HiveField(6) 
  final int previousQuantity;

  StockMutationModel({
    required this.id,
    required this.productId,
    required this.resultingQuantity,
    required this.type,
    required this.timestamp,
    required this.changedBy,
    required this.previousQuantity,
  });

  StockMutation toEntity() {
    return StockMutation(
      id: id,
      productId: productId,
      previousQuantity: previousQuantity,
      resultingQuantity: resultingQuantity,
      type: MutationType.values.byName(type),
      timestamp: timestamp,
      changedBy: changedBy,
    );
  }

  factory StockMutationModel.fromEntity(StockMutation m) {
    return StockMutationModel(
      id: m.id,
      productId: m.productId,
      resultingQuantity: m.resultingQuantity,
      type: m.type.name,
      timestamp: m.timestamp,
      changedBy: m.changedBy,
      previousQuantity: m.previousQuantity,
    );
  }
}