import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../data/models/order_model.dart';
import '../cart/cart_controller.dart';
import '../order_history/order_history_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int _step = 0; // 0: shipping, 1: payment, 2: success
  final _shippingKey = GlobalKey<FormState>();
  final _paymentKey = GlobalKey<FormState>();

  // Shipping fields
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  // Payment fields
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  int _selectedShipping = 0;
  bool _isPlacing = false;

  final _shippingOptions = [
    {'label': 'Standard Delivery', 'time': '5-7 business days', 'price': 0.0},
    {'label': 'Express Delivery', 'time': '2-3 business days', 'price': 5.99},
    {'label': 'Next Day Delivery', 'time': '1 business day', 'price': 12.99},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    if (_step == 2) return _buildSuccess(cart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: BackButton(
          onPressed: () {
            if (_step == 0) {
              Get.back();
            } else {
              setState(() => _step--);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildStepIndicator(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _step == 0
                  ? _buildShippingForm()
                  : _buildPaymentForm(cart),
            ),
          ),
          _buildBottomBar(cart),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          _stepDot(0, 'Shipping'),
          Expanded(
            child: Container(
              height: 2,
              color: _step >= 1 ? AppColors.primary : AppColors.divider,
            ),
          ),
          _stepDot(1, 'Payment'),
        ],
      ),
    );
  }

  Widget _stepDot(int index, String label) {
    final active = _step >= index;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: active && _step > index
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.primary : AppColors.textLight,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingForm() {
    return Form(
      key: _shippingKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Delivery Address'),
          const SizedBox(height: 16),
          _field(
            controller: _nameCtrl,
            label: 'Full Name',
            icon: Iconsax.user,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _addressCtrl,
            label: 'Street Address',
            icon: Iconsax.location,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  controller: _cityCtrl,
                  label: 'City',
                  icon: Iconsax.building,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  controller: _zipCtrl,
                  label: 'ZIP',
                  icon: Iconsax.map,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Shipping Method'),
          const SizedBox(height: 12),
          ...List.generate(_shippingOptions.length, (i) {
            final opt = _shippingOptions[i];
            final selected = _selectedShipping == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedShipping = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textLight,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            opt['time'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      (opt['price'] as double) == 0
                          ? 'FREE'
                          : '\$${(opt['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: (opt['price'] as double) == 0
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(CartController cart) {
    final shippingPrice =
        _shippingOptions[_selectedShipping]['price'] as double;
    final total = cart.totalPrice + shippingPrice;

    return Form(
      key: _paymentKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment Details'),
          const SizedBox(height: 16),
          _field(
            controller: _cardCtrl,
            label: 'Card Number',
            icon: Iconsax.card,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) =>
                v!.replaceAll(' ', '').length < 16 ? 'Invalid card' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: _expiryCtrl,
                  label: 'MM / YY',
                  icon: Iconsax.calendar,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  validator: (v) => v!.length < 5 ? 'Invalid' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  controller: _cvvCtrl,
                  label: 'CVV',
                  icon: Iconsax.lock,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  obscureText: true,
                  validator: (v) => v!.length < 3 ? 'Invalid' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Order Summary'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                ...cart.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '×${item.quantity}  \$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.divider),
                _summaryRow(
                  'Subtotal',
                  '\$${cart.totalPrice.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 6),
                _summaryRow(
                  'Shipping',
                  shippingPrice == 0
                      ? 'FREE'
                      : '\$${shippingPrice.toStringAsFixed(2)}',
                  valueColor: shippingPrice == 0 ? AppColors.success : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(CartController cart) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_circle,
                    size: 52,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your order has been placed successfully.\nYou will receive a confirmation shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cart.clearCart();
                      Get.offAllNamed('/');
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartController cart) {
    final shippingPrice =
        _shippingOptions[_selectedShipping]['price'] as double;
    final total = cart.totalPrice + shippingPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _step == 0 ? 'Subtotal' : 'Total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isPlacing ? null : _handleNext,
                icon: _isPlacing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _step == 0 ? Iconsax.arrow_right_3 : Iconsax.lock,
                        size: 18,
                      ),
                label: Text(_step == 0 ? 'Continue' : 'Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_step == 0) {
      if (_shippingKey.currentState!.validate()) {
        setState(() => _step = 1);
      }
    } else {
      if (_paymentKey.currentState!.validate()) {
        _placeOrder();
      }
    }
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacing = true);
    final cart = Get.find<CartController>();
    final shippingOpt = _shippingOptions[_selectedShipping];
    final shippingPrice = shippingOpt['price'] as double;

    // Build order
    final order = OrderModel(
      orderId: const Uuid().v4(),
      items: cart.cartItems
          .map(
            (c) => OrderItem(
              title: c.title,
              price: c.price,
              quantity: c.quantity,
              image: c.image,
            ),
          )
          .toList(),
      subtotal: cart.totalPrice,
      shippingCost: shippingPrice,
      total: cart.totalPrice + shippingPrice,
      shippingLabel: shippingOpt['label'] as String,
      shippingTime: shippingOpt['time'] as String,
      fullName: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      zip: _zipCtrl.text.trim(),
      placedAt: DateTime.now(),
    );

    // Save order
    await Get.find<OrderHistoryController>().addOrder(order);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _step = 2);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
  );

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
