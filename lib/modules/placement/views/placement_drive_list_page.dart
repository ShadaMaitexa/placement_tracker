import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Placement Drives', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlacementDrivePage()));
          if (res == true) _loadDrives();
        },
        backgroundColor: const Color(0xFF3B82F6),
        label: Text('New Drive', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drives.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDrives,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _drives.length,
                    itemBuilder: (context, index) {
                      final drive = _drives[index];
                      return _buildDriveCard(drive);
                    },
                  ),
                ),
    );
  }

  Widget _buildDriveCard(PlacementDrive drive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Future: Navigate to Drive Details for candidate tracking
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddPlacementDrivePage(drive: drive)),
            );
            if (res == true) _loadDrives();
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
                    children: [
                      Text(drive.jobRole, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17)),
                      Text(drive.companyName ?? 'Unknown Company', 
                        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                      const SizedBox(height: 8),
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
                _buildStatusChip(drive.status),
              ],
            ),
          ),
        ),
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
