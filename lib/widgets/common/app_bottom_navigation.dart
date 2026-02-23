import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

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
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: activeIndex,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textOnDark38,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        onTap: (index) => context.go(items[index].path),
        items: items
            .asMap()
            .entries
            .map(
              (entry) => BottomNavigationBarItem(
                icon: Icon(
                  activeIndex == entry.key
                      ? entry.value.activeIcon
                      : entry.value.icon,
                ),
                label: entry.value.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
