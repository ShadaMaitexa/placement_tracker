import 'package:flutter/material.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';
import 'add_student_page.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;
  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStudentPage(student: student)),
              );
              if (result == true) {
                Navigator.pop(context, true); // Return true to refresh list
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(student.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(student.email ?? 'No Email', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            _buildSection('Academic Info', [
              _infoRow('Qualification', student.qualification ?? '-'),
              _infoRow('Passing Year', student.passingYear?.toString() ?? '-'),
              _infoRow('Primary Course', student.primaryCourse ?? '-'),
              _infoRow('Duration', student.courseDuration?.replaceAll('_', ' ') ?? '-'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Placement Status', [
              _infoRow('Eligibility', student.eligibilityStatus?.toUpperCase() ?? '-'),
              _infoRow('Phone', student.phone ?? '-'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
