import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';
import 'add_student_page.dart';

class StudentDetailPage extends StatefulWidget {
  final Student student;
  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final _placementService = PlacementDriveService();
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final apps = await _placementService.getApplicationsForStudent(widget.student.id!);
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _updateStatus(String appId, String newStatus) async {
    try {
      await _placementService.updateApplicationStatus(appId, newStatus);
      _loadApplications();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Academic Profile'),
                  _buildInfoCard([
                    _infoRow(Icons.school_outlined, 'College', widget.student.collegeName ?? 'Not Specified'),
                    _infoRow(Icons.history_edu_outlined, 'Qualification', widget.student.qualification ?? 'Not Specified'),
                    _infoRow(Icons.calendar_today_outlined, 'Passing Year', widget.student.passingYear?.toString() ?? 'N/A'),
                    _infoRow(Icons.group_outlined, 'Batch', widget.student.batch ?? 'N/A'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Placement Applications'),
                  _isLoading 
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      : _buildApplicationsList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Course Enrollment'),
                  _buildInfoCard([
                    _infoRow(Icons.book_outlined, 'Primary Course', widget.student.primaryCourse ?? 'Not Specified'),
                    _infoRow(Icons.timer_outlined, 'Duration', widget.student.courseDuration?.replaceAll('_', ' ') ?? 'N/A'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills & Assets'),
                  _buildSkillsCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact Information'),
                  _buildInfoCard([
                    _infoRow(Icons.email_outlined, 'Email', widget.student.email ?? 'No email'),
                    _infoRow(Icons.phone_outlined, 'Phone', widget.student.phone ?? 'No phone'),
                    if (widget.student.resumeUrl != null && widget.student.resumeUrl!.isNotEmpty)
                      _infoRow(Icons.link_outlined, 'Resume URL', 'View Document', isLink: true, url: widget.student.resumeUrl),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.student.name[0].toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.student.name,
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _buildStatusBadge(widget.student.eligibilityStatus),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddStudentPage(student: widget.student)),
            );
            if (result == true) {
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildApplicationsList() {
    if (_applications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(child: Text('No applications found', style: GoogleFonts.inter(color: Colors.white60))),
      );
    }

    return Column(
      children: _applications.map((app) {
        final drive = app['placement_drives'];
        final company = drive['companies'];
        final status = app['status'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            title: Text(drive['job_role'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(company['name'], style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            trailing: PopupMenuButton<String>(
              child: _buildStatusTag(status),
              onSelected: (val) => _updateStatus(app['id'], val),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'applied', child: Text('Applied')),
                const PopupMenuItem(value: 'shortlisted', child: Text('Shortlisted')),
                const PopupMenuItem(value: 'interviewed', child: Text('Interviewed')),
                const PopupMenuItem(value: 'selected', child: Text('Selected')),
                const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusTag(String? status) {
    Color color;
    switch (status) {
      case 'selected': color = const Color(0xFF10B981); break;
      case 'rejected': color = const Color(0xFFEF4444); break;
      case 'shortlisted': color = const Color(0xFF3B82F6); break;
      default: color = const Color(0xFFF59E0B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status?.toUpperCase() ?? 'APPLIED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color = const Color(0xFF10B981); // Default Ready
    if (status == 'training') color = const Color(0xFFF59E0B);
    if (status == 'not_eligible') color = const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status?.toUpperCase().replaceAll('_', ' ') ?? 'UNKNOWN',
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statBox('Applications', _applications.length.toString(), Icons.send, Colors.blue),
        const SizedBox(width: 12),
        _statBox('Status', _applications.any((a) => a['status'] == 'selected') ? 'Placed' : 'Searching', Icons.work_outline, Colors.orange),
      ],
    );
  }

  Widget _statBox(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isLink = false, String? url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: isLink ? const Color(0xFF3B82F6) : Colors.white
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = widget.student.skills ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: skills.isEmpty 
        ? Text('No skills listed', style: GoogleFonts.inter(color: Colors.white60))
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(s, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
            )).toList(),
          ),
    );
  }
}
