import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({Key? key}) : super(key: key);

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2128) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.storefront_outlined, Icons.storefront_rounded, 'Store'),
            _buildNavItem(1, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Wishlist'),
            _buildNavItem(2, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart'),
            _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 21,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}