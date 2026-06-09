import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/product_card.dart';
import 'favorites_controller.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: const BackButton(),
      ),
      body: Obx(() {
        if (ctrl.favorites.isEmpty) {
          return _buildEmpty();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                '${ctrl.favorites.length} saved items',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: ctrl.favorites.length,
                itemBuilder: (_, i) => ProductCard(product: ctrl.favorites[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.heart, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          const Text(
            'No wishlist items yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart icon on any product\nto save it here',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.home),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: const Text('Explore Products'),
            ),
          ),
        ],
      ),
    );
  }
}
