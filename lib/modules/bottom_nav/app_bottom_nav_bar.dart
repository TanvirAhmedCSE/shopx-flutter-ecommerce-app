import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/theme.dart';
import '../chat/chat_controller.dart';
import 'bottom_nav_controller.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = BottomNavController.to;
    final chat = ChatController.to;

    return Obx(() {
      final current = ctrl.currentIndex.value;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_2,
                  label: 'Home',
                  isActive: current == 0,
                  onTap: () => ctrl.changePage(0),
                ),
                // Chat with unread badge
                Obx(
                  () => _NavItem(
                    icon: Iconsax.message,
                    activeIcon: Iconsax.message5,
                    label: 'Chat',
                    isActive: current == 1,
                    badge: chat.unreadCount.value,
                    onTap: () => ctrl.changePage(1),
                  ),
                ),
                _NavItem(
                  icon: Iconsax.box,
                  activeIcon: Iconsax.box,
                  label: 'Orders',
                  isActive: current == 2,
                  onTap: () => ctrl.changePage(2),
                ),
                _NavItem(
                  icon: Iconsax.user,
                  activeIcon: Iconsax.user,
                  label: 'Profile',
                  isActive: current == 3,
                  onTap: () => ctrl.changePage(3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
