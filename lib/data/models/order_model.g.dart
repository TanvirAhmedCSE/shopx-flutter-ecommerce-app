// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 2;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      title: fields[0] as String,
      price: fields[1] as double,
      quantity: fields[2] as int,
      image: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      orderId: fields[0] as String,
      items: (fields[1] as List).cast<OrderItem>(),
      subtotal: fields[2] as double,
      shippingCost: fields[3] as double,
      total: fields[4] as double,
      shippingLabel: fields[5] as String,
      shippingTime: fields[6] as String,
      fullName: fields[7] as String,
      address: fields[8] as String,
      city: fields[9] as String,
      zip: fields[10] as String,
      placedAt: fields[11] as DateTime,
      status: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.subtotal)
      ..writeByte(3)
      ..write(obj.shippingCost)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.shippingLabel)
      ..writeByte(6)
      ..write(obj.shippingTime)
      ..writeByte(7)
      ..write(obj.fullName)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.city)
      ..writeByte(10)
      ..write(obj.zip)
      ..writeByte(11)
      ..write(obj.placedAt)
      ..writeByte(12)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
