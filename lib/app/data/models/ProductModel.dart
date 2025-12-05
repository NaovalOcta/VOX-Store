import 'package:hive/hive.dart';

part 'ProductModel.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  final int? api_id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String price;

  // --- FIELD BARU (WAJIB DITAMBAHKAN) ---
  @HiveField(3)
  final String? image_url;

  @HiveField(4)
  final String? brand;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final String? gender;

  @HiveField(7)
  final int quantity;

  Product({
    this.api_id,
    required this.name,
    required this.price,
    this.image_url,
    this.brand,
    this.category,
    this.gender,
    this.quantity = 0,
  });

  factory Product.fromSupabase(Map<String, dynamic> json) {
    return Product(
      api_id: json['id'], // ID dari Supabase
      name: json['product_name'] ?? 'No Name', 
      // Konversi harga angka (db) ke String berformat Dollar ($)
      price: json['unit_price'] != null ? "\$${json['unit_price']}" : "\$0.00",
      
      // Mapping field baru
      image_url: json['image_url'],
      brand: json['brand'],
      category: json['category'],
      gender: json['gender'],
      quantity: json['quantity'] ?? 0,
    );
  }
}