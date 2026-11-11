import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _topWeeklySearches = [];
  final List<String> _searchHistory = [];
  List<Product> _searchResults = [];

  bool _hasSearched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyTrends();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadWeeklyTrends() async {
    final top = await _apiService.fetchTopWeeklySearches();
    if (!mounted) return;
    setState(() {
      _topWeeklySearches = top;
    });
  }

  void _onSearchSubmitted(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _focusNode.unfocus();

    setState(() {
      _searchHistory.remove(clean);
      _searchHistory.insert(0, clean);
      if (_searchHistory.length > 10) _searchHistory.removeLast();
      _searchController.text = clean;
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await _apiService.fetchProducts(search: clean);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults = [];
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF22262E) : const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search Taobao gadgets...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => _onSearchSubmitted(_searchController.text),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: _hasSearched ? _buildSearchResults(isDark, primaryColor) : _buildHistoryAndTrends(isDark, primaryColor),
    );
  }

  Widget _buildHistoryAndTrends(bool isDark, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                onPressed: () => setState(() => _searchHistory.clear()),
                tooltip: 'Clear history',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory.map((query) {
              return InputChip(
                label: Text(query, style: const TextStyle(fontSize: 12)),
                backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.grey.shade100,
                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                onPressed: () => _onSearchSubmitted(query),
                onDeleted: () {
                  setState(() => _searchHistory.remove(query));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        Row(
          children: const [
            Text('🔥', style: TextStyle(fontSize: 16)),
            SizedBox(width: 6),
            Text(
              'Trending This Week',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _topWeeklySearches.map((tag) {
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _onSearchSubmitted(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(color: primaryColor, fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark, Color primaryColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No gadgets found for "${_searchController.text}"',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181B20) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF22262E) : const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? Image.network(product.imageUrl!, fit: BoxFit.contain)
                          : const Icon(Icons.devices_rounded, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.brand.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primaryColor),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.read<CartProvider>().addItem(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_shopping_cart_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}