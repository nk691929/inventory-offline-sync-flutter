import 'package:flutter_test/flutter_test.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

import '../datasource/local/fake_local_datasource.dart';
import '../datasource/remote/conflict_only_background.dart';

//Fake Backend Always fails
class AlwaysFailingBackend implements ConflictOnlyBackend {
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

      await dataSource.saveProduct(
        ProductModel(
          id: 'p1',
          name: 'Test Product',
          quantity: 10,
          lastModified: DateTime.now(),
        ),
      );

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

      await repository.syncPendingOperations();
      await repository.syncPendingOperations();
      await repository.syncPendingOperations();

      final afterRollback = await repository.getProductById('p1');
      expect(afterRollback!.quantity, 10);
    },
  );
}
