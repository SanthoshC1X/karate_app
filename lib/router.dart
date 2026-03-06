import 'package:go_router/go_router.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/register_master_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/locations_screen.dart';
import 'screens/admin/students_list_screen.dart';
import 'screens/admin/student_detail_screen.dart';
import 'screens/admin/mark_attendance_screen.dart';
import 'screens/admin/create_post_screen.dart';
import 'screens/admin/payment_screen.dart';
import 'screens/admin/student_payment_history_screen.dart';
import 'screens/admin/master_profile_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/student/home_feed_screen.dart';
import 'screens/student/my_profile_screen.dart';
import 'screens/student/my_attendance_screen.dart';
import 'screens/student/post_detail_screen.dart';
import 'screens/student/student_payment_screen.dart';
import 'screens/shared/conversations_screen.dart';
import 'screens/shared/chat_screen.dart';
import 'models/conversation_model.dart';
import 'services/auth_service.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLoggedIn = AuthService().isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/register-master' ||
        state.matchedLocation == '/splash';
    if (!isLoggedIn && !isAuthRoute) return '/splash';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/register-master',
      builder: (_, __) => const RegisterMasterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/admin/locations',
          builder: (_, __) => const LocationsScreen(),
        ),
        GoRoute(
          path: '/admin/students',
          builder: (_, __) => const StudentsListScreen(),
        ),
        GoRoute(
          path: '/admin/students/:id',
          builder: (_, state) =>
              StudentDetailScreen(studentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/attendance',
          builder: (_, __) => const MarkAttendanceScreen(),
        ),
        GoRoute(
          path: '/admin/posts/create',
          builder: (_, __) => const CreatePostScreen(),
        ),
        GoRoute(
          path: '/admin/messages',
          builder: (_, __) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/admin/payment',
          builder: (_, __) => const PaymentScreen(),
        ),
        GoRoute(
          path: '/admin/payment/student/:studentId',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return StudentPaymentHistoryScreen(
              studentId: state.pathParameters['studentId']!,
              studentName: extra['name'] as String? ?? 'Student',
              initialYear: extra['year'] as int? ?? DateTime.now().year,
            );
          },
        ),
        GoRoute(
          path: '/admin/profile',
          builder: (_, __) => const MasterProfileScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(
          path: '/student/home',
          builder: (_, __) => const HomeFeedScreen(),
        ),
        GoRoute(
          path: '/student/profile',
          builder: (_, __) => const MyProfileScreen(),
        ),
        GoRoute(
          path: '/student/attendance',
          builder: (_, __) => const MyAttendanceScreen(),
        ),
        GoRoute(
          path: '/student/posts/:id',
          builder: (_, state) =>
              PostDetailScreen(postId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/student/chat',
          builder: (_, __) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/student/payment',
          builder: (_, __) => const StudentPaymentScreen(),
        ),
      ],
    ),
    // Chat screen — pushed on top of shell (no bottom nav)
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) => ChatScreen(
        conversationId: state.pathParameters['id']!,
        conversation: state.extra as ConversationModel?,
      ),
    ),
  ],
);
