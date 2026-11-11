import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About TechHub')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.storefront_rounded, size: 68, color: Colors.blueAccent),
            const SizedBox(height: 12),
            const Text('TechHub E-Commerce', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Version 1.0.0 (Release Build)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            const Text(
              'TechHub is a full-stack e-commerce platform built using Flutter and Python Flask with MySQL. Designed to deliver high-performance retail tech shopping across modern web and mobile ecosystems.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}