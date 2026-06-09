import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/hive_service.dart';
import '../../modules/order_history/order_history_controller.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/favorites/favorites_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final uid = user.uid;

    await HiveService.openUserBoxes(uid);

    if (HiveService.isHiveEmpty()) {
      try {
        final data = await FirebaseService.fetchUserProfile(uid);
        if (data != null) await HiveService.restoreFromMap(data);
      } catch (_) {}
    }

    Get.find<CartController>().reloadForUser(uid);
    Get.find<FavoritesController>().reloadForUser(uid);

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ShopX',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
