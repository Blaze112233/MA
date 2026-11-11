import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../orders/order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Dio _dio = Dio();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _paymentMethod = 'ABA PayWay (KHQR)';
  final double _deliveryFee = 2.00;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name ?? '';
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int _getProductId(dynamic product) {
    if (product is Map) {
      return int.tryParse((product['id'] ?? product['product_id'] ?? 0).toString()) ?? 0;
    }
    try {
      return int.tryParse(product.id.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _getProductName(dynamic product) {
    if (product is Map) return product['name']?.toString() ?? 'Device';
    try {
      return product.name?.toString() ?? 'Device';
    } catch (_) {
      return 'Device';
    }
  }

  double _getProductPrice(dynamic product) {
    if (product is Map) {
      return double.tryParse((product['price'] ?? 0.0).toString()) ?? 0.0;
    }
    try {
      return double.tryParse(product.price.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  String _getProductImage(dynamic product) {
    if (product is Map) {
      return product['image_url']?.toString() ?? product['imageUrl']?.toString() ?? '';
    }
    try {
      return product.imageUrl?.toString() ?? product.image_url?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  // Handles checkout button press
  void _handleCheckout() {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    final double totalAmount = cart.totalAmount + _deliveryFee;

    // If ABA KHQR selected -> Show QR Code Dialog first
    if (_paymentMethod == 'ABA PayWay (KHQR)') {
      _showAbaQrDialog(totalAmount);
    } else {
      // Cash on delivery -> Place order directly
      _submitOrderToBackend();
    }
  }

  // ==================== ABA KHQR DIALOG ====================
  void _showAbaQrDialog(double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top KHQR Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48), // KHQR Red
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'KHQR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Merchant / Store info
                const Text(
                  'TechHub Store (Cambodia)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan to pay with ABA Mobile or any Bakong App',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Simulated Dynamic KHQR QR Code Graphic
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // High-contrast clean QR visual
                      Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=bakong_techhub_usd_${totalAmount.toStringAsFixed(2)}',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.qr_code_2_rounded, size: 140, color: Color(0xFF0F172A)),
                        ),
                      ),
                      // Small ABA Logo Badge in center of QR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003865), // ABA Navy
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ABA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Display
                Text(
                  'Amount Due',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF003865),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003865), // ABA Brand color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx); // Close QR dialog
                          _submitOrderToBackend(); // Submit order
                        },
                        child: const Text(
                          'I Have Paid',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== SUBMIT ORDER TO BACKEND ====================
  Future<void> _submitOrderToBackend() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    setState(() => _isSubmitting = true);

    final user = context.read<UserProvider>().currentUser;
    final int? userId = user?.id;

    final itemsPayload = cart.items.map((item) {
      final prodId = _getProductId(item.product);
      final price = _getProductPrice(item.product);
      return {
        'product_id': prodId,
        'quantity': item.quantity,
        'price': price,
      };
    }).toList();

    final double totalAmount = cart.totalAmount + _deliveryFee;

    final payload = {
      'user_id': userId,
      'customer_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'payment_method': _paymentMethod,
      'amount': totalAmount,
      'delivery_fee': _deliveryFee,
      'items': itemsPayload,
    };

    try {
      final response = await _dio.post(
        'http://127.0.0.1:5000/api/v1/orders/checkout',
        data: payload,
      );

      if (response.statusCode == 200) {
        cart.clearCart();

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 28),
                SizedBox(width: 10),
                Text('Order Confirmed!'),
              ],
            ),
            content: Text(
              'Thank you, ${_nameController.text.trim()}! Your order of \$${totalAmount.toStringAsFixed(2)} has been recorded successfully.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
                child: const Text('View Order History'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${response.data['message']}')),
        );
      }
    } catch (e) {
      debugPrint('[Checkout Error]: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cart = context.watch<CartProvider>();

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    final double subtotal = cart.totalAmount;
    final double grandTotal = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== DELIVERY DETAILS ====================
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Recipient Name',
                        labelStyle: TextStyle(color: textMuted),
                        prefixIcon: Icon(Icons.person_outline, color: textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      style: TextStyle(color: textPrimary),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: textMuted),
                        prefixIcon: Icon(Icons.phone_outlined, color: textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      style: TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        labelStyle: TextStyle(color: textMuted),
                        prefixIcon: Icon(Icons.location_on_outlined, color: textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter address' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== PAYMENT METHOD ====================
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003865),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ABA',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ABA PayWay (KHQR)',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      subtitle: Text('Scan to pay via Bakong / ABA app', style: TextStyle(color: textMuted, fontSize: 12)),
                      value: 'ABA PayWay (KHQR)',
                      groupValue: _paymentMethod,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    Divider(color: borderColor, height: 1),
                    RadioListTile<String>(
                      title: Text(
                        'Cash on Delivery',
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Pay cash upon receiving items', style: TextStyle(color: textMuted, fontSize: 12)),
                      value: 'Cash on Delivery',
                      groupValue: _paymentMethod,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== ORDER ITEMS REVIEW ====================
              Text(
                'Order Summary (${cart.totalItemCount} items)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    ...cart.items.map((item) {
                      final product = item.product;
                      final String name = _getProductName(product);
                      final double price = _getProductPrice(product);
                      final String img = _getProductImage(product);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                child: img.isNotEmpty
                                    ? Image.network(img, fit: BoxFit.contain)
                                    : Icon(Icons.devices, color: textMuted),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '\$${price.toStringAsFixed(2)} × ${item.quantity}',
                                    style: TextStyle(color: textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    Divider(color: borderColor, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(color: textMuted)),
                        Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee', style: TextStyle(color: textMuted)),
                        Text('\$${_deliveryFee.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Divider(color: borderColor, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '\$${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ==================== CHECKOUT BUTTON ====================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _handleCheckout,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _paymentMethod == 'ABA PayWay (KHQR)'
                              ? 'PAY WITH ABA KHQR • \$${grandTotal.toStringAsFixed(2)}'
                              : 'CONFIRM CASH ORDER • \$${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}