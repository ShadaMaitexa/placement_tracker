import 'package:flutter/material.dart';
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
      appBar: AppBar(title: Text(widget.drive == null ? 'Add Drive' : 'Edit Drive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCompanyId,
                items: _companies.map((c) => DropdownMenuItem(
                  value: c.id, 
                  child: Text(c.companyName),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCompanyId = v),
                decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              _textField(_roleCtrl, 'Job Role'),
              _textField(_descCtrl, 'Description', maxLines: 3),
              _textField(_salaryCtrl, 'Salary Package (e.g 5 LPA)'),

              ListTile(
                title: Text(_driveDate == null 
                  ? 'Select Drive Date' 
                  : 'Date: ${_driveDate!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _driveDate = d);
                },
              ),

              DropdownButtonFormField<String>(
                value: _status,
                items: ['scheduled', 'completed', 'cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),

              const SizedBox(height: 24),
               _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveDrive,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Drive'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: (v) => label == 'Job Role' && (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
