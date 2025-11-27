// lib/app/data/models/FullProductModel.dart

// Ini BUKAN model Hive. Ini model murni Dart untuk CRUD Admin.
class FullProductModel {
  final int id; // ID dari database Supabase (bukan api_id)
  final String date;
  final String name;
  final String product_type;
  final String brand;
  final String gender;
  final String category;
  final String country;
  final int quantity;
  final double unit_price;
  final double amount;
  final String payment_mode;

  FullProductModel({
    required this.id,
    required this.date,
    required this.name,
    required this.product_type,
    required this.brand,
    required this.gender,
    required this.category,
    required this.country,
    required this.quantity,
    required this.unit_price,
    required this.amount,
    required this.payment_mode,
  });

  // Factory untuk parsing data lengkap dari Supabase
  factory FullProductModel.fromSupabase(Map<String, dynamic> json) {
    return FullProductModel(
      id: json['id'] ?? 0, // ID utama tabel
      date: json['date'] ?? 'N/A',
      name: json['product_name'] ?? 'N/A',
      product_type: json['product_type'] ?? 'N/A',
      brand: json['brand'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      quantity: json['quantity'] ?? 0,
      unit_price: (json['unit_price'] as num? ?? 0.0).toDouble(),
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      payment_mode: json['payment_mode'] ?? 'N/A',
    );
  }

  // Fungsi untuk INSERT (tanpa id, karena id dibuat otomatis)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'date': date,
      'product_name': name,
      'product_type': product_type,
      'brand': brand,
      'gender': gender,
      'category': category,
      'country': country,
      'quantity': quantity,
      'unit_price': unit_price,
      'amount': amount,
      'payment_mode': payment_mode,
      // Kita tidak memasukkan 'api_id' karena data ini adalah sumbernya
    };
  }
  
  // Fungsi untuk UPDATE
  Map<String, dynamic> toJsonForUpdate() {
     // Sama seperti insert, tapi kita akan gunakan 'id' di query .eq()
     return toJsonForInsert();
  }
}