import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = Dio();
  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _selectedCategoryId = 0; // 0 represents "All"

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchCategories(),
      _fetchProducts(),
    ]);

    // Ensure wishlist is synced on load
    if (mounted) {
      final user = context.read<UserProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<WishlistProvider>().fetchWishlist(userId);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/v1/categories');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _categories = response.data;
        });
      }
    } catch (e) {
      debugPrint('[Fetch Categories Error]: $e');
    }
  }

  Future<void> _fetchProducts({int? categoryId}) async {
    try {
      final catId = categoryId ?? _selectedCategoryId;
      String url = 'http://127.0.0.1:5000/api/v1/products?category_id=$catId';

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _products = response.data;
        });
      }
    } catch (e) {
      debugPrint('[Fetch Products Error]: $e');
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = context.watch<UserProvider>().currentUser;
    final userId = user?.id ?? 1;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
    final imageBg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchInitialData,
          color: const Color(0xFF2563EB),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== TOP HEADER ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to TechHub',
                          style: TextStyle(
                            fontSize: 13,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore Devices',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFBBF24),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ==================== SEARCH BAR ====================
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _navigateToSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: textMuted, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search iPhone, Sony, MacBook...',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _navigateToSearch,
                          child: const Text(
                            'Find',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ==================== CATEGORIES CHIPS ====================
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip(
                        id: 0,
                        name: 'All',
                        isSelected: _selectedCategoryId == 0,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((cat) {
                        final int id = int.tryParse(cat['id'].toString()) ?? 0;
                        final String name = cat['name']?.toString() ?? 'Category';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            id: id,
                            name: name,
                            isSelected: _selectedCategoryId == id,
                            isDark: isDark,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ==================== SECTION TITLE ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId == 0
                          ? 'All'
                          : (_categories.firstWhere(
                              (c) => c['id'] == _selectedCategoryId,
                              orElse: () => {'name': 'Items'},
                            )['name']),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${_products.length} items',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ==================== PRODUCTS GRID ====================
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    ),
                  )
                else if (_products.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No devices found',
                            style: TextStyle(color: textMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final int prodId = int.tryParse(
                        (product['id'] ?? product['product_id']).toString(),
                      ) ?? 0;
                      final String name = product['name']?.toString() ?? 'Device';
                      final String brand = product['brand']?.toString() ?? '';
                      final double price = double.tryParse((product['price'] ?? 0.0).toString()) ?? 0.0;
                      final String imageUrl = product['image_url']?.toString() ?? '';

                      final isFav = context.watch<WishlistProvider>().isFavorite(prodId);

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
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
                              // ==================== PRODUCT IMAGE + HEART ====================
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: imageBg,
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => Center(
                                                  child: Icon(Icons.devices, size: 42, color: textMuted),
                                                ),
                                              )
                                            : Center(
                                                child: Icon(Icons.devices, size: 42, color: textMuted),
                                              ),
                                      ),
                                    ),

                                    // --- FAVORITE (HEART) BUTTON ---
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            context.read<WishlistProvider>().toggleFavorite(
                                                  userId: userId,
                                                  productId: prodId,
                                                  product: product,
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
                                            child: Icon(
                                              isFav ? Icons.favorite : Icons.favorite_border,
                                              color: isFav ? const Color(0xFFEF4444) : textMuted,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ==================== TEXT & ADD TO CART ====================
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        // Dedicated Add-to-Cart Action Target
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            context.read<CartProvider>().addItem(product);

                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('$name added to cart!'),
                                                backgroundColor: const Color(0xFF2563EB),
                                                duration: const Duration(seconds: 1),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB),
                                              borderRadius: BorderRadius.circular(10),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required int id,
    required String name,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
        });
        _fetchProducts(categoryId: id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }
}