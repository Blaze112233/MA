import 'package:flutter/foundation.dart';

class ApiConstants {
  // If running on a real phone via Wi-Fi, change this IP to your computer's IP
  static const String _phoneIp = '192.168.1.5';

  // Automatically selects 127.0.0.1 for Chrome web, preventing network IP issues
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api/v1';
    }
    return 'http://$_phoneIp:5000/api/v1';
  }

  static String get authUrl => '$baseUrl/auth';
  static String get userUrl => '$baseUrl/user';
  static String get productsUrl => '$baseUrl/products';
  static String get categoriesUrl => '$baseUrl/categories';
  static String get searchTrendsUrl => '$baseUrl/search/top-weekly';
  static String get checkoutUrl => '$baseUrl/orders/checkout';
}