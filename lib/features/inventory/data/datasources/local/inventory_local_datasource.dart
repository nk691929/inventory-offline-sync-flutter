import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';

abstract class InventoryLocalDataSource {
  Stream<List<ProductModel>> watchProducts();
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<ProductModel?> getProductById(String productId);

  Future<void> saveStockMutation(StockMutationModel mutation);
  Stream<List<StockMutationModel>> watchMutationHistory(String productId);
  Future<List<StockMutationModel>> getMutationHistory(String productId);

  Stream<List<SyncOperationModel>> watchAllSyncOperations();
  Future<void> saveSyncOperation(SyncOperationModel operation);
  Future<List<SyncOperationModel>> getPendingOperations();
  Future<void> updateSyncOperation(SyncOperationModel operation);
  Stream<List<SyncOperationModel>> watchPendingSyncOperations();
  Stream<List<SyncOperationModel>> watchFailedSyncOperations();
}
