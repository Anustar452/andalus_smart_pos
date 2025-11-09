import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      // Parse user from JSON (simplified)
      try {
        // In real app, you'd parse proper JSON
        return User(
          id: '1',
          email: 'demo@andalus.com',
          name: 'Demo User',
          role: UserRole.owner,
          createdAt: DateTime.now(),
          isActive: true,
          businessId: 'business_1',
          phone: '',
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'demo@andalus.com' && password == 'password') {
      final user = User(
        id: '1',
        email: email,
        name: 'Demo User',
        role: UserRole.owner,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
        businessId: 'business_1',
        phone: '',
      );

      await _saveUser(user);
      return user;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<User> register(
      String email, String password, String name, String businessName) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: UserRole.owner,
      createdAt: DateTime.now(),
      isActive: true,
      businessId: 'business_${DateTime.now().millisecondsSinceEpoch}',
      phone: '',
    );

    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  Future<User> updateProfile(User user) async {
    await _saveUser(user);
    return user;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // In real app, you'd serialize to JSON
    await prefs.setString(_userKey, 'user_data');
    await prefs.setString(_tokenKey, 'demo_token_${user.id}');
  }
}
