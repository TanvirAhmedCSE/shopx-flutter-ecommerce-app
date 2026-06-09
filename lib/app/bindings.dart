import 'package:get/get.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/bottom_nav/bottom_nav_controller.dart';
import '../modules/cart/cart_controller.dart';
import '../modules/chat/chat_controller.dart';
import '../modules/favorites/favorites_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/order_history/order_history_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(BottomNavController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(OrderHistoryController(), permanent: true);
  }
}
