import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  // Safe helper extractors for Map or Object
  int _getProductId(dynamic product) {
    if (product is Map) {
      return int.tryParse((product['id'] ?? product['product_id'] ?? 0).toString()) ?? 0;
    }
    try {
      return int.tryParse(product.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _getProductName(dynamic product) {
    if (product is Map) return product['name']?.toString() ?? 'Device';
    try {
      return product.name?.toString() ?? 'Device';
    } catch (_) {
      return 'Device';
    }
  }

  String _getProductBrand(dynamic product) {
    if (product is Map) return product['brand']?.toString() ?? '';
    try {
      return product.brand?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  double _getProductPrice(dynamic product) {
    if (product is Map) {
      return double.tryParse((product['price'] ?? 0.0).toString()) ?? 0.0;
    }
    try {
      return double.tryParse(product.price.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  String _getProductImage(dynamic product) {
    if (product is Map) {
      return product['image_url']?.toString() ?? product['imageUrl']?.toString() ?? '';
    }
    try {
      return product.imageUrl?.toString() ?? product.image_url?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cart = context.watch<CartProvider>();

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
    final imageBg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
              tooltip: 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cardBg,
                    title: Text('Clear Cart', style: TextStyle(color: textPrimary)),
                    content: Text(
                      'Are you sure you want to remove all items from your cart?',
                      style: TextStyle(color: textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore devices and add items to your cart.',
                    style: TextStyle(fontSize: 14, color: textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final product = item.product;

                final int prodId = _getProductId(product);
                final String name = _getProductName(product);
                final String brand = _getProductBrand(product);
                final double price = _getProductPrice(product);
                final String imageUrl = _getProductImage(product);
                final int quantity = item.quantity;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: imageBg,
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(Icons.devices, color: textMuted),
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.devices, color: textMuted),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (brand.isNotEmpty)
                              Text(
                                brand.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: textMuted,
                                ),
                              ),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Controls & Trash
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textMuted,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => cart.removeItem(prodId),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => cart.decreaseQuantity(prodId),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.remove, size: 14, color: textPrimary),
                                  ),
                                ),
                                Text(
                                  '$quantity',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => cart.increaseQuantity(prodId),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.add, size: 14, color: textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

      // Bottom Checkout Panel
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${cart.totalItemCount} items)',
                  style: TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                child: const Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}