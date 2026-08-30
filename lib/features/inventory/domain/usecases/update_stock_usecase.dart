import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);
}

class UpdateStockUseCase {
  final InventoryRepository repository;
  const UpdateStockUseCase({required this.repository});

  Future<StockMutation> call({
    required UserRole role,
    required String productId,
    required int newQuantity,
    required String changedBy,
  }) async {
    if (!role.can(Permission.editStock)) {
      throw PermissionDeniedException(
        'Role $role does not have permission to edit stock.',
      );
    }
    return repository.updateStock(
      productId: productId,
      newQuantity: newQuantity,
      changedBy: changedBy,
    );
  }
}
