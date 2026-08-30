import 'package:collaborative_inventory/features/inventory/data/datasources/remote/mock_backend_service.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

class ConflictOnlyBackend implements MockBackendService {
  final Map<String, DateTime> _lastAcceptedTimestamps = {};

  @override
  Future<void> sendMutation(StockMutation mutation) async {
    final lastTimestamp = _lastAcceptedTimestamps[mutation.productId];
    if (lastTimestamp != null && mutation.timestamp.isBefore(lastTimestamp)) {
      throw ConflictException(
        'Mutation for ${mutation.productId} is older than the last accepted write.',
      );
    }
    _lastAcceptedTimestamps[mutation.productId] = mutation.timestamp;
  }
}