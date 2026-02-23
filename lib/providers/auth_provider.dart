import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_api_store.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.read(authServiceProvider);
  await for (final state in authService.authStateChanges) {
    final event = state.event;
    final isSignedIn = event == MockAuthChangeEvent.signedIn ||
        event == MockAuthChangeEvent.initialSession;
    if (isSignedIn) {
      try {
        yield await authService.getCurrentUserProfile();
      } catch (_) {
        yield null;
      }
    } else if (event == MockAuthChangeEvent.signedOut) {
      yield null;
    }
  }
});

// Convenience: current profile notifier for reading synchronously
class AuthProfileNotifier extends StateNotifier<UserModel?> {
  AuthProfileNotifier() : super(null);

  void setUser(UserModel? user) => state = user;

  Future<void> refresh(AuthService service) async {
    state = await service.getCurrentUserProfile();
  }

  void clear() => state = null;
}

final authProfileProvider =
    StateNotifierProvider<AuthProfileNotifier, UserModel?>(
  (ref) => AuthProfileNotifier(),
);

