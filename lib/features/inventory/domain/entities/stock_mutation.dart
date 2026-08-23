enum MutationType { increment, decrement, adjustment }

class StockMutation {
  final String id;
  final String productId;
  final int resultingQuantity;
  final MutationType type;
  final DateTime timestamp;
  final String changedBy;

  const StockMutation({
    required this.id,
    required this.productId,
    required this.resultingQuantity,
    required this.type,
    required this.timestamp,
    required this.changedBy,
  });
}