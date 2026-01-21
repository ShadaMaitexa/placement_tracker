import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import '../admin/admin_home.dart';
import '../student/student_home.dart';
import '../trainer/trainer_home.dart';
import '../company/views/company_home.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if a session already exists
    final session = Supabase.instance.client.auth.currentSession;

    // If no session, show Login Page
    if (session == null) {
      return const LoginPage();
    }

    // If session exists, fetch role and redirect
    return FutureBuilder<String?>(
      future: AuthService().getUserRole(),
      builder: (context, snapshot) {
        // While fetching role, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If error or no data
        if (!snapshot.hasData || snapshot.data == null) {
          // Fallback to login or show error
          return const LoginPage();
        }

        final role = snapshot.data;

        // Route based on role
        if (role == 'admin') return const AdminHome();
        if (role == 'student') return const StudentHome();
        if (role == 'trainer') return const TrainerHome();

        // If role doesn't match known roles
        return const Scaffold(
          body: Center(child: Text('Unknown Role Assigned')),
        );
      },
    );
  }
}
