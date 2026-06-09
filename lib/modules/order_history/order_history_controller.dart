import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/hive_service.dart';

class OrderHistoryController extends GetxController {
  static OrderHistoryController get to => Get.find();

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    isLoading(true);
    try {
      // Always load hive first
      final hiveOrders = HiveService.getOrders(uid);

      if (hiveOrders.isNotEmpty) {
        orders.assignAll(hiveOrders);
        isLoading(false);
        return;
      }

      // If hive is empty, load data from firestore
      final fetched = await FirebaseService.fetchOrders(uid);
      await HiveService.saveOrderList(uid, fetched);
      orders.assignAll(fetched);
    } catch (e) {
      print('[OrderHistory] load error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addOrder(OrderModel order) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    orders.insert(0, order);
    await HiveService.saveOrder(uid, order);

    FirebaseService.saveOrder(
      uid,
      order,
    ).catchError((e) => print('[OrderHistory] save error: $e'));
  }
}
