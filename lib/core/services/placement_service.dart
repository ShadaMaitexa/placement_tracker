import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/placement/models/placement_drive.dart';
import 'supabase_service.dart';

class PlacementDriveService {
  final _client = SupabaseService.client;

  Future<List<PlacementDrive>> getDrives() async {
    try {
      final response = await _client
          .from('placement_drives')
          .select('*, companies(company_name)')
          .order('drive_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => PlacementDrive.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load drives: $e');
    }
  }

  Future<void> addDrive(PlacementDrive drive) async {
    try {
      await _client.from('placement_drives').insert(drive.toJson());
    } catch (e) {
      throw Exception('Failed to add drive: $e');
    }
  }

  Future<void> updateDrive(PlacementDrive drive) async {
    if (drive.id == null) return;
    try {
      await _client.from('placement_drives').update(drive.toJson()).eq('id', drive.id!);
    } catch (e) {
      throw Exception('Failed to update drive: $e');
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
