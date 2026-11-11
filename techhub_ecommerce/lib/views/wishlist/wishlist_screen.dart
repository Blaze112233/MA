import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<WishlistProvider>().fetchWishlist(userId);
    });
  }

  // Safe helper methods to read from either a Map or an Object
  int _getId(dynamic item) {
    if (item is Map) {
      return int.tryParse((item['id'] ?? item['product_id']).toString()) ?? 0;
    }
    try {
      return int.tryParse(item.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _getName(dynamic item) {
    if (item is Map) return item['name']?.toString() ?? 'Device';
    try {
      return item.name?.toString() ?? 'Device';
    } catch (_) {
      return 'Device';
    }
  }

  String _getBrand(dynamic item) {
    if (item is Map) return item['brand']?.toString() ?? '';
    try {
      return item.brand?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  double _getPrice(dynamic item) {
    if (item is Map) {
      return double.tryParse((item['price'] ?? 0.0).toString()) ?? 0.0;
    }
    try {
      return double.tryParse((item.price ?? 0.0).toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  String _getImageUrl(dynamic item) {
    if (item is Map) {
      return item['image_url']?.toString() ?? item['imageUrl']?.toString() ?? '';
    }
    try {
      return item.imageUrl?.toString() ?? item.image_url?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = context.watch<UserProvider>().currentUser;
    final userId = user?.id ?? 1;

    final wishlist = context.watch<WishlistProvider>();

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
          'My Wishlist',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: wishlist.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            )
          : wishlist.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 72,
                        color: textMuted.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any device to save it here.',
                        style: TextStyle(fontSize: 14, color: textMuted),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => wishlist.fetchWishlist(userId),
                  color: const Color(0xFF2563EB),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: wishlist.items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = wishlist.items[index];
                      final int prodId = _getId(item);
                      final String name = _getName(item);
                      final String brand = _getBrand(item);
                      final double price = _getPrice(item);
                      final String imageUrl = _getImageUrl(item);

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: item),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and Heart button
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(19),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: imageBg,
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Center(
                                                  child: Icon(
                                                    Icons.devices,
                                                    size: 42,
                                                    color: textMuted,
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.devices,
                                                  size: 42,
                                                  color: textMuted,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Remove from wishlist (heart button)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            wishlist.toggleFavorite(
                                              userId: userId,
                                              productId: prodId,
                                              product: item,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.black.withOpacity(0.5)
                                                  : Colors.white.withOpacity(0.85),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Color(0xFFEF4444),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Text and Add-to-cart
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (brand.isNotEmpty)
                                      Text(
                                        brand.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: textMuted,
                                          letterSpacing: 0.4,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 3),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            context
                                                .read<CartProvider>()
                                                .addItem(item);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('$name added to cart!'),
                                                duration:
                                                    const Duration(seconds: 1),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}