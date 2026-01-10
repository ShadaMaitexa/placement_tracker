import 'supabase_service.dart';

class StudentService {
  Future<void> fetchStudents() async {
    final response = await SupabaseService.client
        .from('students')
        .select();

    print('Students: $response');
  }
}
