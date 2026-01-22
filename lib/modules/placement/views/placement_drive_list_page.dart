import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Applied successfully!')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placement Drives'),
        actions: [
          if (_userRole == 'placement_officer')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPlacementDrivePage(),
                  ),
                );
                _initData(); // Refresh the list
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _drives.length,
              itemBuilder: (context, index) {
                final drive = _drives[index];
                final hasApplied = _appliedDriveIds.contains(drive.id);
                return Card(
                  child: ListTile(
                    title: Text(drive.title),
                    subtitle: Text(
                      'Role: ${drive.jobRole}\nCompany: ${drive.companyName ?? 'Unknown'}',
                    ),
                    trailing: _userRole == 'student' && !hasApplied
                        ? ElevatedButton(
                            onPressed: () => _applyToDrive(drive.id!),
                            child: Text('Apply'),
                          )
                        : hasApplied
                        ? Text('Applied')
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
