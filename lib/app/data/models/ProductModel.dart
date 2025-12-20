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

  @HiveField(3)
  final List<String> images; // Diubah jadi List agar bisa banyak gambar

  @HiveField(4)
  final String? brand;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final String? gender;

  @HiveField(7)
  final int quantity;

  // --- FIELD TAMBAHAN ---
  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? country;

  @HiveField(10)
  final String? type;

  @HiveField(11)
  final List<String> sizes;

  @HiveField(12)
  final List<String> grades;

  Product({
    this.api_id,
    required this.name,
    required this.price,
    required this.images,
    this.brand,
    this.category,
    this.gender,
    this.quantity = 0,
    this.description,
    this.country,
    this.type,
    this.sizes = const [],
    this.grades = const [],
  });

  // --- HELPER PARSING YANG SUDAH DIPERBAIKI ---
  static List<String> _parseList(dynamic input) {
    if (input == null) return [];

    try {
      // 1. Jika data sudah berupa List, bersihkan setiap itemnya
      if (input is List) {
        return input
            .map((e) {
              return e
                  .toString()
                  .replaceAll(
                    RegExp(r'[\[\]"{}]'),
                    '',
                  ) // Hapus kurung & petik dua
                  .replaceAll("'", "") // Hapus petik satu (aman)
                  .trim();
            })
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // 2. Jika data berupa String (misal dari Supabase array text[])
      if (input is String) {
        if (input.isEmpty) return [];
        // Bersihkan tanda kurung [] {} dan petik "
        String clean = input.replaceAll(RegExp(r'[\[\]"{}]'), '');
        // Bersihkan tanda petik satu ' secara terpisah agar tidak error RegExp
        clean = clean.replaceAll("'", "");

        // Pisahkan berdasarkan koma
        return clean
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print("Error parsing list data: $e");
      return [];
    }
    return [];
  }

  factory Product.fromSupabase(Map<String, dynamic> json) {
    return Product(
      api_id: json['id'],
      name: json['product_name']?.toString() ?? 'No Name',
      price: json['unit_price'] != null ? "Rp ${json['unit_price']}" : "Rp 0",

      // Menggunakan helper _parseList yang sudah diperbaiki
      images: _parseList(json['image_url']),
      sizes: _parseList(json['sizes']),
      grades: _parseList(json['grades']),

      brand: json['brand']?.toString(),
      category: json['category']?.toString(),
      gender: json['gender']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString(),
      country: json['country']?.toString(),
      type: json['product_type']?.toString(),
    );
  }
}
