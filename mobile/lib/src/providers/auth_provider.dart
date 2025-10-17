// mobile/lib/src/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password, String deviceName) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref
          .read(apiServiceProvider)
          .login(email: email, password: password, deviceName: deviceName);

      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);

      state = AsyncValue.data(User.fromJson(response['user']));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = const AsyncValue.data(null);
  }
}
