import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

enum OperationStatus { pending, syncing, synced, failed }

sealed class SyncOperation {
  final String id;
  final DateTime createdAt;
  final OperationStatus status;
  final int retryCount;

  const SyncOperation({
    required this.id,
    required this.createdAt,
    required this.status,
    this.retryCount = 0,
  });
}

class StockMutationOperation extends SyncOperation {
  final StockMutation mutation;
  const StockMutationOperation({
    required super.id,
    required super.createdAt,
    required super.status,
    super.retryCount,
    required this.mutation,
  });
}


SyncOperation withUpdatedStatus(
  SyncOperation operation, {
  required OperationStatus status,
  int? retryCount,
}) {
  return switch (operation) {
    StockMutationOperation() => StockMutationOperation(
        id: operation.id,
        createdAt: operation.createdAt,
        status: status,
        retryCount: retryCount ?? operation.retryCount,
        mutation: operation.mutation,
      ),
  };
}