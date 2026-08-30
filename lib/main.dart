import 'package:collaborative_inventory/features/auth/presentations/screens/login_screen.dart';
import 'package:collaborative_inventory/features/inventory/data/datasources/local/inventory_local_datasource_impl.dart';
import 'package:collaborative_inventory/features/inventory/data/models/product_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/stock_mutation_model.dart';
import 'package:collaborative_inventory/features/inventory/data/models/sync_operation_model.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(StockMutationModelAdapter());
  Hive.registerAdapter(SyncOperationModelAdapter());

  final productBox = await Hive.openBox<ProductModel>(HiveBoxNames.productBox);
  final mutationBox = await Hive.openBox<StockMutationModel>(
    HiveBoxNames.mutationBox,
  );
  final syncOps = await Hive.openBox<SyncOperationModel>(
    HiveBoxNames.syncQueueBox,
  );

  runApp(
    ProviderScope(
      overrides: [
        productBoxProvider.overrideWithValue(productBox),
        mutationBoxProvider.overrideWithValue(mutationBox),
        syncQueueBoxProvider.overrideWithValue(syncOps),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
