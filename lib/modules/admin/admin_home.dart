import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/company/views/company_list_page.dart';
import 'package:placement_tracker/modules/placement/views/placement_drive_list_page.dart';
import 'package:placement_tracker/modules/aptitude/views/aptitude_list_page.dart';
import 'package:placement_tracker/modules/mock/views/mock_interview_list_page.dart';
import 'student_list_page.dart';
import '../auth/login_page.dart';
import '../../core/services/dashboard_service.dart';
import 'reports_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _dashboardService = DashboardService();
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'readyStudents': 0,
    'totalCompanies': 0,
    'activeDrives': 0,
    'placedStudents': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final stats = await _dashboardService.getAdminStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onRefresh: _loadStats,
                color: const Color(0xFF3B82F6),
                child: CustomScrollView(
                  slivers: [
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
                                    'Placement Officer',
                                    style: GoogleFonts.outfit(
                                      fontSize: context.responsive(24.0, tablet: 28.0, desktop: 32.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Manage placements & track progress',
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
                                  await AuthService().logout();
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = context.responsive(2, tablet: 3, desktop: 4);
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildStatCard(
                                    _stats['totalStudents'].toString(),
                                    'Total Students',
                                    Icons.people_outline,
                                    const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                  ),
                                  _buildStatCard(
                                    _stats['totalCompanies'].toString(),
                                    'Companies',
                                    Icons.business_outlined,
                                    const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                  ),
                                  _buildStatCard(
                                    _stats['activeDrives'].toString(),
                                    'Active Drives',
                                    Icons.work_outline,
                                    const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                  ),
                                  _buildStatCard(
                                    _stats['placedStudents'].toString(),
                                    'Placed',
                                    Icons.verified_outlined,
                                    const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                        child: FadeInLeft(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'Management Modules',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(2, tablet: 3, desktop: 4),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: context.responsive(1.0, tablet: 1.1, desktop: 1.2),
                        ),
                        delegate: SliverChildListDelegate([
                          _buildModuleItem(
                            title: 'Students',
                            icon: Icons.people_outline,
                            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListPage()));
                              _loadStats();
                            },
                          ),
                          _buildModuleItem(
                            title: 'Companies',
                            icon: Icons.business_outlined,
                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyListPage()));
                              _loadStats();
                            },
                          ),
                          _buildModuleItem(
                            title: 'Placement Drives',
                            icon: Icons.work_outline,
                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementDriveListPage()));
                              _loadStats();
                            },
                          ),
                          _buildModuleItem(
                            title: 'Aptitude Tests',
                            icon: Icons.quiz_outlined,
                            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AptitudeTestListPage()));
                              _loadStats();
                            },
                          ),
                          _buildModuleItem(
                            title: 'Mock Interviews',
                            icon: Icons.mic_external_on_outlined,
                            gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewListPage()));
                              _loadStats();
                            },
                          ),
                          _buildModuleItem(
                            title: 'Reports',
                            icon: Icons.analytics_outlined,
                            gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())),
                          ),
                        ]),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Gradient gradient) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(6)),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label, 
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleItem({required String title, required IconData icon, required Gradient gradient, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.responsive(16.0, tablet: 20.0)),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Icon(icon, color: Colors.white, size: context.responsive(24.0, tablet: 32.0)),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        title, 
                        style: GoogleFonts.outfit(
                          fontSize: context.responsive(13.0, tablet: 15.0), 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ), 
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

