import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _studentService = StudentService();
  final _authService = AuthService();
  Student? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final student = await _studentService.getStudentByEmail(user.email!);
        setState(() => _student = student);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _student == null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildMainInfoCard(),
                            const SizedBox(height: 24),
                            _buildDetailsSection(),
                            const SizedBox(height: 24),
                            _buildSkillsSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('My Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              _student!.name[0].toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(_student!.name, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(_student!.email ?? '', style: GoogleFonts.inter(fontSize: 14, color: Colors.white60)),
          const SizedBox(height: 16),
          _buildStatusTag(_student!.eligibilityStatus),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _infoRow(Icons.school_outlined, 'College', _student!.collegeName ?? 'Not specified'),
              _infoRow(Icons.history_edu_outlined, 'Qualification', _student!.qualification ?? 'Not specified'),
              _infoRow(Icons.book_outlined, 'Course', _student!.primaryCourse ?? 'Not specified'),
              _infoRow(Icons.group_outlined, 'Batch', _student!.batch ?? 'Not specified'),
              _infoRow(Icons.calendar_today_outlined, 'Passing Year', _student!.passingYear?.toString() ?? 'Not specified'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skills', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_student!.skills ?? []).map((skill) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Text(skill, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF60A5FA), fontWeight: FontWeight.w500)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold)),
                Text(value, style: GoogleFonts.inter(fontSize: 15, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String? status) {
    Color color;
    String label;
    switch (status) {
      case 'ready': color = const Color(0xFF10B981); label = 'READY FOR PLACEMENT'; break;
      case 'training': color = const Color(0xFFF59E0B); label = 'IN TRAINING'; break;
      default: color = const Color(0xFFEF4444); label = 'NOT ELIGIBLE';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text('Profile not found', style: GoogleFonts.outfit(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }
}
