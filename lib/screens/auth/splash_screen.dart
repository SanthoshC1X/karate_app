import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/brand_mark.dart';
import '../../widgets/common/app_skeleton_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.init();
    if (!mounted) return;
    if (authProvider.isLoggedIn) {
      try {
        await authProvider.loadProfile();
        final profile = authProvider.currentUser;
        if (!mounted) return;
        if (profile != null &&
            (profile.member == 'master' || profile.member == 'super_admin')) {
          context.go('/admin/dashboard');
        } else {
          context.go('/student/home');
        }
      } catch (_) {
        if (!mounted) return;
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: const BrandMark(size: 120, iconSize: 64, glowOpacity: 0.5),
              ),
              const SizedBox(height: 32),
              Text(
                'KARATE CLASS',
                style: AppText.titleLg.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'train. discipline. achieve.',
                style: AppText.caption.copyWith(fontSize: 14, letterSpacing: 2),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 90,
                child: AppSkeletonLoading(height: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

