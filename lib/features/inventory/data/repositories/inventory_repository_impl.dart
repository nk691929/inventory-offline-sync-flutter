import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource.dart';
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
  final _uuid = const Uuid();

  InventoryRepositoryImpl({required this.localDataSource});

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
    final mutation = StockMutation(
      id: _uuid.v4(),
      productId: productId,
      resultingQuantity: newQuantity,
      type: MutationType.adjustment,
      timestamp: DateTime.now(),
      changedBy: changedBy,
    );

    await localDataSource.saveStockMutation(
      StockMutationModel.fromEntity(mutation),
    );

    final model = await localDataSource.getProductById(productId);
    if (model != null) {
      final updated = ProductModel(
        id: model.id,
        name: model.name,
        quantity: newQuantity,
        lastModified: DateTime.now(),
      );

      await localDataSource.saveProduct(updated);
    }

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
  Future<List<SyncOperation>> getPendingOperations() async {
    // TODO: implement getPendingOperations
    throw UnimplementedError();
  }

  @override
  Future<void> markOperationFailed(
    String operationId, {
    required bool isFinal,
  }) async {
    // TODO: implement markOperationFailed
    throw UnimplementedError();
  }

  @override
  Future<void> markOperationSynced(String operationId) async {
    // TODO: implement markOperationSynced
    throw UnimplementedError();
  }
}
