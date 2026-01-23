import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/company_service.dart';
import 'package:placement_tracker/core/services/placement_service.dart';
import 'package:placement_tracker/modules/company/models/company.dart';
import 'package:placement_tracker/modules/placement/models/placement_drive.dart';

class AddPlacementDrivePage extends StatefulWidget {
  final PlacementDrive? drive;
  const AddPlacementDrivePage({super.key, this.drive});

  @override
  State<AddPlacementDrivePage> createState() => _AddPlacementDrivePageState();
}

class _AddPlacementDrivePageState extends State<AddPlacementDrivePage> {
  final _formKey = GlobalKey<FormState>();
  final _placementService = PlacementDriveService();
  final _companyService = CompanyService();

  late TextEditingController _titleCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _eligibilityCtrl;

  String? _selectedCompanyId;
  DateTime? _driveDate;
  DateTime? _deadlineDate;
  String _status = 'upcoming';

  List<Company> _companies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.drive?.title);
    _roleCtrl = TextEditingController(text: widget.drive?.jobRole);
    _descCtrl = TextEditingController(text: widget.drive?.description);
    _salaryCtrl = TextEditingController(text: widget.drive?.salaryPackage);
    _locationCtrl = TextEditingController(text: widget.drive?.location);
    _eligibilityCtrl = TextEditingController(
      text: widget.drive?.eligibilityCriteria,
    );

    _selectedCompanyId = widget.drive?.companyId;
    _driveDate = widget.drive?.driveDate;
    _deadlineDate = widget.drive?.applicationDeadline;
    if (widget.drive != null) _status = widget.drive!.status;

    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      _companies = await _companyService.getAllCompanies();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _roleCtrl.dispose();
    _descCtrl.dispose();
    _salaryCtrl.dispose();
    _locationCtrl.dispose();
    _eligibilityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_driveDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a drive date')));
      return;
    }
    
    if (_deadlineDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an application deadline')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newDrive = PlacementDrive(
        id: widget.drive?.id,
        title: _titleCtrl.text,
        jobRole: _roleCtrl.text,
        description: _descCtrl.text,
        salaryPackage: _salaryCtrl.text,
        location: _locationCtrl.text,
        eligibilityCriteria: _eligibilityCtrl.text,
        companyId: _selectedCompanyId!,
        driveDate: _driveDate,
        applicationDeadline: _deadlineDate,
        status: _status,
      );
      
      if (widget.drive == null) {
        await _placementService.addPlacementDrive(newDrive);
      } else {
        await _placementService.updatePlacementDrive(newDrive); 
      }
      
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.drive == null ? 'Add Placement Drive' : 'Edit Drive', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Drive Details'),
                    const SizedBox(height: 16),
                    _buildCard([
                       _buildCompanyDropdown(),
                       _buildTextField(_titleCtrl, 'Drive Title', Icons.title, validator: (v) => v!.isEmpty ? 'Required' : null),
                       _buildTextField(_roleCtrl, 'Job Role', Icons.work_outline, validator: (v) => v!.isEmpty ? 'Required' : null),
                       _buildTextField(_salaryCtrl, 'Salary Package (CTC)', Icons.currency_rupee, validator: (v) => v!.isEmpty ? 'Required' : null),
                       _buildTextField(_locationCtrl, 'Job Location', Icons.location_on_outlined, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Process & Dates'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildDatePicker('Drive Date', _driveDate, (d) => setState(() => _driveDate = d)),
                      const Divider(height: 1),
                      _buildDatePicker('Application Deadline', _deadlineDate, (d) => setState(() => _deadlineDate = d)),
                      const Divider(height: 1),
                      _buildTextField(_eligibilityCtrl, 'Eligibility Criteria', Icons.check_circle_outline, maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
                       _buildTextField(_descCtrl, 'Description', Icons.description_outlined, maxLines: 5, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit, 
                        style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF3B82F6),
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Save Placement Drive', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedCompanyId,
        decoration: InputDecoration(
          labelText: 'Select Company',
          labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
          prefixIcon: const Icon(Icons.business, color: Color(0xFF64748B)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _companies.map((company) {
          return DropdownMenuItem<String>(
            value: company.id,
            child: Text(company.name, style: GoogleFonts.inter(color: const Color(0xFF0F172A))),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCompanyId = value),
        validator: (value) => value == null ? 'Please select a company' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, ValueChanged<DateTime?> onDateSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Color(0xFF64748B)),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
      subtitle: Text(
        date == null ? 'Select Date' : '${date.day}/${date.month}/${date.year}',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (picked != null) onDateSelected(picked);
      },
    );
  }
}
