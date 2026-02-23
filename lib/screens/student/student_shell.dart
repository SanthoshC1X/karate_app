import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_bottom_navigation.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  static const List<AppNavItem> _navItems = [
    AppNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      path: '/student/home',
      matchPrefix: '/student/home',
    ),
    AppNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      path: '/student/profile',
      matchPrefix: '/student/profile',
    ),
    AppNavItem(
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check,
      label: 'Attendance',
      path: '/student/attendance',
      matchPrefix: '/student/attendance',
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

