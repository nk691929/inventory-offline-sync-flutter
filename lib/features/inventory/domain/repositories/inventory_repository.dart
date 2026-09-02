import 'package:collaborative_inventory/features/inventory/domain/entities/mutation_with_status.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';

abstract class InventoryRepository {
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String productId);
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String productId);

  Future<StockMutation> updateStock({
    required String productId,
    required int newQuantity,
    required String changedBy,
  });
  Stream<List<StockMutation>> watchMutationHistory(String productId);
  Stream<List<MutationWithStatus>> watchMutationHistoryWithStatus(String productId);

  Future<void> enqueueOperation(SyncOperation operation);
  Future<void> syncPendingOperations();
  Stream<Set<String>> watchPendingProductIds();
  Stream<Set<String>> watchFailedProductIds();
}
