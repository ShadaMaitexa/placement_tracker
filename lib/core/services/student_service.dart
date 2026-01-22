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
      await _client
          .from('students')
          .update(student.toJson())
          .eq('id', student.id!);
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

  Future<Student?> getStudentByEmail(String email) async {
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch student profile: $e');
    }
  }

  Future<String?> getStudentIdByEmail(String email) async {
    try {
      final student = await getStudentByEmail(email);
      return student?.id;
    } catch (e) {
      throw Exception('Failed to fetch student ID: $e');
    }
  }

  Future<List<String>> getAppliedDriveIds(String studentId) async {
    try {
      final response = await _client
          .from('placement_applications')
          .select('drive_id')
          .eq('student_id', studentId);

      final data = response as List<dynamic>;
      return data.map((json) => json['drive_id'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch applied drive IDs: $e');
    }
  }
}
