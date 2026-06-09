import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../data/models/product_model.dart';
import '../modules/cart/cart_controller.dart';
import '../modules/favorites/favorites_controller.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final favs = Get.find<FavoritesController>();

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF7F7F7),
                      padding: const EdgeInsets.all(14),
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favourite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => favs.toggle(product),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            favs.isFavorite(product.id)
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            size: 16,
                            color: favs.isFavorite(product.id)
                                ? AppColors.error
                                : AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        size: 11,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price + cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: () => cart.toggleCart(product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cart.isInCart(product.id)
                                  ? AppColors.primary
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              cart.isInCart(product.id)
                                  ? Iconsax.shopping_cart
                                  : Iconsax.add,
                              size: 16,
                              color: cart.isInCart(product.id)
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
