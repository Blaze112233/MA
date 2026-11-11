import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../main_layout.dart';

class AuthScreen extends StatefulWidget {
  final bool isInitialGate;
  const AuthScreen({Key? key, this.isInitialGate = false}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Dio _dio = Dio();
  final String _baseUrl = ApiConstants.authUrl;

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  void _onSuccessRedirect() {
    if (widget.isInitialGate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('$_baseUrl/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200) {
        final userData = UserModel.fromJson(res.data['user']);
        final token = res.data['token'];
        if (!mounted) return;
        context.read<UserProvider>().setUser(userData, token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome back, ${userData.name}!')),
        );
        _onSuccessRedirect();
      }
    } on DioException catch (dioErr) {
      String msg = 'Cannot connect to backend server. Ensure Flask is running.';
      if (dioErr.response?.statusCode == 401) {
        msg = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRegister() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final password = _regPasswordCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, email, and password required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('$_baseUrl/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please sign in.')),
        );
        _tabController.animateTo(0);
        _loginEmailCtrl.text = email;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Email may already exist.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechHub Account', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: !widget.isInitialGate,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          tabs: const [
            Tab(text: 'Sign In'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sign In Form
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt_rounded, size: 48, color: primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _loginEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),

          // Registration Form
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _regNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _regEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _regPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _regPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}