import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/modules/placement/views/placement_drive_list_page.dart';
import 'package:placement_tracker/modules/aptitude/views/aptitude_list_page.dart';
import 'package:placement_tracker/modules/aptitude/views/aptitude_result_page.dart';
import '../auth/login_page.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            const Text(
              'Placement Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              title: 'Placement Drives',
              subtitle: 'View and Apply',
              icon: Icons.work,
              color: Colors.blue,
              onTap: () {
                // For now, reuse the list page (it has add button, but RLS will block students from adding)
                // Ideally we make a StudentDriveListPage.
                // For MVP, RLS protects data.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlacementDriveListPage(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'My Aptitude Results',
              subtitle: 'Check scores',
              icon: Icons.quiz,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AptitudeResultListPage(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'Mock Interview Feedback',
              subtitle: 'View mentor feedback',
              icon: Icons.mic,
              color: Colors.purple,
              onTap: () {
                // Need Student view of feedback
                // For MVP, just reusing list page (RLS protects write)
                // Ideally create specific view
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            const Text(
              'Welcome, Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ready for Placement',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
