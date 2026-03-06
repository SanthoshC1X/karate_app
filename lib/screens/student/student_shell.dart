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
    AppNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
      path: '/student/chat',
      matchPrefix: '/student/chat',
    ),
    AppNavItem(
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      label: 'Payment',
      path: '/student/payment',
      matchPrefix: '/student/payment',
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

