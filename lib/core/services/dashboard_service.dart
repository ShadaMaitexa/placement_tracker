import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:placement_tracker/core/services/supabase_service.dart';

class DashboardService {
  final _client = SupabaseService.client;

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final totalStudents = await _client.from('students').select('*', const FetchOptions(count: CountOption.exact, head: true));
      final readyStudents = await _client.from('students').select('*', const FetchOptions(count: CountOption.exact, head: true)).eq('eligibility_status', 'ready');
      final totalCompanies = await _client.from('companies').select('*', const FetchOptions(count: CountOption.exact, head: true));
      
      // Active drives: upcoming or ongoing
      final activeDrives = await _client.from('placement_drives')
          .select('*', const FetchOptions(count: CountOption.exact, head: true))
          .or('status.eq.upcoming,status.eq.ongoing');
          
      final placedStudents = await _client.from('placement_applications')
          .select('*', const FetchOptions(count: CountOption.exact, head: true))
          .eq('status', 'selected');

      return {
        'totalStudents': totalStudents.count ?? 0,
        'readyStudents': readyStudents.count ?? 0,
        'totalCompanies': totalCompanies.count ?? 0,
        'activeDrives': activeDrives.count ?? 0,
        'placedStudents': placedStudents.count ?? 0,
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
