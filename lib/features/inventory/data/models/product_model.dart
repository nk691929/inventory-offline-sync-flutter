import 'package:collaborative_inventory/features/inventory/domain/entities/product.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final DateTime lastModified;

  ProductModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.lastModified,
  });

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      quantity: quantity,
      lastModified: lastModified,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      quantity: product.quantity,
      lastModified: product.lastModified,
    );
  }
}
