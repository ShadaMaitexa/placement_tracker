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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newDrive = PlacementDrive(
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
        await _placementService.addPlacementDrive(newDrive);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Placement Drive')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    TextFormField(
                      controller: _roleCtrl,
                      decoration: InputDecoration(labelText: 'Job Role'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a job role' : null,
                    ),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    TextFormField(
                      controller: _salaryCtrl,
                      decoration: InputDecoration(labelText: 'Salary Package'),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter a salary package'
                          : null,
                    ),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(labelText: 'Location'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a location' : null,
                    ),
                    TextFormField(
                      controller: _eligibilityCtrl,
                      decoration: InputDecoration(
                        labelText: 'Eligibility Criteria',
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter eligibility criteria'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCompanyId,
                      decoration: InputDecoration(labelText: 'Select Company'),
                      items: _companies.map((company) {
                        return DropdownMenuItem<String>(
                          value: company.id,
                          child: Text(company.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCompanyId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a company' : null,
                    ),
                    ElevatedButton(onPressed: _submit, child: Text('Submit')),
                  ],
                ),
              ),
            ),
    );
  }
}
