import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:placement_tracker/core/services/supabase_service.dart';

class DashboardService {
  final _client = SupabaseService.client;

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Fetch counts in parallel
      final results = await Future.wait([
        _client.from('students').count(CountOption.exact),
        _client.from('students').count(CountOption.exact).eq('eligibility_status', 'ready'),
        _client.from('companies').count(CountOption.exact),
        _client.from('placement_drives').count(CountOption.exact).eq('status', 'upcoming'),
        _client.from('placement_applications').count(CountOption.exact).eq('status', 'selected'),
      ]);

      return {
        'totalStudents': results[0],
        'readyStudents': results[1],
        'totalCompanies': results[2],
        'activeDrives': results[3],
        'placedStudents': results[4],
      };
    } catch (e) {
      print('Error fetching admin stats: $e');
      return {
        'totalStudents': 0,
        'readyStudents': 0,
        'totalCompanies': 0,
        'activeDrives': 0,
        'placedStudents': 0,
      };
    }
  }
}
