// lib/models/ProductModel.dart
import 'package:hive/hive.dart';

// Penting: Nama file .g.dart harus sesuai dengan nama file ini
part 'ProductModel.g.dart'; 

@HiveType(typeId: 1) // ID unik untuk model Hive
class Product extends HiveObject { // Extend HiveObject untuk manajemen box yang lebih mudah

  @HiveField(0)
  final int api_id; // id dari JSON

  @HiveField(1)
  final String date;

  @HiveField(2)
  final String name; // 'Product Name'

  @HiveField(3)
  final String product_type;

  @HiveField(4)
  final String brand;

  @HiveField(5)
  final String gender;

  @HiveField(6)
  final String category;
  
  @HiveField(7)
  final String country;

  @HiveField(8)
  final int quantity;

  @HiveField(9)
  final String price; // 'Unit Price ($)' - kita simpan sebagai string (misal "$141.82")

  @HiveField(10)
  final double amount;

  @HiveField(11)
  final String payment_mode;

  Product({
    required this.api_id,
    required this.date,
    required this.name,
    required this.product_type,
    required this.brand,
    required this.gender,
    required this.category,
    required this.country,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.payment_mode,
  });

  // Factory untuk parsing JSON dari Supabase
  // (Nama kolom di Supabase harus sama persis dengan key di sini)
  factory Product.fromSupabase(Map<String, dynamic> json) {
    
    // Konversi 'unit_price' (tipe numeric di DB) ke format string harga
    final priceNum = json['unit_price'] as num? ?? 0.0;
    final priceString = '\$${priceNum.toStringAsFixed(2)}';
    
    // Konversi 'amount' (tipe numeric di DB) ke double
    final amountNum = json['amount'] as num? ?? 0.0;

    return Product(
      api_id: json['api_id'] ?? 0,
      date: json['date'] ?? 'N/A',
      name: json['product_name'] ?? 'Product Name N/A',
      product_type: json['product_type'] ?? 'N/A',
      brand: json['brand'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      quantity: json['quantity'] ?? 0,
      price: priceString, // Gunakan string yang sudah diformat
      amount: amountNum.toDouble(),
      payment_mode: json['payment_mode'] ?? 'N/A',
    );
  }

  // Hapus factory 'fromJson' yang lama karena kita tidak lagi mengambil dari typicode
}