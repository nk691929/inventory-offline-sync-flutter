import 'package:collaborative_inventory/features/auth/presentations/providers/auth_provider.dart';
import 'package:collaborative_inventory/features/auth/presentations/screens/login_screen.dart';
import 'package:collaborative_inventory/features/inventory/domain/usecases/update_stock_usecase.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:collaborative_inventory/features/inventory/presentations/screens/add_product_screen.dart';
import 'package:collaborative_inventory/features/inventory/presentations/screens/audit_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collaborative_inventory/features/auth/domain/entities/user_role.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final Set<String> _inFlight = {};

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final pendingIds = ref.watch(pendingProductIdsProvider).value ?? {};
    final failedIds = ref.watch(failedProductIdsProvider).value ?? {};
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in.')));
    }

    final canEdit = currentUser.role.can(Permission.editStock);
    final canCreate = currentUser.role.can(Permission.createProduct);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
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
              final isFailed = failedIds.contains(product.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Text(
                      product.name.isNotEmpty
                          ? product.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Qty: ${product.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFailed)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.error_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                        )
                      else if (isPending)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.sync,
                            size: 18,
                            color: Colors.orange,
                          ),
                        ),
                      if (canEdit) ...[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _inFlight.contains(product.id)
                              ? null
                              : () => _updateStock(
                                  ref,
                                  product.id,
                                  product.quantity - 1,
                                  currentUser.email,
                                  currentUser.role,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _inFlight.contains(product.id)
                              ? null
                              : () => _updateStock(
                                  ref,
                                  product.id,
                                  product.quantity + 1,
                                  currentUser.email,
                                  currentUser.role,
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
    );
  }

  Future<void> _updateStock(
    WidgetRef ref,
    String productId,
    int newQuantity,
    String changedBy,
    UserRole role,
  ) async {
    if (_inFlight.contains(productId)) return;
    setState(() => _inFlight.add(productId));
    try {
      await ref
          .read(updateStockUseCaseProvider)
          .call(
            role: role,
            productId: productId,
            newQuantity: newQuantity,
            changedBy: changedBy,
          );

      await ref.read(syncQueueManagerProvider).triggerImmediateSyncIfOnline();
    } on PermissionDeniedException catch (e) {
      debugPrint('BLOCKED: ${e.message}');
    } finally {
      if (mounted) setState(() => _inFlight.remove(productId));
    }
  }
}
