import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/hive_service.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/favorites/favorites_controller.dart';
import '../../modules/order_history/order_history_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _emailErr = '', _passErr = '', _generalErr = '';
  bool _passVisible = false;
  bool _isLoading = false;
  bool _isRestoring = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    setState(() {
      _emailErr = '';
      _passErr = '';
      _generalErr = '';
    });
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _emailErr = 'Email is required');
      ok = false;
    } else if (!RegExp(
      r'^[\w.-]+@[\w.-]+\.\w+$',
    ).hasMatch(_emailCtrl.text.trim())) {
      setState(() => _emailErr = 'Enter a valid email');
      ok = false;
    }
    if (_passCtrl.text.isEmpty) {
      setState(() => _passErr = 'Password is required');
      ok = false;
    } else if (_passCtrl.text.length < 6) {
      setState(() => _passErr = 'Minimum 6 characters');
      ok = false;
    }
    return ok;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);

    final err = await FirebaseService.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;

    if (err != null) {
      setState(() {
        _isLoading = false;
        _generalErr = err;
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await FirebaseService.signOut();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalErr =
            'Email not verified. Please check your inbox and verify before signing in.';
      });
      return;
    }

    final uid = user?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _generalErr = 'Something went wrong. Please try again.';
      });
      return;
    }

    // Open uid-specific Hive boxes for this user
    await HiveService.openUserBoxes(uid);

    // Reload controllers with this user's boxes
    Get.find<CartController>().reloadForUser(uid);
    Get.find<FavoritesController>().reloadForUser(uid);

    await FirebaseService.syncEmail(uid, _emailCtrl.text.trim());

    if (HiveService.isHiveEmpty()) {
      setState(() => _isRestoring = true);
      try {
        final data = await FirebaseService.fetchUserProfile(uid);
        if (data != null) await HiveService.restoreFromMap(data);
      } catch (_) {}
    } else {
      await HiveService.saveProfile(
        name: HiveService.name,
        email: _emailCtrl.text.trim(),
        avatarPath: HiveService.avatarPath,
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isRestoring = false;
    });

    await Get.find<OrderHistoryController>().loadOrders();

    if (HiveService.isProfileSetup) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.setupProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to ShopX',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Email'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _emailCtrl,
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        error: _emailErr,
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      const SizedBox(height: 8),
                      _passField(),
                      if (_generalErr.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _errorBox(_generalErr),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                      if (_isRestoring) ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Restoring your data...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.offAllNamed(AppRoutes.signup),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: AppColors.textSecondary,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String error = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error.isNotEmpty ? AppColors.error : AppColors.divider,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _passField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _passErr.isNotEmpty ? AppColors.error : AppColors.divider,
            ),
          ),
          child: TextField(
            controller: _passCtrl,
            obscureText: !_passVisible,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textLight,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (_passErr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text(
              _passErr,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            msg,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
