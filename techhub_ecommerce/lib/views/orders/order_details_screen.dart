import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/theme_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final dynamic order;
  final int? orderId;

  const OrderDetailsScreen({Key? key, this.order, this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final Dio _dio = Dio();
  Map<String, dynamic>? _orderData;
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _errorMessage = '';

  int get effectiveOrderId {
    if (widget.orderId != null && widget.orderId! > 0) return widget.orderId!;
    if (widget.order is Map) {
      final rawId = widget.order['id'] ?? widget.order['order_id'];
      return int.tryParse(rawId.toString()) ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final id = effectiveOrderId;
    if (id == 0) {
      setState(() {
        _errorMessage = 'Invalid Order ID';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/v1/orders/$id');
      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _orderData = data;
          _items = (data['items'] as List<dynamic>?) ?? [];
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      if (widget.order is Map) {
        final data = Map<String, dynamic>.from(widget.order);
        setState(() {
          _orderData = data;
          _items = (data['items'] as List<dynamic>?) ?? [];
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _errorMessage = 'Failed to load details.';
        _isLoading = false;
      });
    }
  }

  int _getStageIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('cancel')) return -1;
    if (s.contains('deliver') || s.contains('complete')) return 2;
    if (s.contains('ship') || s.contains('way')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    final id = effectiveOrderId;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Order #$id Tracking',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _fetchOrder,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : _orderData == null
                  ? Center(child: Text('Order not found', style: TextStyle(color: textColor)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTrackingProgressBar(
                            status: _orderData!['status']?.toString() ?? 'Confirmed',
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Delivery Information',
                            icon: Icons.local_shipping_outlined,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            children: [
                              _buildRow('Customer Name', _orderData!['customer_name']?.toString() ?? 'Customer', textColor, textMuted),
                              _buildRow('Contact Phone', _orderData!['phone']?.toString() ?? 'N/A', textColor, textMuted),
                              _buildRow('Delivery Address', _orderData!['address']?.toString() ?? 'Phnom Penh', textColor, textMuted),
                              _buildRow('Payment Method', _orderData!['payment_method']?.toString() ?? 'ABA PayWay', textColor, textMuted),
                              _buildRow('Order Placed', _orderData!['created_at']?.toString() ?? 'Recently', textColor, textMuted),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ORDERED ITEMS CARD
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB), size: 20),
                                    const SizedBox(width: 8),
                                    Text('Ordered Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_items.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      'Order #$id Items (\$${(double.tryParse(_orderData!['total_amount']?.toString() ?? '0.0') ?? 0.0).toStringAsFixed(2)})',
                                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  )
                                else
                                  ..._items.map((item) {
                                    final name = item['product_name'] ?? item['name'] ?? 'Tech Product';
                                    final qty = item['quantity'] ?? item['qty'] ?? 1;
                                    final subtotal = double.tryParse((item['subtotal'] ?? item['unit_price'] ?? 0).toString()) ?? 0.0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${qty}x $name',
                                              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '\$${subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Payment Summary',
                            icon: Icons.receipt_long_outlined,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textColor: textColor,
                            children: [
                              _buildRow(
                                'Total Paid',
                                '\$${(double.tryParse(_orderData!['total_amount']?.toString() ?? '0.0') ?? 0.0).toStringAsFixed(2)}',
                                textColor,
                                textMuted,
                                isBold: true,
                                valueColor: const Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildTrackingProgressBar({
    required String status,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required bool isDark,
  }) {
    final stageIndex = _getStageIndex(status);
    final isCancelled = stageIndex == -1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.red.withOpacity(0.12)
                      : stageIndex == 2
                          ? Colors.green.withOpacity(0.12)
                          : const Color(0xFF2563EB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCancelled ? Colors.red : stageIndex == 2 ? Colors.green : const Color(0xFF2563EB),
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? Colors.redAccent : stageIndex == 2 ? Colors.green : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isCancelled)
            const Center(
              child: Text('This order was cancelled.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            )
          else
            Row(
              children: [
                _buildStep(title: 'Confirmed', icon: Icons.check_circle_outline, isActive: stageIndex >= 0, isDark: isDark),
                _buildStepLine(isActive: stageIndex >= 1, isDark: isDark),
                _buildStep(title: 'Shipping', icon: Icons.local_shipping_outlined, isActive: stageIndex >= 1, isDark: isDark),
                _buildStepLine(isActive: stageIndex >= 2, isDark: isDark),
                _buildStep(title: 'Delivered', icon: Icons.home_outlined, isActive: stageIndex >= 2, isDark: isDark),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStep({required String title, required IconData icon, required bool isActive, required bool isDark}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: isActive ? Colors.white : (isDark ? Colors.grey : const Color(0xFF64748B)), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isActive, required bool isDark}) {
    return Container(
      width: 36,
      height: 3,
      color: isActive ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      margin: const EdgeInsets.only(bottom: 24),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color textColor, Color textMuted, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}