import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../home/home_controller.dart';

class ProductSearchController extends GetxController {
  final query = ''.obs;

  // Filter state
  final selectedCategories = <String>{}.obs; // empty = all
  final priceMin = 0.0.obs;
  final priceMax = 500000.0.obs;
  final ratingMin = 0.0.obs;
  final ratingMax = 5.0.obs;
  final ratingCountMin = 0.0.obs;
  final ratingCountMax = 500.0.obs;

  bool get hasActiveFilters =>
      selectedCategories.isNotEmpty ||
      priceMin.value > 0 ||
      priceMax.value < 500000 ||
      ratingMin.value > 0 ||
      ratingMax.value < 5 ||
      ratingCountMin.value > 0 ||
      ratingCountMax.value < 500;

  // Results
  List<ProductModel> get results {
    final all = Get.find<HomeController>().products;
    return all.where((p) {
      // text query
      if (query.isNotEmpty) {
        final q = query.value.toLowerCase();
        if (!p.title.toLowerCase().contains(q) &&
            !p.category.toLowerCase().contains(q))
          return false;
      }
      // category filter
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(p.category))
        return false;

      if (p.price < priceMin.value || p.price > priceMax.value) return false;
      // rating filter
      if (p.rating < ratingMin.value || p.rating > ratingMax.value)
        return false;
      // rating count filter
      final count = p.ratingCount.toDouble();
      if (count < ratingCountMin.value || count > ratingCountMax.value) {
        return false;
      }
      return true;
    }).toList();
  }

  void resetFilters() {
    selectedCategories.clear();
    priceMin(0.0);
    priceMax(500000.0);
    ratingMin(0.0);
    ratingMax(5.0);
    ratingCountMin(0.0);
    ratingCountMax(500.0);
  }

  void toggleCategory(String cat) {
    if (selectedCategories.contains(cat)) {
      selectedCategories.remove(cat);
    } else {
      selectedCategories.add(cat);
    }
  }
}
