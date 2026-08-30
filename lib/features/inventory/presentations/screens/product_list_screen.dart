import 'package:collaborative_inventory/features/auth/presentations/providers/auth_provider.dart';
import 'package:collaborative_inventory/features/auth/presentations/screens/login_screen.dart';
import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:collaborative_inventory/features/inventory/presentations/screens/audit_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final pendingIds = ref.watch(pendingProductIdsProvider).value ?? {};
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in.')));
    }

    final canEdit = currentUser.role.can(Permission.editStock);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products yet.'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isPending = pendingIds.contains(product.id);

              return ListTile(
                title: Text(product.name),
                subtitle: Text('Qty: ${product.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPending)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.sync, size: 18, color: Colors.orange),
                      ),
                    if (canEdit) ...[
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateStock(
                          ref,
                          product.id,
                          product.quantity - 1,
                          currentUser.email,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _updateStock(
                          ref,
                          product.id,
                          product.quantity + 1,
                          currentUser.email,
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuditLogScreen(
                      productId: product.id,
                      productName: product.name,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () {
                ref
                    .read(inventoryRepositoryProvider)
                    .addProduct(
                      Product(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'Test Product',
                        quantity: 10,
                        lastModified: DateTime.now(),
                      ),
                    );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _updateStock(
    WidgetRef ref,
    String productId,
    int newQuantity,
    String changedBy,
  ) async {
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .updateStock(
            productId: productId,
            newQuantity: newQuantity,
            changedBy: changedBy,
          );
      await ref.read(syncQueueManagerProvider).triggerImmediateSyncIfOnline();
    } catch (e) {
      // will handle
    }
  }
}
