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

  StockMutationModel({
    required this.id,
    required this.productId,
    required this.resultingQuantity,
    required this.type,
    required this.timestamp,
    required this.changedBy,
  });

  StockMutation toEntity() {
    return StockMutation(
      id: id,
      productId: productId,
      resultingQuantity: resultingQuantity,
      type: MutationType.values.byName(type),
      timestamp: timestamp,
      changedBy: changedBy,
    );
  }

  factory StockMutationModel.fromEntity(StockMutation stockMutation) {
    return StockMutationModel(
      id: stockMutation.id,
      productId: stockMutation.productId,
      resultingQuantity: stockMutation.resultingQuantity,
      type: stockMutation.type.name,
      timestamp: stockMutation.timestamp,
      changedBy: stockMutation.changedBy,
    );
  }
}
