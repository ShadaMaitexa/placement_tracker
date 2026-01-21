import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Post-login check for students to ensure they are still in the authorized list
      final role = await getUserRole(response.user?.id);
      if (role == 'student') {
        final bool isAuthorized = await _client.rpc(
          'check_student_authorized',
          params: {'p_email': email},
        );

        if (!isAuthorized) {
          await logout();
          throw Exception('Your account is no longer authorized by the Placement Officer.');
        }
      }

      return response;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Login failed: $e');
    }
  }

  Future<AuthResponse> signUp(String email, String password, String fullName, String role) async {
    try {
      // If student, check if email is pre-authorized by Placement Officer
      if (role == 'student') {
        final bool isAuthorized = await _client.rpc(
          'check_student_authorized',
          params: {'p_email': email},
        );

        if (!isAuthorized) {
          throw Exception('This email is not authorized by the Placement Officer. Please contact the office to be added.');
        }
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
      return response;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Signup failed: $e');
    }
  }

  Future<String?> getUserRole([String? userId]) async {
    final id = userId ?? currentUser?.id;
    if (id == null) return null;

    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', id)
          .maybeSingle();

      if (response != null && response['role'] != null) {
        return response['role'];
      }
      
      // Fallback to user metadata if not in public.users table yet
      final user = currentUser;
      if (user != null && user.id == id) {
        final metadataRole = user.userMetadata?['role'];
        if (metadataRole != null) {
          return metadataRole.toString();
        }
      }

      return null;
    } catch (e) {
      print('DEBUG: Error fetching user role for $id: $e');
      
      // Fallback to user metadata on error
      final user = currentUser;
      if (user != null && user.id == id) {
        final metadataRole = user.userMetadata?['role'];
        if (metadataRole != null) {
          return metadataRole.toString();
        }
      }
      
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
