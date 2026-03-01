import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final String matchPrefix;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    required this.matchPrefix,
  });
}

class AppBottomNavigation extends StatelessWidget {
  final List<AppNavItem> items;
  final String currentPath;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentPath,
  });

  int _activeIndex() {
    for (var i = 0; i < items.length; i++) {
      if (currentPath.startsWith(items[i].matchPrefix)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: activeIndex,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppText.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppText.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        onTap: (index) => context.go(items[index].path),
        items: items.asMap().entries.map((entry) {
          final item = entry.value;
          return BottomNavigationBarItem(
            label: item.label,
            icon: _NavIcon(icon: item.icon, active: false),
            activeIcon: _NavIcon(icon: item.activeIcon, active: true),
          );
        }).toList(),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _NavIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 22,
        color: active ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
