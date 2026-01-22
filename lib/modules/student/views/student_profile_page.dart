import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';
import 'package:placement_tracker/modules/student/views/available_placements_page.dart';

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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _student != null
          ? Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${_student!.name}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${_student!.email ?? 'Not provided'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'College: ${_student!.collegeName ?? 'Not provided'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Course: ${_student!.primaryCourse ?? 'Not provided'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvailablePlacementsPage(),
                        ),
                      );
                    },
                    child: Text('View Available Placements'),
                  ),
                ],
              ),
            )
          : Center(child: Text('No student data found.')),
    );
  }
}
