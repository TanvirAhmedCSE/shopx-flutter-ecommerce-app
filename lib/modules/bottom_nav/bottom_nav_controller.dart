import 'package:get/get.dart';

class BottomNavController extends GetxController {
  static BottomNavController get to => Get.find();
  final currentIndex = 0.obs;

  void changePage(int index) => currentIndex.value = index;
}
