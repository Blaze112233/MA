// At the top of your product card file:
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/user_provider.dart';

// Inside your ProductCard's build method:
Widget build(BuildContext context) {
  final user = context.watch<UserProvider>().currentUser;
  final userId = user?.id ?? 1;

  final wishlistProvider = context.watch<WishlistProvider>();
  final int productId = int.tryParse((product['id'] ?? product['product_id']).toString()) ?? 0;
  final bool isFav = wishlistProvider.isFavorite(productId);

  return Stack(
    children: [
      // Your existing card UI / image / text goes here ...

      // --- HEART (FAVORITE) BUTTON ---
      Positioned(
        top: 8,
        right: 8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<WishlistProvider>().toggleFavorite(userId, product);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? const Color(0xFFEF4444) : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ],
  );
}