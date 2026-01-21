import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';
import 'add_student_page.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;
  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                    _infoRow(Icons.school_outlined, 'College', student.collegeName ?? 'Not Specified'),
                    _infoRow(Icons.history_edu_outlined, 'Qualification', student.qualification ?? 'Not Specified'),
                    _infoRow(Icons.calendar_today_outlined, 'Passing Year', student.passingYear?.toString() ?? 'N/A'),
                    _infoRow(Icons.group_outlined, 'Batch', student.batch ?? 'N/A'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Course Enrollment'),
                  _buildInfoCard([
                    _infoRow(Icons.book_outlined, 'Primary Course', student.primaryCourse ?? 'Not Specified'),
                    _infoRow(Icons.timer_outlined, 'Duration', student.courseDuration?.replaceAll('_', ' ') ?? 'N/A'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills & Assets'),
                  _buildSkillsCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact Information'),
                  _buildInfoCard([
                    _infoRow(Icons.email_outlined, 'Email', student.email ?? 'No email'),
                    _infoRow(Icons.phone_outlined, 'Phone', student.phone ?? 'No phone'),
                    if (student.resumeUrl != null && student.resumeUrl!.isNotEmpty)
                      _infoRow(Icons.link_outlined, 'Resume URL', 'View Document', isLink: true, url: student.resumeUrl),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
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
                  student.name[0].toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                student.name,
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _buildStatusBadge(student.eligibilityStatus),
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
              MaterialPageRoute(builder: (_) => AddStudentPage(student: student)),
            );
            if (result == true) {
              Navigator.pop(context, true);
            }
          },
        ),
      ],
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
        _statBox('Performance', '92%', Icons.trending_up, Colors.blue),
        const SizedBox(width: 12),
        _statBox('Attendance', '88%', Icons.calendar_today, Colors.orange),
      ],
    );
  }

  Widget _statBox(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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
      child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
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
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: isLink ? const Color(0xFF3B82F6) : const Color(0xFF0F172A)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = student.skills ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: skills.isEmpty 
        ? Text('No skills listed', style: GoogleFonts.inter(color: Colors.grey))
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
