import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../modules/bottom_nav/app_bottom_nav_bar.dart';
import '../../../modules/bottom_nav/bottom_nav_controller.dart';
import '../../../modules/cart/cart_controller.dart';
import '../../../modules/chat/chat_view.dart';
import '../../../modules/favorites/favorites_controller.dart';
import '../../../modules/order_history/order_history_view.dart';
import '../../../modules/profile/profile_view.dart';
import 'home_controller.dart';
import '../../widgets/product_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<BottomNavController>();

    return Obx(() {
      final index = navCtrl.currentIndex.value;

      if (index == 1) {
        return const ChatView();
      }

      return Scaffold(
        body: () {
          switch (index) {
            case 0:
              return const _HomeTab();
            case 2:
              return const OrderHistoryView();
            case 3:
              return const ProfileView();
            default:
              return const _HomeTab();
          }
        }(),
        bottomNavigationBar: const AppBottomNavBar(),
      );
    });
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(cart),
                _buildSearchBar(),
                Obx(
                  () => ctrl.isLoading.value
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : ctrl.error.isNotEmpty
                      ? Expanded(child: _buildError(ctrl))
                      : Expanded(child: _buildScrollContent(ctrl)),
                ),
              ],
            ),
          ),
          const _PromoFlyBanner(),
        ],
      ),
    );
  }

  Widget _buildHeader(CartController cart) {
    final favs = Get.find<FavoritesController>();
    final name = HiveService.name;
    final displayName = name.isNotEmpty ? name : 'there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName 👋',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'ShopX',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Favourites
              Obx(
                () => Stack(
                  children: [
                    _iconBtn(
                      Iconsax.heart,
                      () => Get.toNamed(AppRoutes.favorites),
                    ),
                    if (favs.favorites.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${favs.favorites.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Cart
              Obx(
                () => Stack(
                  children: [
                    _iconBtn(
                      Iconsax.shopping_cart,
                      () => Get.toNamed(AppRoutes.cart),
                    ),
                    if (cart.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Iconsax.search_normal,
                      size: 18,
                      color: AppColors.textLight,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Search products...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.search, arguments: {'openFilter': true});
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.setting_4,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollContent(HomeController ctrl) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HomeBanner()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shop by Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.search),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildCategoryIcons(ctrl)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Deals for You',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.search),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          sliver: Obx(() {
            final products = ctrl.filteredProducts;
            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: products[i]),
                childCount: products.length,
              ),
            );
          }),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildCategoryIcons(HomeController ctrl) {
    final categoryMeta = {
      'all': (Iconsax.element_4, 'All'),
      'electronics': (Iconsax.headphone, 'Electronics'),
      "men's clothing": (Icons.person_outline, 'Men'),
      "women's clothing": (Icons.female, 'Women'),
      'jewelery': (Iconsax.crown_1, 'Jewellery'),
    };

    return SizedBox(
      height: 90,
      child: Obx(() {
        final selected = ctrl.selectedCategory.value;
        final cats = ctrl.categories;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.none,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final cat = cats[i];
            final meta = categoryMeta[cat];
            final icon = meta?.$1 ?? Iconsax.box;
            final label = meta?.$2 ?? (cat[0].toUpperCase() + cat.substring(1));
            final isSelected = selected == cat;
            return GestureDetector(
              onTap: () => ctrl.selectCategory(cat),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 12 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildError(HomeController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.wifi_square, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(
            ctrl.error.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: ctrl.loadData, child: const Text('Retry')),
        ],
      ),
    );
  }
}

//  Promo Fly Banner

class _PromoFlyBanner extends StatefulWidget {
  const _PromoFlyBanner();

  @override
  State<_PromoFlyBanner> createState() => _PromoFlyBannerState();
}

class _PromoFlyBannerState extends State<_PromoFlyBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideY;
  late Animation<double> _ropeLength;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _slideY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -1.4,
          end: 0.55,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.55), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.55,
          end: -1.4,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 42,
      ),
    ]).animate(_ctrl);

    _ropeLength = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 42,
      ),
    ]).animate(_ctrl);

    ever(Get.find<HomeController>().showPromoBanner, (show) {
      if (show && mounted) {
        _ctrl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visible = Get.find<HomeController>().showPromoBanner.value;
      if (!visible && !_ctrl.isAnimating) return const SizedBox.shrink();

      final promos = [
        (Iconsax.truck, 'Free Delivery', 'On orders over \$50'),
        (Iconsax.refresh_circle, 'Easy Returns', 'Within 7 days'),
        (Iconsax.shield_tick, 'Secure Payments', '100% Protected'),
      ];

      return Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final ropeH = (_ropeLength.value * 600).clamp(0.0, 600.0);
              return FractionalTranslation(
                translation: Offset(0, _slideY.value),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Rope — left
                        Positioned(
                          left: 18,
                          top: -(ropeH + 4),
                          child: CustomPaint(
                            size: Size(10, ropeH),
                            painter: _RopePainter(),
                          ),
                        ),
                        // Rope — right
                        Positioned(
                          right: 18,
                          top: -(ropeH + 4),
                          child: CustomPaint(
                            size: Size(10, ropeH),
                            painter: _RopePainter(),
                          ),
                        ),
                        // Banner body
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: promos.map((p) {
                              return Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        p.$1,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.$2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      p.$3,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 9,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

//  Rope Painter
class _RopePainter extends CustomPainter {
  const _RopePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height < 2) return;

    final ropePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.7)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(
        size.width / 2 + 6,
        size.height * 0.25,
        size.width / 2 - 8,
        size.height * 0.55,
        size.width / 2 + 4,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width / 2 + 8,
        size.height * 0.88,
        size.width / 2 - 4,
        size.height * 0.94,
        size.width / 2,
        size.height,
      );

    canvas.drawPath(path, ropePaint);

    canvas.drawCircle(
      Offset(size.width / 2, size.height),
      2.5,
      Paint()..color = Colors.grey.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//  Home Banner
class _HomeBanner extends StatefulWidget {
  @override
  State<_HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<_HomeBanner> {
  int _current = 0;
  final PageController _pageCtrl = PageController();

  final _banners = [
    _BannerData(
      title: 'Summer Sale',
      subtitle: 'Up to 40% OFF',
      desc: 'On top brands & trending products',
      gradient: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
      imageUrl:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400&q=80',
      badge: 'HOT DEAL',
    ),
    _BannerData(
      title: 'New Arrivals',
      subtitle: 'Fresh Picks',
      desc: 'Discover the latest trending items',
      gradient: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80',
      badge: 'NEW',
    ),
    _BannerData(
      title: 'Flash Sale',
      subtitle: 'Today Only!',
      desc: 'Limited time deals — grab them fast',
      gradient: [Color(0xFFE91E63), Color(0xFFFF5722)],
      imageUrl:
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&q=80',
      badge: 'LIMITED',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_current + 1) % _banners.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 171,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title, subtitle, desc, imageUrl, badge;
  final List<Color> gradient;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.gradient,
    required this.imageUrl,
    required this.badge,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradient.first.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.gradient.first,
                      data.gradient.first.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.desc,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shop Now',
                          style: TextStyle(
                            color: data.gradient.first,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: data.gradient.first,
                        ),
                      ],
                    ),
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
