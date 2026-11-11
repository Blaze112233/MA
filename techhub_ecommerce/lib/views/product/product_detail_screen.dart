import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  // Safe attribute getters whether product is a Map or a Model Object
  int get productId {
    if (widget.product is Map) {
      return int.tryParse((widget.product['id'] ?? widget.product['product_id']).toString()) ?? 0;
    }
    try {
      return int.tryParse(widget.product.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String get name {
    if (widget.product is Map) return widget.product['name']?.toString() ?? 'Product';
    return widget.product.name?.toString() ?? 'Product';
  }

  String get brand {
    if (widget.product is Map) return widget.product['brand']?.toString() ?? '';
    return widget.product.brand?.toString() ?? '';
  }

  double get price {
    if (widget.product is Map) {
      return double.tryParse((widget.product['price'] ?? 0.0).toString()) ?? 0.0;
    }
    return double.tryParse((widget.product.price ?? 0.0).toString()) ?? 0.0;
  }

  int get stock {
    if (widget.product is Map) {
      return int.tryParse((widget.product['stock_quantity'] ?? 10).toString()) ?? 10;
    }
    return int.tryParse((widget.product.stockQuantity ?? 10).toString()) ?? 10;
  }

  String get description {
    if (widget.product is Map) {
      return widget.product['description']?.toString() ?? 'No technical specifications provided.';
    }
    return widget.product.description?.toString() ?? 'No technical specifications provided.';
  }

  String get imageUrl {
    if (widget.product is Map) return widget.product['image_url']?.toString() ?? '';
    return widget.product.imageUrl?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Providers
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = context.watch<UserProvider>().currentUser;
    final userId = user?.id ?? 1;

    final wishlistProvider = context.watch<WishlistProvider>();
    final bool isFav = wishlistProvider.isFavorite(productId);

    // 2. Dynamic Colors
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 17),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // ==================== HEART (FAVORITE) TOGGLE BUTTON ====================
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? const Color(0xFFEF4444) : textColor,
              size: 24,
            ),
            tooltip: isFav ? 'Remove from Wishlist' : 'Add to Wishlist',
            onPressed: () {
              context.read<WishlistProvider>().toggleFavorite(
                    userId: userId,
                    productId: productId,
                    product: widget.product,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? 'Removed from Wishlist' : 'Added to Wishlist ❤️',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== PRODUCT IMAGE ====================
            Container(
              width: double.infinity,
              height: 300,
              color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
              child: Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.devices_other_rounded,
                          size: 90,
                          color: textMuted,
                        ),
                      )
                    : Icon(
                        Icons.devices_other_rounded,
                        size: 90,
                        color: textMuted,
                      ),
              ),
            ),

            // ==================== PRODUCT DETAILS ====================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (brand.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            brand.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: stock > 0
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stock > 0 ? '$stock in stock' : 'Out of stock',
                          style: TextStyle(
                            color: stock > 0 ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 16),

                  Text(
                    'About this item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              color: textColor,
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Text(
                              '$_quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: textColor,
                              onPressed: _quantity < stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ==================== ADD TO CART BUTTON ====================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      label: Text(
                        'Add to Cart • \$${(price * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: stock > 0
                          ? () {
                              final cart = context.read<CartProvider>();
                              for (int i = 0; i < _quantity; i++) {
                                cart.addItem(widget.product);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$_quantity x $name added to cart!'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}