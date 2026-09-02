import 'package:flutter_test/flutter_test.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/usecases/update_stock_usecase.dart';

import '../../data/datasource/local/fake_local_datasource.dart';
import '../../data/datasource/remote/conflict_only_background.dart';

void main() {
  test(
    'viewer role is blocked from editing stock at the use case layer',
    () async {
      final dataSource = FakeLocalDataSource();
      final repository = InventoryRepositoryImpl(
        localDataSource: dataSource,
        mockBackendService: ConflictOnlyBackend(),
      );
      final useCase = UpdateStockUseCase(repository: repository);

      await dataSource.saveProduct(
        ProductModel(
          id: 'p1',
          name: 'Test',
          quantity: 10,
          lastModified: DateTime.now(),
        ),
      );

      expect(
        () => useCase.call(
          role: UserRole.viewer,
          productId: 'p1',
          newQuantity: 99,
          changedBy: 'sneaky-viewer',
        ),
        throwsA(isA<PermissionDeniedException>()),
      );

      final product = await dataSource.getProductById('p1');
      expect(product!.quantity, 10);
    },
  );
}
