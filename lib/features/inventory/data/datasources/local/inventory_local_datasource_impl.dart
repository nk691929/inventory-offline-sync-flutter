import 'dart:async';

import 'package:hive/hive.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';

import 'inventory_local_datasource.dart';

class HiveBoxNames {
  static const productBox = 'products_box';
  static const mutationBox = 'mutations_box';
  static const syncQueueBox = 'sync_queue_box';
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final Box<ProductModel> productBox;
  final Box<StockMutationModel> mutationBox;
  final Box<SyncOperationModel> syncQueueBox;

  InventoryLocalDataSourceImpl({
    required this.productBox,
    required this.mutationBox,
    required this.syncQueueBox,
  });

  @override
  Stream<List<ProductModel>> watchProducts() {
    return productBox.watch().map((_) => productBox.values.toList());
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await productBox.delete(productId);
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    return productBox.get(productId);
  }

  @override
  Future<void> saveStockMutation(StockMutationModel mutation) async {
    await mutationBox.put(mutation.id, mutation);
  }

  @override
  Stream<List<StockMutationModel>> watchMutationHistory(String productId) {
    return mutationBox.watch().map(
      (_) => mutationBox.values.where((m) => m.productId == productId).toList(),
    );
  }

  @override
  Future<void> saveSyncOperation(SyncOperationModel operation) async {
    await syncQueueBox.put(operation.id, operation);
  }

  @override
  Future<List<SyncOperationModel>> getPendingOperations() async {
    return syncQueueBox.values.where((op) => op.status == 'pending').toList();
  }

  @override
  Future<void> updateSyncOperation(SyncOperationModel operation) async {
    await syncQueueBox.put(operation.id, operation);
  }

  @override
  Future<List<StockMutationModel>> getMutationHistory(String productId) async {
    return mutationBox.values.where((m) => m.productId == productId).toList();
  }
}
