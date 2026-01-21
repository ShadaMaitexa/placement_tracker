import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/mock/models/mock_interview.dart';
import 'supabase_service.dart';

class MockInterviewService {
  final _client = SupabaseService.client;

  Future<List<MockInterview>> getInterviews() async {
    try {
      final response = await _client
          .from('mock_interviews')
          .select('*, students(name)')
          .order('conducted_at', ascending: false);
      return (response as List).map((json) => MockInterview.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load interviews: $e');
    }
  }

  Future<List<MockInterview>> getInterviewsForStudent(String studentId) async {
    try {
      final response = await _client
          .from('mock_interviews')
          .select('*, students(name)')
          .eq('student_id', studentId)
          .order('conducted_at', ascending: false);
      return (response as List).map((json) => MockInterview.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load student interviews: $e');
    }
  }

  Future<void> addInterview(MockInterview interview) async {
    try {
      await _client.from('mock_interviews').insert(interview.toJson());
    } catch (e) {
      throw Exception('Failed to add interview: $e');
    }
  }
}
