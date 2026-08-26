import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
}

abstract class MockBackendService {
  Future<void> sendMutation(StockMutation mutation);
}

class MockBackendServiceImpl implements MockBackendService {
  final Map<String, DateTime> _lastAcceptedTimestamp = {};

  @override
  Future<void> sendMutation(StockMutation mutation) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lastTimestamp = _lastAcceptedTimestamp[mutation.productId];
    if (lastTimestamp != null && mutation.timestamp.isBefore(lastTimestamp)) {
      throw ConflictException(
        'Mutation for ${mutation.productId} is older than the last accepted write.',
      );
    }

    if(DateTime.now().millisecond%5==0){
      throw Exception('Simulated network failure');
    }

    _lastAcceptedTimestamp[mutation.productId]=mutation.timestamp;
  }
}
