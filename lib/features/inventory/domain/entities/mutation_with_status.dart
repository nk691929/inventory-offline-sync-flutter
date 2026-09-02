import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';

class MutationWithStatus {
  final StockMutation mutation;
  final OperationStatus status;
  const MutationWithStatus({required this.mutation, required this.status});
}
