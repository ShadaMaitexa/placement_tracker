import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/company_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/company/models/company.dart';

class AddCompanyPage extends StatefulWidget {
  final Company? company;

  const AddCompanyPage({super.key, this.company});

  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();

  late TextEditingController _nameCtrl;
  late TextEditingController _hrCtrl;
  late TextEditingController _hrDesignationCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _roleCtrl;
  DateTime? _lastContacted;
  DateTime? _followUpDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameCtrl = TextEditingController(text: c?.name);
    _hrCtrl = TextEditingController(text: c?.hrName);
    _hrDesignationCtrl = TextEditingController(text: c?.hrDesignation);
    _phoneCtrl = TextEditingController(text: c?.phone);
    _emailCtrl = TextEditingController(text: c?.email);
    _linkedinCtrl = TextEditingController(text: c?.linkedin);
    _roleCtrl = TextEditingController(text: c?.hiringRoles?.join(', '));
    _lastContacted = c?.lastContactedDate;
    _followUpDate = c?.followUpReminder;
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
          title: Text(widget.company == null ? 'Add Company' : 'Edit Company', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsive(20.0, tablet: 40.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Company Information'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _textField(
                        _nameCtrl, 
                        'Company Name', 
                        Icons.business, 
                        validator: (v) => v == null || v.isEmpty ? 'Company Name is required' : null
                      ),
                      _textField(_roleCtrl, 'Hiring Roles (comma separated)', Icons.work_outline),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('HR Contact Details'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _textField(_hrCtrl, 'HR Manager Name', Icons.person_outline),
                      _textField(_hrDesignationCtrl, 'HR Designation', Icons.badge_outlined),
                      _textField(
                        _emailCtrl, 
                        'HR Email', 
                        Icons.email_outlined, 
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                            return 'Invalid email address';
                          }
                          return null;
                        }
                      ),
                      _textField(
                        _phoneCtrl, 
                        'HR Phone', 
                        Icons.phone_outlined, 
                        keyboard: TextInputType.phone,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 10) {
                            return 'Phone number too short';
                          }
                          return null;
                        }
                      ),
                      _textField(_linkedinCtrl, 'LinkedIn Profile URL', Icons.link_outlined),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Relationship Tracking'),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildDatePickerTile(
                        'Last Contacted', 
                        _lastContacted, 
                        Icons.history, 
                        () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (d != null) setState(() => _lastContacted = d);
                        }
                      ),
                      const Divider(color: Colors.white10),
                      _buildDatePickerTile(
                        'Follow-up Reminder', 
                        _followUpDate, 
                        Icons.notifications_active_outlined, 
                        () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                          if (d != null) setState(() => _followUpDate = d);
                        },
                        isPriority: true,
                      ),
                    ]),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCompany,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                          : Text('Save Company Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDatePickerTile(String label, DateTime? date, IconData icon, VoidCallback onTap, {bool isPriority = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isPriority ? Colors.amber : Colors.blue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isPriority ? Colors.amber : Colors.blue, size: 20),
      ),
      title: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
      subtitle: Text(
        date == null ? 'Not set' : '${date.day}/${date.month}/${date.year}',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      trailing: const Icon(Icons.calendar_today, color: Colors.white60, size: 18),
      onTap: onTap,
    );
  }

  Widget _textField(
    TextEditingController c, 
    String label, 
    IconData icon, 
    {TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator ?? ((v) => (label == 'Company Name' && (v == null || v.isEmpty)) ? 'Required' : null),
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60, size: 20),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newCompany = Company(
        id: widget.company?.id,
        name: _nameCtrl.text,
        hrName: _hrCtrl.text,
        hrDesignation: _hrDesignationCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        linkedin: _linkedinCtrl.text,
        hiringRoles: _roleCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        lastContactedDate: _lastContacted,
        followUpReminder: _followUpDate,
      );

      if (widget.company == null) {
        await _companyService.addCompany(newCompany);
      } else {
        await _companyService.updateCompany(newCompany);
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

