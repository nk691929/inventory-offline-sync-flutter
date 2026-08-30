import 'package:collaborative_inventory/core/providers/core_providers.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource_impl.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/remote/mock_backend_service.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/stock_mutation.dart';
import 'package:collaborative_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:collaborative_inventory/features/inventory/domain/services/sync_queue_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final productBoxProvider = Provider<Box<ProductModel>>(
  (ref) => throw ('Overridden in main.dart with ProviderScope(overrides: ...)'),
);

final mutationBoxProvider = Provider<Box<StockMutationModel>>((ref) {
  throw UnimplementedError('Overridden in main.dart');
});

final syncQueueBoxProvider = Provider<Box<SyncOperationModel>>((ref) {
  throw UnimplementedError('Overridden in main.dart');
});

final localDataSourceProvider = Provider<InventoryLocalDataSource>(
  (ref) => InventoryLocalDataSourceImpl(
    productBox: ref.watch(productBoxProvider),
    mutationBox: ref.watch(mutationBoxProvider),
    syncQueueBox: ref.watch(syncQueueBoxProvider),
  ),
);

final mockBackendServiceProvider = Provider<MockBackendService>(
  (ref) => MockBackendServiceImpl(),
);

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepositoryImpl(
    localDataSource: ref.watch(localDataSourceProvider),
    mockBackendService: ref.watch(mockBackendServiceProvider),
  ),
);

final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  final manager = SyncQueueManager(
    connectivityService: ref.watch(connectivityServiceProvider),
    repository: ref.watch(inventoryRepositoryProvider),
  );
  manager.startListening();
  ref.onDispose(() => manager.dispose());
  return manager;
});

final productsStreamProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(inventoryRepositoryProvider).watchProducts(),
);

final pendingProductIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(inventoryRepositoryProvider).watchPendingProductIds(),
);

final mutationHistoryProvider =
    StreamProvider.family<List<StockMutation>, String>(
      (ref, productId) => ref
          .watch(inventoryRepositoryProvider)
          .watchMutationHistory(productId),
    );