import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/company_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/company/models/company.dart';
import 'add_company_page.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({super.key});

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  final _companyService = CompanyService();
  List<Company> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final data = await _companyService.getAllCompanies();
      setState(() {
        _companies = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Company Database',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCompanyPage()),
          );
          if (res == true) _loadCompanies();
        },
        backgroundColor: const Color(0xFF10B981),
        label: Text(
          'Add Company',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _companies.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0)),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: context.responsive(2.2, tablet: 2.0, desktop: 1.8),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCompanyCard(_companies[index]),
                          childCount: _companies.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
        ),
      ),
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCompanyPage(company: company)),
            );
            if (res == true) _loadCompanies();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            company.location ?? 'Global',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text(
                      company.hrName ?? "No HR Contact",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                if (company.hiringRoles != null && company.hiringRoles!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: company.hiringRoles!
                        .take(3)
                        .map(
                          (role) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'No companies registered',
            style: GoogleFonts.outfit(fontSize: 18, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

