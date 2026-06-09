import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/services/hive_service.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/order_history/order_history_view.dart';
import '../../modules/auth/setup_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late String _name;
  late String _email;
  late String _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _name = HiveService.name;
      _email = HiveService.email;
      _avatarPath = HiveService.avatarPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Profile Header
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider, width: 1.5),
                    ),
                    child: ClipOval(
                      child: _avatarPath.isNotEmpty
                          ? Image.asset(
                              _avatarPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name.isNotEmpty ? _name : 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            //  Section: Account
            _sectionLabel('Account'),
            _menuCard(
              items: [
                _MenuEntry(
                  icon: Iconsax.edit,
                  label: 'Edit Profile',
                  onTap: () async {
                    await Get.to(() => const SetupProfileView(isEdit: true));
                    _loadProfile();
                  },
                ),
                _MenuEntry(
                  icon: Iconsax.notification,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _MenuEntry(
                  icon: Iconsax.heart,
                  label: 'Favourites',
                  onTap: () => Get.toNamed(AppRoutes.favorites),
                ),
                _MenuEntry(
                  icon: Iconsax.box,
                  label: 'Order History',
                  onTap: () =>
                      Get.to(() => const OrderHistoryView(showBack: true)),
                ),
                _MenuEntry(
                  icon: Iconsax.logout,
                  label: 'Sign Out',
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  onTap: () => _confirmSignOut(context),
                  showChevron: false,
                ),
              ],
            ),

            const SizedBox(height: 40),

            //  App version
            Center(
              child: Text(
                'ShopX v1.0.0',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  //  Helpers

  Widget _defaultAvatar() => Container(
    color: AppColors.background,
    child: const Icon(Icons.person, size: 36, color: AppColors.textLight),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _menuCard({required List<_MenuEntry> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _menuItemWidget(items[i], isLast: i == items.length - 1),
        ],
      ),
    );
  }

  Widget _menuItemWidget(_MenuEntry entry, {required bool isLast}) {
    return Column(
      children: [
        GestureDetector(
          onTap: entry.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(
                  entry.icon,
                  size: 19,
                  color: entry.iconColor ?? AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: entry.labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (entry.showChevron)
                  const Icon(
                    Iconsax.arrow_right_3,
                    size: 15,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 51),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sign out of ShopX?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You'll need to log in again to access your account.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      AuthController.to.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//  Data class

class _MenuEntry {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;

  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
  });
}
