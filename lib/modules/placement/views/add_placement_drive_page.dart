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

  late TextEditingController _roleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _salaryCtrl;
  String? _selectedCompanyId;
  DateTime? _driveDate;
  String _status = 'scheduled';

  List<Company> _companies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roleCtrl = TextEditingController(text: widget.drive?.jobRole);
    _descCtrl = TextEditingController(text: widget.drive?.description);
    _salaryCtrl = TextEditingController(text: widget.drive?.salaryPackage);
    _selectedCompanyId = widget.drive?.companyId;
    _driveDate = widget.drive?.driveDate;
    if (widget.drive != null) _status = widget.drive!.status;
    
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      final data = await _companyService.getCompanies();
      setState(() => _companies = data);
    } catch (e) {
      // safe fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.drive == null ? 'Schedule Drive' : 'Edit Drive', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('General Details'),
                const SizedBox(height: 16),
                _buildCard([
                  DropdownButtonFormField<String>(
                    value: _selectedCompanyId,
                    items: _companies.map((c) => DropdownMenuItem(
                      value: c.id, 
                      child: Text(c.name, style: GoogleFonts.inter()),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCompanyId = v),
                    decoration: InputDecoration(
                      labelText: 'Select Company',
                      prefixIcon: const Icon(Icons.business, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _textField(_roleCtrl, 'Job Role / Designation', Icons.work_outline),
                  _textField(_salaryCtrl, 'Salary Package (e.g. 8.5 LPA)', Icons.payments_outlined),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('Schedule & Description'),
                const SizedBox(height: 16),
                _buildCard([
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setState(() => _driveDate = d);
                    },
                    leading: const Icon(Icons.calendar_month, color: Color(0xFF3B82F6)),
                    title: Text('Drive Date', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                    subtitle: Text(
                      _driveDate == null ? 'Select Date' : '${_driveDate!.day}/${_driveDate!.month}/${_driveDate!.year}',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                  ),
                  const Divider(),
                  _textField(_descCtrl, 'Job Description', Icons.description_outlined, maxLines: 4),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('Current Status'),
                const SizedBox(height: 16),
                _buildCard([
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: ['scheduled', 'completed', 'cancelled']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                    decoration: InputDecoration(
                      labelText: 'Drive Status',
                      prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveDrive,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Save Placement Drive', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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

  Widget _textField(TextEditingController c, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) => label.contains('Role') && (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
        ),
      ),
    );
  }

  Future<void> _saveDrive() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final drive = PlacementDrive(
        id: widget.drive?.id,
        companyId: _selectedCompanyId!,
        jobRole: _roleCtrl.text,
        description: _descCtrl.text,
        salaryPackage: _salaryCtrl.text,
        driveDate: _driveDate,
        status: _status,
      );

      if (widget.drive == null) {
        await _placementService.addDrive(drive);
      } else {
        await _placementService.updateDrive(drive);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
