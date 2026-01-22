import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/admin/admin_home.dart';
import 'package:placement_tracker/modules/student/student_home.dart';
import 'package:placement_tracker/modules/trainer/trainer_home.dart';
import 'package:placement_tracker/modules/company/views/company_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool loading = false;
  bool _isObscure = true;
  bool _isSignUp = false;
  String _selectedRole = 'student';

  static const List<Map<String, String>> _roles = [
    {'value': 'student', 'label': 'Student'},
    {'value': 'admin', 'label': 'Placement Officer'},
    {'value': 'trainer', 'label': 'Trainer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: FadeInDown(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(context.responsive(24.0, tablet: 40.0)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.school_rounded, color: Color(0xFF3B82F6), size: 40),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Placement Tracker',
                                style: GoogleFonts.outfit(
                                  fontSize: context.responsive(28.0, tablet: 32.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Empowering Futures, One Placement at a Time',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              if (_isSignUp) ...[
                                _buildTextField(
                                  controller: nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 16),
                                _buildRoleSelector(),
                                const SizedBox(height: 16),
                              ],
                              _buildTextField(
                                controller: emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: loading ? null : _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0F172A),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 0,
                                  ),
                                  child: loading
                                      ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                                      : Text(
                                          _isSignUp ? 'Create Account' : 'Sign In',
                                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                                    children: [
                                      TextSpan(text: _isSignUp ? 'Already have an account? ' : "Don't have an account? "),
                                      TextSpan(
                                        text: _isSignUp ? 'Sign In' : 'Sign Up',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Role',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              isExpanded: true,
              style: GoogleFonts.inter(color: Colors.white),
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['value'],
                  child: Text(role['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _isObscure,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white60, size: 20),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => loading = true);
    try {
      final auth = AuthService();
      if (_isSignUp) {
        await auth.signUp(emailController.text, passwordController.text, nameController.text, _selectedRole);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please sign in.')));
        setState(() => _isSignUp = false);
      } else {
        await auth.login(emailController.text, passwordController.text);
        if (mounted) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            final role = await auth.getUserRole(session.user.id);
            if (mounted) _navigateBasedOnRole(role);
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _navigateBasedOnRole(String? role) {
    Widget nextScreen;
    switch (role) {
      case 'admin':
        nextScreen = const AdminHome();
        break;
      case 'trainer':
        nextScreen = const TrainerHome();
        break;
      case 'company':
        nextScreen = const CompanyHome();
        break;
      default:
        nextScreen = const StudentHome();
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }
}
