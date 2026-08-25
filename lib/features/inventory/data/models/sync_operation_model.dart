import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';
import 'package:hive/hive.dart';

part 'sync_operation_model.g.dart';

@HiveType(typeId: 2)
class SyncOperationModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime createdAt;
  @HiveField(2)
  final String status;
  @HiveField(3)
  final int retryCount;
  @HiveField(4)
  final String operationType;
  @HiveField(5)
  final StockMutationModel? mutation;

  SyncOperationModel({
    required this.id,
    required this.createdAt,
    required this.status,
    this.retryCount = 0,
    required this.operationType,
    this.mutation,
  });

  SyncOperation toEntity() {
    return switch (operationType) {
      'stockMutation' => StockMutationOperation(
        id: id,
        createdAt: createdAt,
        status: OperationStatus.values.byName(status),
        retryCount: retryCount,
        mutation: mutation!.toEntity(),
      ),
      _ => throw Exception('Unknown operation type: $operationType'),
    };
  }

  factory SyncOperationModel.fromEntity(SyncOperation operation) {
    return switch (operation) {
      StockMutationOperation(mutation: final mutation) => SyncOperationModel(
        id: operation.id,
        createdAt: operation.createdAt,
        status: operation.status.name,
        retryCount: operation.retryCount,
        operationType: 'stockMutation',
        mutation: StockMutationModel.fromEntity(mutation),
      ),
    };
  }
}
