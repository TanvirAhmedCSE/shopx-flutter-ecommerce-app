import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/services/firebase_service.dart';

enum _SignUpState { form, waitingVerification, verified }

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _emailErr = '', _passErr = '', _confirmErr = '', _generalErr = '';
  bool _passVisible = false, _confirmVisible = false;
  int _passStrength = 0;
  String _strengthLabel = '';
  _SignUpState _state = _SignUpState.form;
  bool _signing = false;
  Timer? _verifyTimer;

  @override
  void dispose() {
    _verifyTimer?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int _calcStrength(String p) {
    int s = 0;
    if (p.length >= 6) s++;
    if (p.length >= 10) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s++;
    return s;
  }

  void _onPasswordChanged(String value) {
    final s = value.isEmpty ? 0 : _calcStrength(value);
    String label = '';
    if (value.isNotEmpty) {
      if (s <= 1)
        label = 'Weak — add uppercase, numbers & symbols';
      else if (s == 2)
        label = 'Fair — getting better!';
      else if (s == 3)
        label = 'Good — almost there!';
      else
        label = 'Strong password!';
    }
    setState(() {
      _passStrength = s;
      _strengthLabel = label;
    });
  }

  Color _barColor(int i) {
    if (_passStrength == 0) return AppColors.divider;
    if (_passStrength <= 1) return i == 0 ? AppColors.error : AppColors.divider;
    if (_passStrength == 2) return i <= 1 ? AppColors.star : AppColors.divider;
    if (_passStrength == 3)
      return i <= 2 ? AppColors.success : AppColors.divider;
    return AppColors.success;
  }

  bool _validate() {
    bool ok = true;
    setState(() {
      _emailErr = '';
      _passErr = '';
      _confirmErr = '';
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
    if (_confirmCtrl.text != _passCtrl.text) {
      setState(() => _confirmErr = 'Passwords do not match');
      ok = false;
    }
    return ok;
  }

  Future<void> _signUp() async {
    if (!_validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _signing = true;
      _generalErr = '';
    });

    final err = await FirebaseService.signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;

    if (err != null) {
      setState(() {
        _signing = false;
        _generalErr = err;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _signing = false;
      _state = _SignUpState.waitingVerification;
    });
    _startPolling();
  }

  void _startPolling() {
    _verifyTimer?.cancel();
    _verifyTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final verified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        if (verified && mounted) {
          _verifyTimer?.cancel();
          setState(() => _state = _SignUpState.verified);
          await Future.delayed(const Duration(milliseconds: 1600));
          if (!mounted) return;
          Get.offAllNamed(AppRoutes.setupProfile);
        }
      } catch (_) {}
    });
  }

  Future<void> _resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      Get.snackbar(
        'Email Sent',
        'Verification email resent!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not resend. Try again shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
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
                // Logo
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

                if (_state == _SignUpState.form) ...[
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join ShopX and start shopping',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildForm(),
                  const SizedBox(height: 28),
                  RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.offAllNamed(AppRoutes.login),
                        ),
                      ],
                    ),
                  ),
                ] else if (_state == _SignUpState.waitingVerification) ...[
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _emailCtrl.text.trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildWaitingCard(),
                ] else ...[
                  const Text(
                    "You're all set!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildSuccessCard(),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
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
          _passFieldWidget(
            controller: _passCtrl,
            visible: _passVisible,
            onToggle: () => setState(() => _passVisible = !_passVisible),
            onChange: _onPasswordChanged,
            error: _passErr,
          ),
          if (_passCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: _barColor(i),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _strengthLabel,
              style: TextStyle(
                fontSize: 11,
                color: _passStrength <= 1
                    ? AppColors.error
                    : _passStrength <= 2
                    ? AppColors.star
                    : AppColors.success,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _label('Confirm Password'),
          const SizedBox(height: 8),
          _passFieldWidget(
            controller: _confirmCtrl,
            visible: _confirmVisible,
            onToggle: () => setState(() => _confirmVisible = !_confirmVisible),
            error: _confirmErr,
          ),
          if (_generalErr.isNotEmpty) ...[
            const SizedBox(height: 14),
            _errorBox(_generalErr),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _signing ? null : _signUp,
              child: _signing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Waiting for verification',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Check your email and click the verification link. This screen updates automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _resendEmail,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Resend email',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Successfully signed up!',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Email verified. Setting up your profile…',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppColors.success,
              strokeWidth: 2.5,
            ),
          ),
        ],
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

  Widget _passFieldWidget({
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
    String error = '',
    void Function(String)? onChange,
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
            obscureText: !visible,
            onChanged: onChange,
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
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
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
