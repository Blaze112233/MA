import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../auth/auth_screen.dart';
import '../main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2-second branded splash transition
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final isLoggedIn = context.read<UserProvider>().isLoggedIn;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn
              ? const MainLayout()
              : const AuthScreen(isInitialGate: true),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt_rounded, size: 76, color: primary),
            ),
            const SizedBox(height: 22),
            const Text(
              'TechHub Store',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Next-Gen Smart Devices & Gadgets',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}