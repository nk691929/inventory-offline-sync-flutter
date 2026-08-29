import 'package:flutter_test/flutter_test.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/remote/mock_backend_service.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

// Fake datasource in-memory
class FakeLocalDataSource implements InventoryLocalDataSource {
  final Map<String, ProductModel> products = {};
  final Map<String, StockMutationModel> mutations = {};
  final Map<String, SyncOperationModel> syncOps = {};

  @override
  Future<void> saveProduct(ProductModel product) async =>
      products[product.id] = product;

  @override
  Future<ProductModel?> getProductById(String productId) async =>
      products[productId];

  @override
  Future<void> deleteProduct(String productId) async =>
      products.remove(productId);

  @override
  Stream<List<ProductModel>> watchProducts() =>
      Stream.value(products.values.toList());

  @override
  Future<void> saveStockMutation(StockMutationModel mutation) async =>
      mutations[mutation.id] = mutation;

  @override
  Stream<List<StockMutationModel>> watchMutationHistory(String productId) =>
      Stream.value(
        mutations.values.where((m) => m.productId == productId).toList(),
      );

  @override
  Future<List<StockMutationModel>> getMutationHistory(String productId) async =>
      mutations.values.where((m) => m.productId == productId).toList();

  @override
  Future<void> saveSyncOperation(SyncOperationModel operation) async =>
      syncOps[operation.id] = operation;

  @override
  Future<List<SyncOperationModel>> getPendingOperations() async =>
      syncOps.values.where((op) => op.status == 'pending').toList();

  @override
  Future<void> updateSyncOperation(SyncOperationModel operation) async =>
      syncOps[operation.id] = operation;

  @override
  Stream<List<SyncOperationModel>> watchPendingSyncOperations() {
    return Stream.value(
      syncOps.values.where((op) => op.status == 'pending').toList(),
    );
  }
}

//Fake Backend Always fails
class AlwaysFailingBackend implements MockBackendService {
  @override
  Future<void> sendMutation(StockMutation mutation) async {
    throw Exception('Simulated permanent failure');
  }
}

void main() {
  test(
    'rollback restores previous quantity after permanent sync failure',
    () async {
      final dataSource = FakeLocalDataSource();
      final repository = InventoryRepositoryImpl(
        localDataSource: dataSource,
        mockBackendService: AlwaysFailingBackend(),
      );

      // arange product starts at quantity 10
      await dataSource.saveProduct(
        ProductModel(
          id: 'p1',
          name: 'Test Product',
          quantity: 10,
          lastModified: DateTime.now(),
        ),
      );

      // 1. optimistic update to 15
      await repository.updateStock(
        productId: 'p1',
        newQuantity: 15,
        changedBy: 'tester',
      );
      final afterOptimistic = await repository.getProductById('p1');
      expect(
        afterOptimistic!.quantity,
        15,
      ); 

      // 2. run sync 3 times  matches maxRetries, forcing isFinal on the 3rd attempt
      await repository.syncPendingOperations();
      await repository.syncPendingOperations();
      await repository.syncPendingOperations();

      // assert rollback fired, quantity reverted to the pre-mutation value
      final afterRollback = await repository.getProductById('p1');
      expect(afterRollback!.quantity, 10);
    },
  );
}
