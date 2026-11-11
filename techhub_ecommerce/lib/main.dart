import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const TechHubApp(),
    ),
  );
}

class TechHubApp extends StatelessWidget {
  const TechHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'TechHub Store',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // Listens to the toggle switch
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      builder: (context, child) {
        if (kIsWeb) {
          return Scaffold(
            backgroundColor: const Color(0xFF0B0F19),
            body: Center(
              child: Container(
                width: 412,
                height: 860,
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(color: const Color(0xFF2D3748), width: 10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 40,
                      spreadRadius: 8,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Stack(
                    children: [
                      child ?? const SizedBox(),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 110,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return child ?? const SizedBox();
      },
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}