import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../datasource/local/fake_local_datasource.dart';
import '../datasource/remote/conflict_only_background.dart';

void main() {
  test('older mutation is rejected and rolled back when a newer write already synced', () async {
    final dataSource = FakeLocalDataSource();
    final backend = ConflictOnlyBackend();
    final repository = InventoryRepositoryImpl(
      localDataSource: dataSource,
      mockBackendService: backend,
    );

    await dataSource.saveProduct(
      ProductModel(
        id: 'p1',
        name: 'Contested Product',
        quantity: 10,
        lastModified: DateTime.now(),
      ),
    );

    await repository.updateStock(
      productId: 'p1',
      newQuantity: 99,
      changedBy: 'you',
    );

    await Future.delayed(const Duration(milliseconds: 10));

    await backend.sendMutation(
      StockMutation(
        id: 'other-device',
        productId: 'p1',
        previousQuantity: 10,
        resultingQuantity: 500,
        type: MutationType.adjustment,
        timestamp: DateTime.now(),
        changedBy: 'other-device',
      ),
    );

    await repository.syncPendingOperations();

    final finalProduct = await repository.getProductById('p1');

    expect(finalProduct!.quantity, isNot(99));
    expect(finalProduct.quantity, isNot(500));
    expect(finalProduct.quantity, 10);
  });
}
