import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Dio _dio = Dio();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = context.read<UserProvider>().currentUser;
    final userId = user?.id ?? 1;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/v1/notifications?user_id=$userId');
      if (response.statusCode == 200) {
        setState(() {
          _notifications = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load notifications from server.';
        _isLoading = false;
      });
    }
  }

  IconData _getNotificationIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('ship') || t.contains('dispatch') || t.contains('way')) {
      return Icons.local_shipping_rounded;
    }
    if (t.contains('deliver') || t.contains('complete')) {
      return Icons.check_circle_rounded;
    }
    if (t.contains('cancel')) {
      return Icons.cancel_rounded;
    }
    if (t.contains('deal') || t.contains('offer') || t.contains('promo')) {
      return Icons.local_offer_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  Color _getIconColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('deliver')) return const Color(0xFF22C55E);
    if (t.contains('ship') || t.contains('dispatch')) return const Color(0xFF38BDF8);
    if (t.contains('cancel')) return const Color(0xFFEF4444);
    if (t.contains('deal') || t.contains('offer')) return const Color(0xFFF59E0B);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: _fetchNotifications,
            tooltip: 'Refresh Notifications',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 70, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          Text(
                            'No notifications yet',
                            style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Order process updates and announcements will appear here.',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF38BDF8),
                      backgroundColor: cardBg,
                      onRefresh: _fetchNotifications,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final String title = item['title']?.toString() ?? 'Notification';
                          final String message = item['message']?.toString() ?? '';
                          final String time = item['created_at']?.toString() ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getIconColor(title).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(title),
                                    color: _getIconColor(title),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        message,
                                        style: TextStyle(
                                          color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                      if (time.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}