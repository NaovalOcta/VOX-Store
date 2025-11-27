import 'package:hive/hive.dart';

part 'CartItemModel.g.dart';

@HiveType(typeId: 2) // ID Hive harus beda dengan Product (Product=1)
class CartItem extends HiveObject {
  @HiveField(0)
  final int? id; // ID dari tabel cart Supabase (bisa null jika offline sementara)

  @HiveField(1)
  final int product_id;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String price; // Disimpan sbg string "$100.00"

  @HiveField(4)
  int quantity;

  @HiveField(5)
  final String size;

  @HiveField(6)
  final String image_url; // Disimpan string untuk keperluan offline

  CartItem({
    this.id,
    required this.product_id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.image_url,
  });

  // Factory untuk mengambil data dari Join Supabase (cart + products)
  factory CartItem.fromSupabase(Map<String, dynamic> json) {
    final productData = json['products']; // Relasi tabel products
    return CartItem(
      id: json['id'],
      product_id: json['product_id'],
      quantity: json['quantity'],
      size: json['size'] ?? '40',
      // Ambil detail dari tabel products yang di-join
      name: productData != null ? productData['product_name'] : 'Unknown',
      // Format harga sederhana
      price: productData != null 
          ? '\$${(productData['unit_price'] as num).toStringAsFixed(2)}' 
          : '\$0.00',
      image_url: '', // Nanti diisi logic gambar
    );
  }

  // Untuk menghitung total harga (menghapus simbol $)
  double get priceValue {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
}