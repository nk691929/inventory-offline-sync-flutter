// features/inventory/presentation/screens/audit_log_screen.dart
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuditLogScreen extends ConsumerWidget {
  final String productId;
  final String productName;

  const AuditLogScreen({super.key, required this.productId, required this.productName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mutationHistoryProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text('$productName — History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (mutations) {
          if (mutations.isEmpty) {
            return const Center(child: Text('No changes yet.'));
          }
          final sorted = [...mutations]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final m = sorted[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text('${m.previousQuantity} → ${m.resultingQuantity}'),
                subtitle: Text('${m.changedBy} • ${m.timestamp.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}