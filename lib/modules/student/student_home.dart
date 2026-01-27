import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/placement/views/placement_drive_list_page.dart';
import 'package:placement_tracker/modules/aptitude/views/aptitude_result_page.dart';
import 'package:placement_tracker/modules/mock/views/mock_interview_list_page.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';
import 'package:placement_tracker/modules/student/views/student_profile_page.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/core/services/mock_service.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import '../auth/login_page.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final _authService = AuthService();
  final _studentService = StudentService();
  final _placementService = PlacementDriveService();
  final _mockService = MockInterviewService();
  final _aptitudeService = AptitudeService();

  Student? _student;
  bool _isLoading = true;
  int _applicationCount = 0;
  int _interviewCount = 0;
  double _avgAptitude = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final student = await _studentService.getStudentByEmail(user.email!);
        if (student != null) {
          _student = student;
          
          // Fetch stats in parallel
          final results = await Future.wait([
            _placementService.getStudentApplications(student.id!),
            _mockService.getInterviewsForStudent(student.id!),
            _aptitudeService.getResultsForStudent(student.id!),
          ]);

          final apps = results[0] as List<String>;
          final interviews = results[1] as List;
          final aptResults = results[2] as List;

          _applicationCount = apps.length;
          _interviewCount = interviews.length;

          if (aptResults.isNotEmpty) {
            int totalScore = 0;
            int totalMax = 0;
            for (var res in aptResults) {
              totalScore += (res as dynamic).score as int;
              totalMax += (res as dynamic).maxScore as int;
            }
            _avgAptitude = totalMax > 0 ? (totalScore / totalMax) * 100 : 0.0;
          } else {
            _avgAptitude = 0.0;
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF3B82F6),
                child: CustomScrollView(
                  slivers: [
                    // Custom App Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FadeInDown(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Dashboard',
                                    style: GoogleFonts.outfit(
                                      fontSize: context.responsive(24.0, tablet: 28.0, desktop: 32.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Track your placement journey',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white),
                                onPressed: () async {
                                  await _authService.logout();
                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildProfileCard(_student),
                        ),
                      ),
                    ),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                children: [
                                  Expanded(child: _buildStatCard(_applicationCount.toString(), 'Applications', Icons.send, const Color(0xFF3B82F6))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildStatCard(_interviewCount.toString(), 'Interviews', Icons.calendar_today, const Color(0xFF8B5CF6))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildStatCard('${_avgAptitude.toInt()}%', 'Aptitude', Icons.trending_up, const Color(0xFF10B981))),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        child: FadeInLeft(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            'Quick Actions',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Action Cards
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: context.isMobile 
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                              _actionList(context),
                              const SizedBox(height: 40),
                            ]),
                          )
                        : SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.isTablet ? 2 : 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                            ),
                            delegate: SliverChildListDelegate([
                              _actionItem(
                                context,
                                title: 'Placement Drives',
                                subtitle: 'View and apply to opportunities',
                                icon: Icons.work_outline,
                                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementDriveListPage())),
                              ),
                              _actionItem(
                                context,
                                title: 'Aptitude Results',
                                subtitle: 'Check your test scores',
                                icon: Icons.assessment_outlined,
                                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AptitudeResultListPage())),
                              ),
                              _actionItem(
                                context,
                                title: 'Mock Interview Feedback',
                                subtitle: 'View mentor feedback',
                                icon: Icons.mic_none,
                                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewListPage())),
                              ),
                              _actionItem(
                                context,
                                title: 'My Profile',
                                subtitle: 'Update resume & skills',
                                icon: Icons.person_outline,
                                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfilePage())),
                              ),
                            ]),
                          ),
                    ),
                    if (!context.isMobile) const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionList(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(
          context,
          title: 'Placement Drives',
          subtitle: 'View and apply to opportunities',
          icon: Icons.work_outline,
          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementDriveListPage())),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Aptitude Results',
          subtitle: 'Check your test scores',
          icon: Icons.assessment_outlined,
          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AptitudeResultListPage())),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Mock Interview Feedback',
          subtitle: 'View mentor feedback',
          icon: Icons.mic_none,
          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewListPage())),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'My Profile',
          subtitle: 'Update resume & skills',
          icon: Icons.person_outline,
          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfilePage())),
        ),
      ],
    );
  }

  Widget _actionItem(BuildContext context, {required String title, required String subtitle, required IconData icon, required Gradient gradient, required VoidCallback onTap}) {
    return _buildActionCard(context, title: title, subtitle: subtitle, icon: icon, gradient: gradient, onTap: onTap);
  }

  Widget _buildProfileCard(Student? student) {
    if (student == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('Profile details unavailable', style: TextStyle(color: Colors.white70))),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                ),
                child: CircleAvatar(
                  radius: context.responsive(25.0, tablet: 35.0),
                  backgroundColor: const Color(0xFF1E293B),
                  child: Text(student.name[0].toUpperCase(), style: TextStyle(fontSize: context.responsive(18.0, tablet: 24.0), fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Back!', style: GoogleFonts.inter(fontSize: 14, color: Colors.white60)),
                    const SizedBox(height: 2),
                    Text(
                      student.name, 
                      style: GoogleFonts.outfit(
                        fontSize: context.responsive(18.0, tablet: 22.0), 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusChip(student.eligibilityStatus),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    switch (status) {
      case 'ready': color = const Color(0xFF10B981); label = 'Ready'; break;
      case 'training': color = const Color(0xFFF59E0B); label = 'In Training'; break;
      default: color = const Color(0xFFEF4444); label = 'Needs Check';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: context.responsive(20.0, tablet: 24.0)),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.outfit(fontSize: context.responsive(16.0, tablet: 20.0), fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Gradient gradient, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                          const SizedBox(height: 2),
                          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

