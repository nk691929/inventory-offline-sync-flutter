class Product {
  final String id;
  final String name;
  final int quantity;
  final DateTime lastModified;

  const Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.lastModified,
  });
}