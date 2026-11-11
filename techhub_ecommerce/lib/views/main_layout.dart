import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: primaryColor.withOpacity(0.18),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: _currentIndex,
          backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.white,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_outline_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.totalItemCount > 0,
                label: Text('${cart.totalItemCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cart.totalItemCount > 0,
                label: Text('${cart.totalItemCount}'),
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}