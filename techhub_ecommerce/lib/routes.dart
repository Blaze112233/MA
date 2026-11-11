import 'package:flutter/material.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/auth_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/main_layout.dart';
import 'views/home/home_screen.dart';
import 'views/cart/cart_screen.dart';
import 'views/checkout/checkout_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/orders/order_history_screen.dart';
import 'views/wishlist/wishlist_screen.dart';
import 'views/settings/settings_screen.dart';
import 'views/info/about_screen.dart';
import 'views/info/contact_screen.dart';
import 'views/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String orderHistory = '/order-history';
  static const String wishlist = '/wishlist';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        auth: (context) => const AuthScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        main: (context) => const MainLayout(),
        home: (context) => const HomeScreen(),
        cart: (context) => const CartScreen(),
        checkout: (context) => const CheckoutScreen(),
        profile: (context) => const ProfileScreen(),
        orderHistory: (context) => const OrderHistoryScreen(),
        wishlist: (context) => const WishlistScreen(),
        settings: (context) => const SettingsScreen(),
        about: (context) => const AboutScreen(),
        contact: (context) => const ContactScreen(),
        notifications: (context) => const NotificationsScreen(),
      };
}