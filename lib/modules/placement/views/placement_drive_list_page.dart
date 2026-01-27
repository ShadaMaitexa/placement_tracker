import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/placement/models/placement_drive.dart';
import 'add_placement_drive_page.dart';

class PlacementDriveListPage extends StatefulWidget {
  const PlacementDriveListPage({super.key});

  @override
  State<PlacementDriveListPage> createState() => _PlacementDriveListPageState();
}

class _PlacementDriveListPageState extends State<PlacementDriveListPage> {
  final _placementService = PlacementDriveService();
  final _studentService = StudentService();
  final _authService = AuthService();

  List<PlacementDrive> _drives = [];
  List<String> _appliedDriveIds = [];
  bool _isLoading = true;
  String? _userRole;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userRole = await _authService.getUserRole(user.id);
        if (_userRole == 'student') {
          _studentId = await _studentService.getStudentIdByEmail(user.email!);
          if (_studentId != null) {
            _appliedDriveIds = await _studentService.getAppliedDriveIds(
              _studentId!,
            );
          }
        }
        _drives = await _placementService.getAllPlacementDrives();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _applyToDrive(String driveId) async {
    if (_studentId == null) return;
    try {
      await _placementService.applyToDrive(driveId, _studentId!);
      setState(() {
        _appliedDriveIds.add(driveId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Placement Drives', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _drives.isEmpty 
                  ? _buildEmptyState()
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0)),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: context.responsive(1.5, tablet: 1.4, desktop: 1.3),
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final drive = _drives[index];
                                return _buildDriveCard(drive);
                              },
                              childCount: _drives.length,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        floatingActionButton: _userRole == 'admin'
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPlacementDrivePage()),
                  );
                  _initData();
                },
                backgroundColor: const Color(0xFF3B82F6),
                icon: const Icon(Icons.add),
                label: Text('New Drive', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              )
            : null,
      ),
    );
  }

  Widget _buildDriveCard(PlacementDrive drive) {
    final hasApplied = _appliedDriveIds.contains(drive.id);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(drive.companyName ?? 'Unknown Company', 
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(drive.location ?? 'Remote', 
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(drive.title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(drive.jobRole, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const Spacer(),
          const Divider(color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PACKAGE', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                  Text(drive.salaryPackage ?? 'N/A', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                ],
              ),
              if (_userRole == 'student')
                ElevatedButton(
                  onPressed: hasApplied ? null : () => _applyToDrive(drive.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasApplied ? Colors.white10 : Colors.white,
                    foregroundColor: hasApplied ? Colors.white38 : const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(hasApplied ? 'Applied' : 'Apply'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text('No Placement Drives Active', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
        ],
      ),
    );
  }
}

