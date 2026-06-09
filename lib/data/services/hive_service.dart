import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class HiveService {
  static const _profileBox = 'profile';

  // uid-based box names
  static String _cartBoxName(String uid) => 'cart_$uid';
  static String _favBoxName(String uid) => 'favorites_$uid';
  static String _ordersBoxName(String uid) => 'orders_$uid';

  // Open user-specific boxes after login/splash
  static Future<void> openUserBoxes(String uid) async {
    if (!Hive.isBoxOpen(_cartBoxName(uid))) {
      await Hive.openBox<CartItem>(_cartBoxName(uid));
    }
    if (!Hive.isBoxOpen(_favBoxName(uid))) {
      await Hive.openBox<ProductModel>(_favBoxName(uid));
    }
    if (!Hive.isBoxOpen(_ordersBoxName(uid))) {
      await Hive.openBox<OrderModel>(_ordersBoxName(uid));
    }
  }

  // Profile
  static Box get _pBox => Hive.box(_profileBox);

  static bool get isProfileSetup =>
      _pBox.get('name', defaultValue: '').toString().isNotEmpty;

  static bool isHiveEmpty() =>
      _pBox.get('name', defaultValue: '').toString().isEmpty;

  static String get name => _pBox.get('name', defaultValue: '') as String;
  static String get email => _pBox.get('email', defaultValue: '') as String;
  static String get avatarPath =>
      _pBox.get('avatarPath', defaultValue: '') as String;

  static Future<void> saveProfile({
    required String name,
    required String email,
    required String avatarPath,
  }) async {
    await _pBox.put('name', name);
    await _pBox.put('email', email);
    await _pBox.put('avatarPath', avatarPath);
  }

  static Future<void> restoreFromMap(Map<String, dynamic> data) async {
    await _pBox.put('name', data['name'] ?? '');
    await _pBox.put('email', data['email'] ?? '');
    await _pBox.put('avatarPath', data['avatarPath'] ?? '');
  }

  static Future<void> clearProfile() async => _pBox.clear();

  // Cart (uid-based)
  static Box<CartItem> cartBox(String uid) =>
      Hive.box<CartItem>(_cartBoxName(uid));

  // Favorites (uid-based)
  static Box<ProductModel> favBox(String uid) =>
      Hive.box<ProductModel>(_favBoxName(uid));

  // Orders (uid-based)
  static Box<OrderModel> ordersBox(String uid) =>
      Hive.box<OrderModel>(_ordersBoxName(uid));

  static List<OrderModel> getOrders(String uid) {
    final orders = ordersBox(uid).values.toList();
    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders;
  }

  static bool isOrdersEmpty(String uid) => ordersBox(uid).isEmpty;

  static Future<void> saveOrder(String uid, OrderModel order) async {
    await ordersBox(uid).put(order.orderId, order);
  }

  static Future<void> saveOrderList(String uid, List<OrderModel> orders) async {
    for (final o in orders) {
      await ordersBox(uid).put(o.orderId, o);
    }
  }
}
