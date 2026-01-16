import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/company_service.dart';
import 'package:placement_tracker/modules/company/models/company.dart';

class AddCompanyPage extends StatefulWidget {
  final Company? company; // If provided, edit mode

  const AddCompanyPage({super.key, this.company});

  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();

  late TextEditingController _nameCtrl;
  late TextEditingController _hrCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _linkedinCtrl;
  DateTime? _lastContacted;
  DateTime? _followUpDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.company?.companyName);
    _hrCtrl = TextEditingController(text: widget.company?.hrName);
    _phoneCtrl = TextEditingController(text: widget.company?.phone);
    _emailCtrl = TextEditingController(text: widget.company?.email);
    _linkedinCtrl = TextEditingController(text: widget.company?.linkedin);
    _lastContacted = widget.company?.lastContacted;
    _followUpDate = widget.company?.followUpDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company == null ? 'Add Company' : 'Edit Company'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(_nameCtrl, 'Company Name'),
              _textField(_hrCtrl, 'HR Name'),
              _textField(_phoneCtrl, 'Phone', keyboard: TextInputType.phone),
              _textField(_emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
              _textField(_linkedinCtrl, 'LinkedIn URL'),
              
              const SizedBox(height: 12),
              ListTile(
                title: Text(_lastContacted == null 
                  ? 'Select Last Contacted Date' 
                  : 'Last Contactd: ${_formatDate(_lastContacted!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _lastContacted = date);
                },
              ),
              
              ListTile(
                title: Text(_followUpDate == null 
                  ? 'Select Follow Up Date' 
                  : 'Follow Up: ${_formatDate(_followUpDate!)}'),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _followUpDate = date);
                },
              ),

              const SizedBox(height: 24),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveCompany,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Company'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String label, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: (v) => label == 'Company Name' && (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newCompany = Company(
        id: widget.company?.id,
        companyName: _nameCtrl.text,
        hrName: _hrCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        linkedin: _linkedinCtrl.text,
        lastContacted: _lastContacted,
        followUpDate: _followUpDate,
      );

      if (widget.company == null) {
        await _companyService.addCompany(newCompany);
      } else {
        await _companyService.updateCompany(newCompany);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company saved successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
