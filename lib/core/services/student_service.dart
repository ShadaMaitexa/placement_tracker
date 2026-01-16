import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/student/models/student_model.dart';
import 'supabase_service.dart';

class StudentService {
  final _client = SupabaseService.client;

  // Fetch all students (Day 9)
  Future<List<Student>> getStudents() async {
    try {
      final response = await _client
          .from('students')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  // Add a new student (Day 8)
  Future<void> addStudent(Student student) async {
    try {
      await _client.from('students').insert(student.toJson());
    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  // Update student (Day 11)
  Future<void> updateStudent(Student student) async {
    if (student.id == null) return;
    try {
      await _client.from('students').update(student.toJson()).eq('id', student.id!);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete student (Day 11 - Pre-emptive)
  Future<void> deleteStudent(String id) async {
     try {
      await _client.from('students').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }
}
