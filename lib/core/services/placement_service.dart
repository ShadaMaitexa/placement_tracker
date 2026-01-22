import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/placement/models/placement_drive.dart';
import 'supabase_service.dart';

class PlacementDriveService {
  final _client = SupabaseService.client;

  Future<List<PlacementDrive>> getAllPlacementDrives() async {
    try {
      final response = await _client
          .from('placement_drives')
          .select('*, companies(name)')
          .order('drive_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => PlacementDrive.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load drives: $e');
    }
  }

  Future<void> addPlacementDrive(PlacementDrive drive) async {
    try {
      await _client.from('placement_drives').insert(drive.toJson());
    } catch (e) {
      throw Exception('Failed to add drive: $e');
    }
  }

  Future<void> updateDrive(PlacementDrive drive) async {
    if (drive.id == null) return;
    try {
      await _client
          .from('placement_drives')
          .update(drive.toJson())
          .eq('id', drive.id!);
    } catch (e) {
      throw Exception('Failed to update drive: $e');
    }
  }

  Future<void> applyToDrive(String driveId, String studentId) async {
    try {
      await _client.from('placement_applications').insert({
        'drive_id': driveId,
        'student_id': studentId,
        'status': 'applied',
      });
    } catch (e) {
      throw Exception('Application failed: $e');
    }
  }

  Future<List<String>> getStudentApplications(String studentId) async {
    try {
      final response = await _client
          .from('placement_applications')
          .select('drive_id')
          .eq('student_id', studentId);

      final data = response as List<dynamic>;
      return data.map((json) => json['drive_id'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch applications: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getApplicationsForStudent(
    String studentId,
  ) async {
    try {
      final response = await _client
          .from('placement_applications')
          .select('*, placement_drives(*, companies(name))')
          .eq('student_id', studentId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch detailed applications: $e');
    }
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await _client
          .from('placement_applications')
          .update({'status': status})
          .eq('id', applicationId);
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  Future<void> deleteDrive(String id) async {
    try {
      await _client.from('placement_drives').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete drive: $e');
    }
  }
}
