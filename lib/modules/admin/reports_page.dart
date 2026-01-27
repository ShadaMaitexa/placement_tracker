import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/dashboard_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _dashboardService = DashboardService();
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'readyStudents': 0,
    'totalCompanies': 0,
    'activeDrives': 0,
    'placedStudents': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _dashboardService.getAdminStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
        appBar: AppBar(
          title: Text('Analytics & Reports', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 32),
                        _buildPlacementProgress(),
                        const SizedBox(height: 32),
                        _buildEligibilityBreakdown(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(2, tablet: 3, desktop: 4);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _statTile('Students', _stats['totalStudents'].toString(), Icons.people, Colors.blue),
            _statTile('Companies', _stats['totalCompanies'].toString(), Icons.business, Colors.green),
            _statTile('Active Drives', _stats['activeDrives'].toString(), Icons.work, Colors.orange),
            _statTile('Placed', _stats['placedStudents'].toString(), Icons.check_circle, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _statTile(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildPlacementProgress() {
    final total = _stats['totalStudents'] as int;
    final placed = _stats['placedStudents'] as int;
    final percentage = total > 0 ? (placed / total) : 0.0;

    return _buildReportSection(
      title: 'Placement Progress',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: GoogleFonts.inter(color: Colors.white70)),
              Text('${(percentage * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white10,
            color: const Color(0xFF10B981),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Text(
            '$placed out of $total students placed so far.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityBreakdown() {
    final total = _stats['totalStudents'] as int;
    final ready = _stats['readyStudents'] as int;
    final training = total - ready; // Simplified for report

    return _buildReportSection(
      title: 'Eligibility Metrics',
      child: Row(
        children: [
          Expanded(
            child: _miniBar('Ready', ready, total, const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _miniBar('Training', training, total, const Color(0xFFF59E0B)),
          ),
        ],
      ),
    );
  }

  Widget _miniBar(String label, int val, int total, Color color) {
    final ratio = total > 0 ? (val / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.white05,
                color: color,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(val.toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildReportSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
