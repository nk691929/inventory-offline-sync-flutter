import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/remote/mock_backend_service.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';
import 'package:collaborative_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:uuid/uuid.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final MockBackendService mockBackendService;
  final _uuid = const Uuid();
  static const int maxRetries = 3;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.mockBackendService,
  });

  @override
  Stream<List<Product>> watchProducts() {
    return localDataSource.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> addProduct(Product product) async {
    await localDataSource.saveProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await localDataSource.deleteProduct(productId);
  }

  @override
  Future<Product?> getProductById(String productId) async {
    final model = await localDataSource.getProductById(productId);
    return model?.toEntity();
  }

  @override
  Future<StockMutation> updateStock({
    required String productId,
    required int newQuantity,
    required String changedBy,
  }) async {
    final currentModel = await localDataSource.getProductById(productId);

    if (currentModel == null) {
      throw StateError('Product not found: $productId');
    }

    final now = DateTime.now();

    final mutation = StockMutation(
      id: _uuid.v4(),
      productId: productId,
      previousQuantity: currentModel.quantity,
      resultingQuantity: newQuantity,
      type: MutationType.adjustment,
      timestamp: now,
      changedBy: changedBy,
    );

    await localDataSource.saveStockMutation(
      StockMutationModel.fromEntity(mutation),
    );

    final updated = ProductModel(
      id: currentModel.id,
      name: currentModel.name,
      quantity: newQuantity,
      lastModified: now,
    );

    await localDataSource.saveProduct(updated);

    final stockOperation = StockMutationOperation(
      id: _uuid.v4(),
      createdAt: now,
      status: OperationStatus.pending,
      mutation: mutation,
    );

    await enqueueOperation(stockOperation);

    return mutation;
  }

  @override
  Stream<List<StockMutation>> watchMutationHistory(String productId) {
    return localDataSource
        .watchMutationHistory(productId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> enqueueOperation(SyncOperation operation) async {
    await localDataSource.saveSyncOperation(
      SyncOperationModel.fromEntity(operation),
    );
  }

  @override
  Future<void> syncPendingOperations() async {
    final pendingModels = await localDataSource.getPendingOperations();
    for (final model in pendingModels) {
      final operation = model.toEntity();

      if (operation is! StockMutationOperation) continue;

      try {
        await mockBackendService.sendMutation(operation.mutation);
        final synced = withUpdatedStatus(
          operation,
          status: OperationStatus.synced,
        );
        await localDataSource.updateSyncOperation(
          SyncOperationModel.fromEntity(synced),
        );
      } on ConflictException {
        final lost = withUpdatedStatus(
          operation,
          status: OperationStatus.failed,
        );
        await localDataSource.updateSyncOperation(
          SyncOperationModel.fromEntity(lost),
        );
        await _rollbackProductQuantity(operation.mutation);
      } catch (e) {
        final nextRetryCount = operation.retryCount + 1;
        final isFinal = nextRetryCount >= maxRetries;

        final updated = withUpdatedStatus(
          operation,
          status: isFinal ? OperationStatus.failed : OperationStatus.pending,
          retryCount: nextRetryCount,
        );

        await localDataSource.updateSyncOperation(
          SyncOperationModel.fromEntity(updated),
        );

        if (isFinal) {
          await _rollbackProductQuantity(operation.mutation);
        }
      }
    }
  }

  Future<void> _rollbackProductQuantity(StockMutation failedMutation) async {
    final currentModel = await localDataSource.getProductById(
      failedMutation.productId,
    );
    if (currentModel == null) return;

    if (currentModel.lastModified != failedMutation.timestamp) {
      return;
    }

    final rolledBack = ProductModel(
      id: currentModel.id,
      name: currentModel.name,
      quantity: failedMutation.previousQuantity,
      lastModified: DateTime.now(),
    );
    await localDataSource.saveProduct(rolledBack);
  }
}
