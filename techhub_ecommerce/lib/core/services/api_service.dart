import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../models/product_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConstants.baseUrl;

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await _dio.get('$_baseUrl/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return [
          {'id': 0, 'name': 'All'},
          ...data,
        ];
      }
      return [{'id': 0, 'name': 'All'}];
    } catch (e) {
      return [{'id': 0, 'name': 'All'}];
    }
  }

  Future<List<Product>> fetchProducts({int categoryId = 0, String search = ''}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/products',
        queryParameters: {
          if (categoryId > 0) 'category_id': categoryId,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> fetchTopWeeklySearches() async {
    try {
      final response = await _dio.get('$_baseUrl/search/top-weekly');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
      return ["iPhone 16", "MacBook", "AirPods", "Sony", "Charger"];
    } catch (e) {
      return ["iPhone 16", "MacBook", "AirPods", "Sony", "Charger"];
    }
  }

  Future<List<dynamic>> fetchCart() async {
    try {
      final response = await _dio.get('$_baseUrl/cart');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}