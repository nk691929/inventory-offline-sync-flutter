import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../datasource/local/fake_local_datasource.dart';
import 'inventory_repository_impl_test.dart';

void main(){
  test('product quantity rolls back to previousQuantity after maxRetries is exhausted', () async {
  final dataSource = FakeLocalDataSource();
  final repository = InventoryRepositoryImpl(
    localDataSource: dataSource,
    mockBackendService: AlwaysFailingBackend(),
  );

  await dataSource.saveProduct(ProductModel(
    id: 'p1', name: 'Test', quantity: 30, lastModified: DateTime.now(),
  ));

  await repository.updateStock(productId: 'p1', newQuantity: 31, changedBy: 'tester');
  expect((await repository.getProductById('p1'))!.quantity, 31);

  // Attempt 1 
  await repository.syncPendingOperations();
  expect((await repository.getProductById('p1'))!.quantity, 31); 

  // Attempt 2 
  await repository.syncPendingOperations();
  expect((await repository.getProductById('p1'))!.quantity, 31); 

  // Attemp 3
  await repository.syncPendingOperations();
  expect((await repository.getProductById('p1'))!.quantity, 30); 
});
}