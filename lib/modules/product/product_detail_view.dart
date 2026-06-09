import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/models/product_model.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/favorites/favorites_controller.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductModel product = Get.arguments;
    final cart = Get.find<CartController>();
    final favs = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              //  Hero Image AppBar
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => favs.toggle(product),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: favs.isFavorite(product.id)
                                ? AppColors.error.withValues(alpha: 0.10)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            favs.isFavorite(product.id)
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            size: 19,
                            color: favs.isFavorite(product.id)
                                ? AppColors.error
                                : AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProductImageSection(product: product),
                ),
              ),

              //  Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFFF7F8FA)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Title + Rating card
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.35,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Rating row
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: product.rating,
                                  itemBuilder: (_, __) => const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.star,
                                  ),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${product.ratingCount} reviews)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Description card
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.75,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom spacing for the sticky bar
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),

          //  Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart button
                  Expanded(
                    child: Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 52,
                        decoration: BoxDecoration(
                          color: cart.isInCart(product.id)
                              ? AppColors.success
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (cart.isInCart(product.id)
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => cart.toggleCart(product),
                          icon: Icon(
                            cart.isInCart(product.id)
                                ? Iconsax.tick_circle
                                : Iconsax.shopping_bag,
                            size: 18,
                          ),
                          label: Text(
                            cart.isInCart(product.id)
                                ? 'Added to Cart'
                                : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Cart icon button
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.cart),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Iconsax.shopping_cart,
                        size: 20,
                        color: AppColors.secondary,
                      ),
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
}

//  Product Image Section
class _ProductImageSection extends StatelessWidget {
  final ProductModel product;
  const _ProductImageSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Subtle gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF0F5), Color(0xFFF9FAFB), Color(0xFFEEF0F5)],
            ),
          ),
        ),
        // Decorative circle accents
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Product image
        Padding(
          padding: const EdgeInsets.fromLTRB(60, 72, 60, 28),
          child: Hero(
            tag: 'product_${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.image,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
