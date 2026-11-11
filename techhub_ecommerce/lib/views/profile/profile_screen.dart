import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../orders/order_history_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _handleSignOut(BuildContext context) {
    context.read<UserProvider>().logout();

    // Direct navigation to LoginScreen removes all route name dependency errors
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 1. TOP TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textColor),
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. USER AVATAR & NAME
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E3A8A),
                ),
                child: const Icon(Icons.person_rounded, size: 44, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 10),
              Text(
                user?.name ?? 'Luna',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 3),
              Text(
                user?.email ?? 'luna123@gmail.com',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
              const SizedBox(height: 20),

              // 3. CONTACT CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: textMuted),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone', style: TextStyle(fontSize: 11, color: textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              user?.phone ?? '093318228',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: borderColor, height: 22),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Address', style: TextStyle(fontSize: 11, color: textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                user?.address ?? 'Takhmao, kandal province',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. NAVIGATION MENU WITH THEME TOGGLE
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'Order History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                        );
                      },
                    ),
                    _buildDivider(borderColor),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFF43F5E),
                      title: 'Wishlist & Favorites',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WishlistScreen()),
                        );
                      },
                    ),
                    _buildDivider(borderColor),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    _buildDivider(borderColor),

                    // Theme toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B)).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  isDark ? 'Dark theme enabled' : 'Light theme enabled',
                                  style: TextStyle(fontSize: 11, color: textMuted),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeColor: const Color(0xFF38BDF8),
                            onChanged: (val) {
                              context.read<ThemeProvider>().toggleTheme(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(borderColor),

                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'About TechHub',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuItem(
                      context,
                      icon: Icons.headset_mic_rounded,
                      iconColor: const Color(0xFFA855F7),
                      title: 'Contact Support',
                      onTap: () => _showContactDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. SIGN OUT BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleSignOut(context),
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(color: borderColor, height: 1, indent: 54, endIndent: 16);
  }

  void _showEditProfileDialog(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;
    final userId = user?.id ?? 1;

    final nameController = TextEditingController(text: user?.name ?? 'Luna');
    final phoneController = TextEditingController(text: user?.phone ?? '093318228');
    final addressController = TextEditingController(text: user?.address ?? 'Takhmao, kandal province');

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setStateDialog(() => isSaving = true);
                          final newName = nameController.text.trim();
                          final newPhone = phoneController.text.trim();
                          final newAddress = addressController.text.trim();

                          try {
                            final dio = Dio();
                            final res = await dio.post(
                              'http://127.0.0.1:5000/api/v1/users/$userId',
                              data: {
                                'name': newName,
                                'phone': newPhone,
                                'address': newAddress,
                              },
                            );

                            final updatedUserMap = res.data['user'] ?? {
                              'id': userId,
                              'name': newName,
                              'email': user?.email ?? 'luna123@gmail.com',
                              'phone': newPhone,
                              'address': newAddress,
                            };

                            final currentToken = (userProvider as dynamic).token ?? '';
                            try {
                              userProvider.setUser(updatedUserMap, currentToken);
                            } catch (_) {
                              try {
                                (userProvider as dynamic).setUser(updatedUserMap, '');
                              } catch (_) {
                                (userProvider as dynamic).setUser(updatedUserMap);
                              }
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully!')),
                              );
                            }
                          } catch (e) {
                            setStateDialog(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About TechHub'),
        content: const Text('TechHub Store 2.0\nBuilt with Flutter, Python Flask, and MySQL.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Support'),
        content: const Text('Customer Care: support@techhub.com\nHotline: 093 318 228'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}