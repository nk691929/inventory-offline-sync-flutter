// features/inventory/presentation/screens/audit_log_screen.dart
import 'package:collaborative_inventory/features/inventory/domain/entities/sync_operation.dart';
import 'package:collaborative_inventory/features/inventory/presentations/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuditLogScreen extends ConsumerWidget {
  final String productId;
  final String productName;

  const AuditLogScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      mutationHistoryWithStatusProvider(productId),
    );

    return Scaffold(
      appBar: AppBar(title: Text('$productName — History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No changes yet.'));
          }
          final sorted = [...items]
            ..sort(
              (a, b) => b.mutation.timestamp.compareTo(a.mutation.timestamp),
            );

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final m = sorted[index].mutation;
              final delta = m.resultingQuantity - m.previousQuantity;
              final isIncrease = delta >= 0;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isIncrease
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    child: Icon(
                      isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncrease ? Colors.green[700] : Colors.red[700],
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '${m.previousQuantity} → ${m.resultingQuantity}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isIncrease ? '(+$delta)' : '($delta)',
                        style: TextStyle(
                          color: isIncrease
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              m.changedBy,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(m.timestamp),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: statusChip(sorted[index].status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget statusChip(OperationStatus status) {
    switch (status) {
      case OperationStatus.synced:
        return const Chip(
          label: Text('Synced', style: TextStyle(fontSize: 11)),
          backgroundColor: Color(0xFFDFF5E1),
        );
      case OperationStatus.pending:
        return const Chip(
          label: Text('Pending', style: TextStyle(fontSize: 11)),
          backgroundColor: Color(0xFFFFF3D6),
        );
      case OperationStatus.failed:
        return const Chip(
          label: Text('Failed RB', style: TextStyle(fontSize: 11)),
          backgroundColor: Color(0xFFFFE0E0),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
