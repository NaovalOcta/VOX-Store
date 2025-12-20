// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProductModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      api_id: fields[0] as int?,
      name: fields[1] as String,
      price: fields[2] as String,
      images: (fields[3] as List).cast<String>(),
      brand: fields[4] as String?,
      category: fields[5] as String?,
      gender: fields[6] as String?,
      quantity: fields[7] as int,
      description: fields[8] as String?,
      country: fields[9] as String?,
      type: fields[10] as String?,
      sizes: (fields[11] as List).cast<String>(),
      grades: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.api_id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.country)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.sizes)
      ..writeByte(12)
      ..write(obj.grades);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
