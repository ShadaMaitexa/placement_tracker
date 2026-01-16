import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/aptitude/models/aptitude_model.dart';
import 'supabase_service.dart';

class AptitudeService {
  final _client = SupabaseService.client;

  // TESTS
  Future<List<AptitudeTest>> getTests() async {
    try {
      final response = await _client
          .from('aptitude_tests')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((json) => AptitudeTest.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tests: $e');
    }
  }

  Future<void> addTest(AptitudeTest test) async {
    try {
      await _client.from('aptitude_tests').insert(test.toJson());
    } catch (e) {
      throw Exception('Failed to add test: $e');
    }
  }

  // RESULTS
  Future<List<AptitudeResult>> getResults() async {
    try {
      final response = await _client
          .from('aptitude_results')
          .select('*, students(name), aptitude_tests(title)')
          .order('created_at', ascending: false);
      return (response as List).map((json) => AptitudeResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load results: $e');
    }
  }

  Future<void> addResult(AptitudeResult result) async {
    try {
      await _client.from('aptitude_results').insert(result.toJson());
    } catch (e) {
      throw Exception('Failed to add result: $e');
    }
  }
}
