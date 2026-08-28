import 'dart:async';

import 'package:collaborative_inventory/core/network/connectivity_service.dart';
import 'package:collaborative_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class SyncQueueManager {
  final ConnectivityService connectivityService;
  final InventoryRepository repository;

  StreamSubscription<bool>? _subscription;

  SyncQueueManager({
    required this.connectivityService,
    required this.repository,
  });

  void startListening() {
    _subscription = connectivityService.onConnectivityChanged.listen((
      isOnline,
    ) {
      if (isOnline) {
        repository.syncPendingOperations();
      }
    });
  }

  Future<void> triggerImmediateSyncIfOnline() async {
    final isOnline = await connectivityService.isConnected;
    if (isOnline) {
      await repository.syncPendingOperations();
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
