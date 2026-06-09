import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/theme.dart';
import '../../modules/cart/cart_controller.dart';
import '../../widgets/product_card.dart';
import 'search_controller.dart';
import '../home/home_controller.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProductSearchController());
    final cart = Get.find<CartController>();

    // If navigated with openFilter:true, open dialog after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['openFilter'] == true) {
        _showFilterDialog(context, ctrl);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
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
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        title: _SearchField(ctrl: ctrl),
        titleSpacing: 0,
        actions: [
          // Filter chip
          Obx(
            () => GestureDetector(
              onTap: () => _showFilterDialog(context, ctrl),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ctrl.hasActiveFilters
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: ctrl.hasActiveFilters
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: ctrl.hasActiveFilters ? 10 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.setting_4,
                  size: 20,
                  color: ctrl.hasActiveFilters
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Cart
          Obx(
            () => cart.totalItems > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/cart'),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Iconsax.shopping_cart,
                            color: AppColors.textPrimary,
                          ),
                          Positioned(
                            right: 0,
                            top: 8,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${cart.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 17),
        ],
      ),
      body: Obx(() {
        final results = ctrl.results;

        if (ctrl.query.isEmpty && !ctrl.hasActiveFilters) {
          return _buildEmptyQuery();
        }

        if (results.isEmpty) {
          return _buildNoResults(ctrl.query.value);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ctrl.query.isNotEmpty) ...[
                    const Text(
                      ' for ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '"${ctrl.query.value}"',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (ctrl.hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: ctrl.resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Clear filters',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
                itemCount: results.length,
                itemBuilder: (_, i) => ProductCard(product: results[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showFilterDialog(BuildContext context, ProductSearchController ctrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _FilterDialog(ctrl: ctrl),
    );
  }

  Widget _buildEmptyQuery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.search_normal,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Search for products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find anything by name or category',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String q) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.search_status,
              size: 40,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            q.isNotEmpty ? 'No results for "$q"' : 'No products match filters',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search term',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

//  Filter Dialog

class _FilterDialog extends StatefulWidget {
  final ProductSearchController ctrl;
  const _FilterDialog({required this.ctrl});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late Set<String> _selectedCats;
  late RangeValues _priceRange;
  late RangeValues _ratingRange;
  late RangeValues _ratingCountRange;

  static const double _priceMin = 0;
  static const double _priceMax = 1000;
  static const double _ratingMin = 0;
  static const double _ratingMax = 5;
  static const double _countMin = 0;
  static const double _countMax = 500;

  @override
  void initState() {
    super.initState();
    _selectedCats = Set.from(widget.ctrl.selectedCategories);
    _priceRange = RangeValues(
      widget.ctrl.priceMin.value.clamp(_priceMin, _priceMax),
      widget.ctrl.priceMax.value.clamp(_priceMin, _priceMax),
    );
    _ratingRange = RangeValues(
      widget.ctrl.ratingMin.value.clamp(_ratingMin, _ratingMax),
      widget.ctrl.ratingMax.value.clamp(_ratingMin, _ratingMax),
    );
    _ratingCountRange = RangeValues(
      widget.ctrl.ratingCountMin.value.clamp(_countMin, _countMax),
      widget.ctrl.ratingCountMax.value.clamp(_countMin, _countMax),
    );
  }

  List<String> get _categories {
    try {
      final cats = Get.find<HomeController>().categories.toList();
      return cats.where((c) => c != 'all').toList();
    } catch (_) {
      return [];
    }
  }

  String _catLabel(String cat) {
    const labels = {
      'electronics': 'Electronics',
      "men's clothing": 'Men\'s Fashion',
      "women's clothing": 'Women\'s Fashion',
      'jewelery': 'Jewellery',
    };
    return labels[cat] ?? (cat[0].toUpperCase() + cat.substring(1));
  }

  void _reset() {
    setState(() {
      _selectedCats.clear();
      _priceRange = const RangeValues(_priceMin, _priceMax);
      _ratingRange = const RangeValues(_ratingMin, _ratingMax);
      _ratingCountRange = const RangeValues(_countMin, _countMax);
    });
  }

  void _apply() {
    widget.ctrl.selectedCategories.assignAll(_selectedCats);
    widget.ctrl.priceMin(_priceRange.start);
    widget.ctrl.priceMax(_priceRange.end);
    widget.ctrl.ratingMin(_ratingRange.start);
    widget.ctrl.ratingMax(_ratingRange.end);
    widget.ctrl.ratingCountMin(_ratingCountRange.start);
    widget.ctrl.ratingCountMax(_ratingCountRange.end);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  const Text(
                    'Filter Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            const SizedBox(height: 4),
            Divider(color: AppColors.divider, thickness: 1),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Category
                    _sectionLabel('Category'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = _selectedCats.contains(cat);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedCats.remove(cat);
                            } else {
                              _selectedCats.add(cat);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.divider,
                                width: 1.5,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              _catLabel(cat),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: 12),

                    //  Price Range
                    _sectionLabel('Price Range (USD)'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _rangeLabel(
                          '\$${_priceRange.start.toStringAsFixed(0)}',
                        ),
                        _rangeLabel('\$${_priceRange.end.toStringAsFixed(0)}'),
                      ],
                    ),
                    SliderTheme(
                      data: _sliderTheme(context),
                      child: RangeSlider(
                        values: _priceRange,
                        min: _priceMin,
                        max: _priceMax,
                        divisions: 100,
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ),

                    const SizedBox(height: 4),
                    Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: 12),

                    //  Rating
                    _sectionLabel('Rating (stars)'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _rangeLabel(
                          '${_ratingRange.start.toStringAsFixed(1)} ★',
                        ),
                        _rangeLabel('${_ratingRange.end.toStringAsFixed(1)} ★'),
                      ],
                    ),
                    SliderTheme(
                      data: _sliderTheme(context),
                      child: RangeSlider(
                        values: _ratingRange,
                        min: _ratingMin,
                        max: _ratingMax,
                        divisions: 50,
                        onChanged: (v) => setState(() => _ratingRange = v),
                      ),
                    ),

                    const SizedBox(height: 4),
                    Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: 12),

                    //  Rating Count
                    _sectionLabel('Number of Ratings'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _rangeLabel(
                          '${_ratingCountRange.start.toInt()} reviews',
                        ),
                        _rangeLabel('${_ratingCountRange.end.toInt()} reviews'),
                      ],
                    ),
                    SliderTheme(
                      data: _sliderTheme(context),
                      child: RangeSlider(
                        values: _ratingCountRange,
                        min: _countMin,
                        max: _countMax,
                        divisions: 50,
                        onChanged: (v) => setState(() => _ratingCountRange = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            //  Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _apply,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
  );

  Widget _rangeLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
  );

  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
    );
  }
}

//  Search Field

class _SearchField extends StatefulWidget {
  final ProductSearchController ctrl;
  const _SearchField({required this.ctrl});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _text,
      autofocus: true,
      onChanged: widget.ctrl.query,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.only(
          left: 4,
          right: 4,
          top: 13,
          bottom: 0,
        ),
        suffixIcon: Obx(
          () => widget.ctrl.query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _text.clear();
                    widget.ctrl.query('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
