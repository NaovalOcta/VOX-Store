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
      api_id: fields[0] as int,
      date: fields[1] as String,
      name: fields[2] as String,
      product_type: fields[3] as String,
      brand: fields[4] as String,
      gender: fields[5] as String,
      category: fields[6] as String,
      country: fields[7] as String,
      quantity: fields[8] as int,
      price: fields[9] as String,
      amount: fields[10] as double,
      payment_mode: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.api_id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.product_type)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.price)
      ..writeByte(10)
      ..write(obj.amount)
      ..writeByte(11)
      ..write(obj.payment_mode);
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
