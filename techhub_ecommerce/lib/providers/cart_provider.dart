import 'package:flutter/material.dart';

class CartItem {
  final dynamic product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Safe helper getters to work with both Maps and Model Objects
  int get id {
    if (product is Map) {
      return int.tryParse((product['id'] ?? product['product_id'] ?? 0).toString()) ?? 0;
    }
    try {
      return int.tryParse(product.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String get name {
    if (product is Map) return product['name']?.toString() ?? 'Device';
    try {
      return product.name?.toString() ?? 'Device';
    } catch (_) {
      return 'Device';
    }
  }

  double get price {
    if (product is Map) {
      return double.tryParse((product['price'] ?? 0.0).toString()) ?? 0.0;
    }
    try {
      return double.tryParse(product.price.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  String get imageUrl {
    if (product is Map) {
      return product['image_url']?.toString() ?? product['imageUrl']?.toString() ?? '';
    }
    try {
      return product.imageUrl?.toString() ?? product.image_url?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> toJson() => {
    'product_id': id,
    'id': id,
    'name': name,
    'price': price,
    'unit_price': price,
    'quantity': quantity,
    'image_url': imageUrl,
  };
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Required by checkout_screen: cart.items.map((item) { ... }).toList()
  List<CartItem> get items => _items;
  List<CartItem> get cartList => _items;

  // Required by main_layout.dart, cart_screen.dart, and checkout_screen.dart
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalItemCount;

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  // Helper to extract numeric ID from any input
  int _extractId(dynamic prod) {
    if (prod == null) return 0;
    if (prod is num) return prod.toInt();
    if (prod is String) return int.tryParse(prod) ?? 0;
    if (prod is Map) {
      return int.tryParse((prod['id'] ?? prod['product_id'] ?? 0).toString()) ?? 0;
    }
    try {
      return int.tryParse(prod.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // Handles both addItem(product) and addItem(product, quantity: n)
  void addItem(dynamic product, {int quantity = 1}) {
    final int prodId = _extractId(product);
    if (prodId == 0) return;

    final existingIndex = _items.indexWhere((item) => item.id == prodId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  // Alias for addToCart
  void addToCart(dynamic product, {int quantity = 1}) {
    addItem(product, quantity: quantity);
  }

  // Required by cart_screen.dart: cart.increaseQuantity(product.id)
  void increaseQuantity(dynamic productId) {
    final int id = _extractId(productId);
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  // Required by cart_screen.dart: cart.decreaseQuantity(product.id)
  void decreaseQuantity(dynamic productId) {
    final int id = _extractId(productId);
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeSingleItem(dynamic productId) {
    decreaseQuantity(productId);
  }

  void removeItem(dynamic productId) {
    final int id = _extractId(productId);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}