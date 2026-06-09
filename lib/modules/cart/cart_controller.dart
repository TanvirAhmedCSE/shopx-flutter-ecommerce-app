import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/services/hive_service.dart';
import 'package:flutter/material.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;
  Box<CartItem>? _cartBox;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && Hive.isBoxOpen('cart_$uid')) {
      _cartBox = HiveService.cartBox(uid);
      cartItems.assignAll(_cartBox!.values.toList());
    }
  }

  void reloadForUser(String uid) {
    _cartBox = HiveService.cartBox(uid);
    cartItems.assignAll(_cartBox!.values.toList());
  }

  void toggleCart(ProductModel product) {
    if (isInCart(product.id)) {
      removeFromCart(product.id);
      Get.snackbar(
        'Removed from Cart',
        product.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } else {
      final item = CartItem(
        productId: product.id,
        title: product.title,
        price: product.price,
        image: product.image,
      );
      _cartBox?.add(item);
      cartItems.add(item);
      cartItems.refresh();
      Get.snackbar(
        'Added to Cart',
        product.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void removeFromCart(int productId) {
    final item = cartItems.firstWhereOrNull((e) => e.productId == productId);
    if (item != null) {
      final key = _cartBox?.keys.firstWhere(
        (k) => _cartBox!.get(k)?.productId == productId,
        orElse: () => null,
      );
      if (key != null) _cartBox?.delete(key);
      cartItems.remove(item);
    }
  }

  void increment(int productId) {
    final item = cartItems.firstWhereOrNull((e) => e.productId == productId);
    if (item != null) {
      item.quantity++;
      final key = _cartBox?.keys.firstWhere(
        (k) => _cartBox!.get(k)?.productId == productId,
        orElse: () => null,
      );
      if (key != null) _cartBox?.put(key, item);
      cartItems.refresh();
    }
  }

  void decrement(int productId) {
    final item = cartItems.firstWhereOrNull((e) => e.productId == productId);
    if (item != null) {
      if (item.quantity > 1) {
        item.quantity--;
        final key = _cartBox?.keys.firstWhere(
          (k) => _cartBox!.get(k)?.productId == productId,
          orElse: () => null,
        );
        if (key != null) _cartBox?.put(key, item);
        cartItems.refresh();
      } else {
        removeFromCart(productId);
      }
    }
  }

  void clearCart() {
    _cartBox?.clear();
    cartItems.clear();
  }

  bool isInCart(int productId) =>
      cartItems.any((e) => e.productId == productId);

  double get totalPrice =>
      cartItems.fold(0, (sum, e) => sum + (e.price * e.quantity));

  int get totalItems => cartItems.fold(0, (sum, e) => sum + e.quantity);
}
