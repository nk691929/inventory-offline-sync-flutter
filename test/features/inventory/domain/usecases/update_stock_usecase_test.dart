import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/usecases/update_stock_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/datasource/local/fake_local_datasource.dart';
import '../../data/datasource/remote/conflict_only_background.dart';

void main() {
  late FakeLocalDataSource dataSource;
  late UpdateStockUseCase useCase;

  final fixedTime = DateTime(2026, 1, 1);

  setUp(() {
    dataSource = FakeLocalDataSource();
    final repository = InventoryRepositoryImpl(
      localDataSource: dataSource,
      mockBackendService: ConflictOnlyBackend(),
    );
    useCase = UpdateStockUseCase(repository: repository);
  });

  Future<void> seedProduct({required String id, required int quantity}) {
    return dataSource.saveProduct(
      ProductModel(
        id: id,
        name: 'Test Product',
        quantity: quantity,
        lastModified: fixedTime,
      ),
    );
  }

  group('UpdateStockUseCase', () {
    test('viewer is blocked from editing stock and quantity is unchanged',
        () async {
      // ARRANGE
      await seedProduct(id: 'p1', quantity: 10);

      // ACT + ASSERT (refused)
      await expectLater(
        () => useCase.call(
          role: UserRole.viewer,
          productId: 'p1',
          newQuantity: 99,
          changedBy: 'viewer-user',
        ),
        throwsA(isA<PermissionDeniedException>()),
      );

      // ASSERT (no side effect)
      final product = await dataSource.getProductById('p1');
      expect(product!.quantity, 10);
    });

    test('manager can edit stock and the new quantity is saved', () async {
      // ARRANGE
      await seedProduct(id: 'p1', quantity: 10);

      // ACT
      final result = await useCase.call(
        role: UserRole.manager,
        productId: 'p1',
        newQuantity: 8,
        changedBy: 'manager-user',
      );

      // ASSERT (receipt)
      expect(result.previousQuantity, 10);
      expect(result.resultingQuantity, 8);

      // ASSERT (saved data)
      final product = await dataSource.getProductById('p1');
      expect(product!.quantity, 8);
    });
  });
}