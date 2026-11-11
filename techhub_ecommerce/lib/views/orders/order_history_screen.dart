import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final Dio _dio = Dio();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = context.read<UserProvider>().currentUser;
    final userId = user?.id ?? 1;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/v1/orders/user/$userId');
      if (response.statusCode == 200) {
        setState(() {
          _orders = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order history.';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('deliver') || s.contains('complete')) return const Color(0xFF22C55E);
    if (s.contains('ship')) return const Color(0xFF38BDF8);
    if (s.contains('cancel')) return const Color(0xFFEF4444);
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
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: _fetchOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 70, color: textMuted),
                          const SizedBox(height: 14),
                          Text(
                            'No orders found',
                            style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF2563EB),
                      backgroundColor: cardBg,
                      onRefresh: _fetchOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final int orderId = int.tryParse(order['id'].toString()) ?? 0;
                          final String status = order['status']?.toString() ?? 'Confirmed';
                          final String date = order['created_at']?.toString() ?? '';
                          final double total = double.tryParse(order['total_amount']?.toString() ?? '0.0') ?? 0.0;
                          final Color statusColor = _getStatusColor(status);

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(
                                    orderId: orderId,
                                    order: order,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order #$orderId',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    date,
                                    style: TextStyle(color: textMuted, fontSize: 12),
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(color: borderColor, height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Track Order',
                                            style: TextStyle(
                                              color: textMuted,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}