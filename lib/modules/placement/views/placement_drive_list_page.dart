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
          final student = await _studentService.getStudentByEmail(user.email!);
          if (student != null) {
            _studentId = student.id;
            _appliedDriveIds = await _placementService.getStudentApplications(_studentId!);
          }
        }
      }
      await _loadDrives();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDrives() async {
    try {
      final data = await _placementService.getDrives();
      if (mounted) {
        setState(() {
          _drives = data;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleApply(String driveId) async {
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student profile not found.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _placementService.applyToDrive(driveId, _studentId!);
      _appliedDriveIds = await _placementService.getStudentApplications(_studentId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applied successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'admin';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Placement Drives', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      floatingActionButton: isAdmin 
          ? FloatingActionButton.extended(
              onPressed: () async {
                final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlacementDrivePage()));
                if (res == true) _loadDrives();
              },
              backgroundColor: const Color(0xFF3B82F6),
              label: Text('New Drive', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drives.isEmpty
              ? _buildEmptyState()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: RefreshIndicator(
                      onRefresh: _loadDrives,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(child: SizedBox(height: 16)),
                            SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: context.responsive(2.8, tablet: 2.2, desktop: 2.0),
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildDriveCard(_drives[index], isAdmin),
                                itemCount: _drives.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDriveCard(PlacementDrive drive, bool isAdmin) {
    final isApplied = _appliedDriveIds.contains(drive.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (isAdmin) {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPlacementDrivePage(drive: drive)),
              );
              if (res == true) _loadDrives();
            } else {
              _showDriveDetails(drive, isApplied);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildDateStack(drive.driveDate),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(drive.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${drive.companyName ?? 'Unknown Company'} • ${drive.jobRole}', 
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(drive.salaryPackage ?? 'Competitive', 
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusChip(drive.status),
                    const SizedBox(height: 8),
                    if (!isAdmin && (drive.status == 'upcoming' || drive.status == 'ongoing'))
                      ElevatedButton(
                        onPressed: isApplied ? null : () => _handleApply(drive.id!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApplied ? Colors.grey : const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(60, 28),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isApplied ? 'Applied' : 'Apply', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDriveDetails(PlacementDrive drive, bool isApplied) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(drive.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${drive.companyName ?? 'Unknown Company'} - ${drive.jobRole}', style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w500)),
            const Divider(height: 32),
            _detailRow(Icons.location_on_outlined, 'Location', drive.location ?? 'Remote / TBD'),
            _detailRow(Icons.payments_outlined, 'Package', drive.salaryPackage ?? 'Competitive'),
            _detailRow(Icons.checklist_outlined, 'Eligibility', drive.eligibilityCriteria ?? 'Open to all'),
            _detailRow(Icons.calendar_today_outlined, 'Drive Date', drive.driveDate?.toString().split(' ')[0] ?? 'TBD'),
            _detailRow(Icons.description_outlined, 'Description', drive.description ?? 'No description provided.'),
            const Spacer(),
            if (drive.status == 'upcoming' || drive.status == 'ongoing')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isApplied ? null : () {
                    Navigator.pop(context);
                    _handleApply(drive.id!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isApplied ? 'Already Applied' : 'Confirm Application', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                Text(value, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStack(DateTime? date) {
    final d = date ?? DateTime.now();
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(d.day.toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(_getMonth(d.month), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
        ],
      ),
    );
  }

  String _getMonth(int m) {
    return ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][m - 1];
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'completed': color = const Color(0xFF10B981); break;
      case 'cancelled': color = const Color(0xFFEF4444); break;
      default: color = const Color(0xFF3B82F6);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), 
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No drives found', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
