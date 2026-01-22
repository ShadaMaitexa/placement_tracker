import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/modules/placement/models/placement_drive.dart';

class AvailablePlacementsPage extends StatefulWidget {
  const AvailablePlacementsPage({super.key});

  @override
  State<AvailablePlacementsPage> createState() =>
      _AvailablePlacementsPageState();
}

class _AvailablePlacementsPageState extends State<AvailablePlacementsPage> {
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
      _drives = await _placementService.getAllPlacementDrives();
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
      appBar: AppBar(title: Text('Available Placements')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _drives.length,
              itemBuilder: (context, index) {
                final drive = _drives[index];
                return Card(
                  child: ListTile(
                    title: Text(drive.title),
                    subtitle: Text(
                      'Role: ${drive.jobRole}\nCompany: ${drive.companyName ?? 'Unknown'}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement apply functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Apply functionality coming soon!'),
                          ),
                        );
                      },
                      child: Text('Apply'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
