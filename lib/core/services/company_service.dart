import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/company/models/company.dart';
import 'supabase_service.dart';

class CompanyService {
  final _client = SupabaseService.client;

  Future<List<Company>> getCompanies() async {
    try {
      final response = await _client
          .from('companies')
          .select()
          .order('company_name', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => Company.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load companies: $e');
    }
  }

  Future<void> addCompany(Company company) async {
    try {
      await _client.from('companies').insert(company.toJson());
    } catch (e) {
      throw Exception('Failed to add company: $e');
    }
  }

  Future<void> updateCompany(Company company) async {
    if (company.id == null) return;
    try {
      await _client
          .from('companies')
          .update(company.toJson())
          .eq('id', company.id!);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await _client.from('companies').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }
}
