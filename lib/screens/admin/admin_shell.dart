import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_bottom_navigation.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const List<AppNavItem> _navItems = [
    AppNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      path: '/admin/messages',
      matchPrefix: '/admin/messages',
    ),
    AppNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      path: '/admin/dashboard',
      matchPrefix: '/admin/dashboard',
    ),
    AppNavItem(
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      label: 'Payment',
      path: '/admin/payment',
      matchPrefix: '/admin/payment',
    ),
    AppNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      path: '/admin/profile',
      matchPrefix: '/admin/profile',
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

