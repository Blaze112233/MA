import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true; // true = Sign In, false = Register
  final _dio = Dio();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final res = await _dio.post(
          'http://127.0.0.1:5000/api/v1/auth/login',
          data: {'email': email, 'password': password},
        );

        if (res.statusCode == 200) {
          final userData = res.data['user'];
          final token = res.data['token']?.toString() ?? '';

          // Passes both required positional arguments: (userData, token)
          context.read<UserProvider>().setUser(userData, token);
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();

        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your full name')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final res = await _dio.post(
          'http://127.0.0.1:5000/api/v1/auth/register',
          data: {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
          },
        );

        if (res.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please sign in.')),
          );
          setState(() => _isLogin = true);
        }
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Authentication failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Safely below the notch)
              const SizedBox(height: 12),
              Text(
                'TechHub Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 24),

              // 2. SEGMENTED TABS WITH HIGH-CONTRAST LABELS
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isLogin ? const Color(0xFF2563EB) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isLogin ? Colors.white : textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: !_isLogin ? const Color(0xFF2563EB) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !_isLogin ? Colors.white : textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 3. LOGO ICON
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 38,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. FORM FIELDS
              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                  hintText: 'Full Name',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                ),
                const SizedBox(height: 16),
              ],

              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                cardColor: cardColor,
                borderColor: borderColor,
                textColor: textColor,
                textMuted: textMuted,
              ),
              const SizedBox(height: 16),

              if (!_isLogin) ...[
                _buildTextField(
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                ),
                const SizedBox(height: 16),
              ],

              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                hintText: 'Password',
                obscureText: _obscurePassword,
                cardColor: cardColor,
                borderColor: borderColor,
                textColor: textColor,
                textMuted: textMuted,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 28),

              // 5. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. BOTTOM SWITCH LINK
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Sign In",
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: textMuted, size: 20),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}