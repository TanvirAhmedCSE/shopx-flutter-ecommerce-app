import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/product_provider.dart';

class HomeController extends GetxController {
  final _provider = ProductProvider();

  final products = <ProductModel>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = 'all'.obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final showPromoBanner = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void triggerPromoBanner() {
    if (showPromoBanner.value) return;
    showPromoBanner(true);
    Future.delayed(const Duration(milliseconds: 5000), () {
      showPromoBanner(false);
    });
  }

  Future<void> loadData() async {
    try {
      isLoading(true);
      error('');
      final results = await Future.wait([
        _provider.fetchProducts(),
        _provider.fetchCategories(),
      ]);
      products.assignAll(results[0] as List<ProductModel>);
      categories.assignAll(results[1] as List<String>);
    } catch (e) {
      error('Failed to load products. Check your internet connection.');
    } finally {
      isLoading(false);
    }
  }

  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == 'all') return products;
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  void selectCategory(String cat) => selectedCategory(cat);
}
