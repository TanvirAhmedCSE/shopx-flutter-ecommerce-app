import 'package:get/get.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/hive_service.dart';
import '../../app/routes.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/chat/chat_controller.dart';
import '../../modules/favorites/favorites_controller.dart';
import '../../modules/order_history/order_history_controller.dart';
import '../../modules/bottom_nav/bottom_nav_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  Future<void> signOut() async {
    ChatController.to.closeListener();
    await FirebaseService.signOut();

    // Clear profile box only — uid boxes stay intact for next login
    await HiveService.clearProfile();

    // Clear in-memory observables
    Get.find<CartController>().cartItems.clear();
    Get.find<FavoritesController>().favorites.clear();
    Get.find<OrderHistoryController>().orders.clear();

    // ADD THIS:
    Get.find<BottomNavController>().currentIndex.value = 0;
    Get.offAllNamed(AppRoutes.login);
  }
}
