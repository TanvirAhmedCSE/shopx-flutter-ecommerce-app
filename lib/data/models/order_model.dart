import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final String image;

  OrderItem({
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'price': price,
    'quantity': quantity,
    'image': image,
  };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
    title: m['title'] as String,
    price: (m['price'] as num).toDouble(),
    quantity: m['quantity'] as int,
    image: m['image'] as String,
  );
}

@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final List<OrderItem> items;

  @HiveField(2)
  final double subtotal;

  @HiveField(3)
  final double shippingCost;

  @HiveField(4)
  final double total;

  @HiveField(5)
  final String shippingLabel;

  @HiveField(6)
  final String shippingTime;

  @HiveField(7)
  final String fullName;

  @HiveField(8)
  final String address;

  @HiveField(9)
  final String city;

  @HiveField(10)
  final String zip;

  @HiveField(11)
  final DateTime placedAt;

  @HiveField(12)
  final String status;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.shippingLabel,
    required this.shippingTime,
    required this.fullName,
    required this.address,
    required this.city,
    required this.zip,
    required this.placedAt,
    this.status = 'Order Placed',
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'items': items.map((e) => e.toMap()).toList(),
    'subtotal': subtotal,
    'shippingCost': shippingCost,
    'total': total,
    'shippingLabel': shippingLabel,
    'shippingTime': shippingTime,
    'fullName': fullName,
    'address': address,
    'city': city,
    'zip': zip,
    'placedAt': placedAt.toIso8601String(),
    'status': status,
  };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    orderId: m['orderId'] as String,
    items: (m['items'] as List)
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    subtotal: (m['subtotal'] as num).toDouble(),
    shippingCost: (m['shippingCost'] as num).toDouble(),
    total: (m['total'] as num).toDouble(),
    shippingLabel: m['shippingLabel'] as String,
    shippingTime: m['shippingTime'] as String,
    fullName: m['fullName'] as String,
    address: m['address'] as String,
    city: m['city'] as String,
    zip: m['zip'] as String,
    placedAt: DateTime.parse(m['placedAt'] as String),
    status: (m['status'] as String?) ?? 'Order Placed',
  );
}
