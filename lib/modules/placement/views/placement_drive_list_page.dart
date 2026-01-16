import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/modules/placement/models/placement_drive.dart';
import 'add_placement_drive_page.dart';

class PlacementDriveListPage extends StatefulWidget {
  const PlacementDriveListPage({super.key});

  @override
  State<PlacementDriveListPage> createState() => _PlacementDriveListPageState();
}

class _PlacementDriveListPageState extends State<PlacementDriveListPage> {
  final _placementService = PlacementDriveService();
  List<PlacementDrive> _drives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrives();
  }

  Future<void> _loadDrives() async {
    setState(() => _isLoading = true);
    try {
      final data = await _placementService.getDrives();
      setState(() {
        _drives = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placement Drives')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlacementDrivePage()),
          );
          if (res == true) _loadDrives();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drives.isEmpty
              ? const Center(child: Text('No drives scheduled'))
              : ListView.builder(
                  itemCount: _drives.length,
                  itemBuilder: (context, index) {
                    final drive = _drives[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(drive.status),
                          child: const Icon(Icons.work, color: Colors.white),
                        ),
                        title: Text(drive.jobRole),
                        subtitle: Text('${drive.companyName ?? "Unknown Company"} • ${drive.driveDate.toString().split(" ")[0]}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                           final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddPlacementDrivePage(drive: drive)),
                          );
                          if (res == true) _loadDrives();
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.blue;
    }
  }
}
