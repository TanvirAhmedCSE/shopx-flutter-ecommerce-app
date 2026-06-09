import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductProvider {
  static const String _base = 'https://fakestoreapi.com';

  Future<List<ProductModel>> fetchProducts() async {
    final res = await http.get(Uri.parse('$_base/products'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<List<String>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/products/categories'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return ['all', ...data.map((e) => e.toString())];
    }
    throw Exception('Failed to load categories');
  }
}
