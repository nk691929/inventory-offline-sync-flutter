import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';

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
