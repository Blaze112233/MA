import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WishlistProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  List<dynamic> _wishlistProducts = [];
  final Set<int> _favoriteIds = {};
  bool _isLoading = false;

  // Both getters so wishlist_screen and other screens work seamlessly
  List<dynamic> get items => _wishlistProducts;
  List<dynamic> get wishlistProducts => _wishlistProducts;
  bool get isLoading => _isLoading;

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  // Load wishlist from MySQL backend
  Future<void> fetchWishlist(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/v1/wishlist/$userId');
      if (response.statusCode == 200 && response.data is List) {
        _wishlistProducts = response.data;
        _favoriteIds.clear();
        for (var item in _wishlistProducts) {
          int? id;
          if (item is Map) {
            id = int.tryParse((item['id'] ?? item['product_id']).toString());
          } else {
            try {
              id = int.tryParse(item.id.toString());
            } catch (_) {}
          }
          if (id != null && id > 0) {
            _favoriteIds.add(id);
          }
        }
      }
    } catch (e) {
      debugPrint('[Wishlist Fetch Error]: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accepts named parameters matching wishlist_screen.dart
  Future<void> toggleFavorite({
    int? userId,
    dynamic productId,
    dynamic product,
  }) async {
    final effectiveUserId = userId ?? 1;

    // Extract product ID from either productId or product object
    int effectiveProdId = 0;
    if (productId != null) {
      effectiveProdId = int.tryParse(productId.toString()) ?? 0;
    } else if (product != null) {
      if (product is Map) {
        effectiveProdId = int.tryParse((product['id'] ?? product['product_id']).toString()) ?? 0;
      } else {
        try {
          effectiveProdId = int.tryParse(product.id.toString()) ?? 0;
        } catch (_) {}
      }
    }

    if (effectiveProdId == 0) return;

    // Optimistic UI toggle
    final wasFavorite = _favoriteIds.contains(effectiveProdId);
    if (wasFavorite) {
      _favoriteIds.remove(effectiveProdId);
      _wishlistProducts.removeWhere((p) {
        if (p is Map) {
          return (p['id'] ?? p['product_id']) == effectiveProdId;
        }
        try {
          return p.id == effectiveProdId;
        } catch (_) {
          return false;
        }
      });
    } else {
      _favoriteIds.add(effectiveProdId);
      if (product != null) {
        _wishlistProducts.add(product);
      }
    }
    notifyListeners();

    // Sync with backend API
    try {
      final res = await _dio.post(
        'http://127.0.0.1:5000/api/v1/wishlist/toggle',
        data: {
          'user_id': effectiveUserId,
          'product_id': effectiveProdId,
        },
      );

      if (res.statusCode != 200) {
        // Rollback on server failure
        if (wasFavorite) {
          _favoriteIds.add(effectiveProdId);
        } else {
          _favoriteIds.remove(effectiveProdId);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Wishlist Toggle Error]: $e');
      if (wasFavorite) {
        _favoriteIds.add(effectiveProdId);
      } else {
        _favoriteIds.remove(effectiveProdId);
      }
      notifyListeners();
    }
  }
}