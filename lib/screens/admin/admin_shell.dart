import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_bottom_navigation.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const List<AppNavItem> _navItems = [
    AppNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      path: '/admin/dashboard',
      matchPrefix: '/admin/dashboard',
    ),
    AppNavItem(
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on,
      label: 'Locations',
      path: '/admin/locations',
      matchPrefix: '/admin/locations',
    ),
    AppNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Students',
      path: '/admin/students',
      matchPrefix: '/admin/students',
    ),
    AppNavItem(
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check,
      label: 'Attendance',
      path: '/admin/attendance',
      matchPrefix: '/admin/attendance',
    ),
    AppNavItem(
      icon: Icons.post_add_outlined,
      activeIcon: Icons.post_add,
      label: 'Posts',
      path: '/admin/posts/create',
      matchPrefix: '/admin/posts',
    ),
    AppNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      path: '/admin/messages',
      matchPrefix: '/admin/messages',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigation(
        items: _navItems,
        currentPath: currentPath,
      ),
    );
  }
}

