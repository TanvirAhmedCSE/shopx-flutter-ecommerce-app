import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/hive_service.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/favorites/favorites_controller.dart';
import '../../modules/bottom_nav/bottom_nav_controller.dart';
import '../../modules/home/home_controller.dart';

class SetupProfileView extends StatefulWidget {
  final bool isEdit;
  const SetupProfileView({super.key, required this.isEdit});

  @override
  State<SetupProfileView> createState() => _SetupProfileViewState();
}

class _SetupProfileViewState extends State<SetupProfileView> {
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();

  int? _selectedAvatar;
  bool _nameError = false;
  String _nameErrorText = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String _avatarAsset(int? index) {
    if (index == null) return 'assets/images/avatar_null_profile_picture.png';
    return 'assets/images/avatar_profile_picture_$index.png';
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = true;
        _nameErrorText = 'Display name is required';
      });
      return false;
    }
    if (name.length > 30) {
      setState(() {
        _nameError = true;
        _nameErrorText = 'Name cannot exceed 30 characters';
      });
      return false;
    }
    setState(() {
      _nameError = false;
      _nameErrorText = '';
    });
    return true;
  }

  Future<void> _onDone() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_validate()) return;

    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final avatarPath = _avatarAsset(_selectedAvatar);
    final email = FirebaseService.currentEmail ?? '';
    final uid = FirebaseService.currentUid;

    if (uid != null) {
      await HiveService.openUserBoxes(uid);
      Get.find<CartController>().reloadForUser(uid);
      Get.find<FavoritesController>().reloadForUser(uid);
    }

    await HiveService.saveProfile(
      name: name,
      email: email,
      avatarPath: avatarPath,
    );

    if (uid != null) {
      FirebaseService.saveUserProfile(
        uid: uid,
        name: name,
        avatarPath: avatarPath,
      ).catchError((e) => debugPrint('[SetupProfile] $e'));
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (widget.isEdit) {
      Get.back();
    } else {
      Get.find<BottomNavController>().currentIndex.value = 0;
      Get.offAllNamed(AppRoutes.home);

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.find<HomeController>().triggerPromoBanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Setup Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Avatar picker
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _avatarAsset(_selectedAvatar),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to choose avatar',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Display Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _nameError
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      child: TextField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        maxLength: 30,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        onChanged: (_) {
                          if (_nameError) _validate();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Your name',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_nameError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          _nameErrorText,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onDone,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                widget.isEdit ? 'Edit Profile' : 'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  itemCount: 25,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (_, i) {
                    final idx = i == 0 ? null : i;
                    final path = _avatarAsset(idx);
                    final isSelected = _selectedAvatar == idx;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedAvatar = idx);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
