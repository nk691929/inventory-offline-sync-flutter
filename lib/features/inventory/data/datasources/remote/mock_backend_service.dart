import 'dart:math';

import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
}

abstract class MockBackendService {
  Future<void> sendMutation(StockMutation mutation);
}

class MockBackendServiceImpl implements MockBackendService {
  final Map<String, DateTime> _lastAcceptedTimestamps = {};
  final Random _random = Random();

  @override
  Future<void> sendMutation(StockMutation mutation) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lastTimestamp = _lastAcceptedTimestamps[mutation.productId];
    if (lastTimestamp != null && mutation.timestamp.isBefore(lastTimestamp)) {
      throw ConflictException(
        'Mutation for ${mutation.productId} is older than the last accepted write.',
      );
    }

    if (_random.nextDouble() < 0.2) {
      throw Exception('Simulated network failure');
    }

    _lastAcceptedTimestamps[mutation.productId] = mutation.timestamp;
  }
}
