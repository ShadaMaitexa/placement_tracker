import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'];
    } catch (e) {
      // Return null if user profile is not found or other db error
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
