import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';

abstract class InventoryRepository {
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String productId);
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String productId);

  //StockMutation
  Future<StockMutation> updateStock({
    required String productId,
    required int newQuantity,
    required String changedBy,
  });

  Stream<List<StockMutation>> watchMutationHistory(String productId);

  //Queue Operations
  Future<void> enqueueOperation(SyncOperation operation);
  Future<List<SyncOperation>> getPendingOperations();
  Future<void> markOperationSynced(String operationId);
  Future<void> markOperationFailed(
    String operationId, {
    required bool isFinal,
  });
}
