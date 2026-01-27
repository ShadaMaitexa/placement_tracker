import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AddStudentPage extends StatefulWidget {
  final Student? student;
  const AddStudentPage({super.key, this.student});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentService = StudentService();

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController collegeCtrl;
  late TextEditingController qualificationCtrl;
  late TextEditingController passingYearCtrl;
  late TextEditingController batchCtrl;
  late TextEditingController primaryCourseCtrl;
  late TextEditingController skillsCtrl;
  late TextEditingController resumeUrlCtrl;

  String courseDuration = '3_months';
  String eligibilityStatus = 'training';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    nameCtrl = TextEditingController(text: s?.name);
    phoneCtrl = TextEditingController(text: s?.phone);
    emailCtrl = TextEditingController(text: s?.email);
    collegeCtrl = TextEditingController(text: s?.collegeName);
    qualificationCtrl = TextEditingController(text: s?.qualification);
    passingYearCtrl = TextEditingController(text: s?.passingYear?.toString());
    batchCtrl = TextEditingController(text: s?.batch);
    primaryCourseCtrl = TextEditingController(text: s?.primaryCourse);
    skillsCtrl = TextEditingController(text: s?.skills?.join(', '));
    resumeUrlCtrl = TextEditingController(text: s?.resumeUrl);
    
    if (s?.courseDuration != null) courseDuration = s!.courseDuration!;
    if (s?.eligibilityStatus != null) eligibilityStatus = s!.eligibilityStatus!;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    collegeCtrl.dispose();
    qualificationCtrl.dispose();
    passingYearCtrl.dispose();
    batchCtrl.dispose();
    primaryCourseCtrl.dispose();
    skillsCtrl.dispose();
    resumeUrlCtrl.dispose();
    super.dispose();
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
          title: Text(widget.student == null ? 'Add Student' : 'Edit Student', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsive(20.0, tablet: 40.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal & Academic Details'),
                    const SizedBox(height: 16),
                    _buildSectionCard([
                       _textField(nameCtrl, 'Full Name', Icons.person_outline),
                       _textField(
                         emailCtrl, 
                         'Email Address', 
                         Icons.email_outlined, 
                         keyboard: TextInputType.emailAddress,
                         validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
                            return null;
                         }
                       ),
                       _textField(
                         phoneCtrl, 
                         'Phone Number', 
                         Icons.phone_outlined, 
                         keyboard: TextInputType.phone,
                         validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 10) return 'Enter valid phone number';
                            return null;
                         }
                       ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('College & Course Details'),
                    const SizedBox(height: 16),
                    _buildSectionCard([
                       _textField(collegeCtrl, 'College Name', Icons.school_outlined),
                       _textField(qualificationCtrl, 'Qualification', Icons.history_edu_outlined),
                       Row(
                         children: [
                           Expanded(child: _textField(
                             passingYearCtrl, 
                             'Passing Year', 
                             Icons.calendar_today_outlined, 
                             keyboard: TextInputType.number,
                             validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                final year = int.tryParse(v);
                                if (year == null || year < 1900 || year > 2100) return 'Invalid year';
                                return null;
                             }
                           )),
                           const SizedBox(width: 12),
                           Expanded(child: _textField(batchCtrl, 'Batch (e.g. 2024)', Icons.group_outlined)),
                         ],
                       ),
                       _textField(primaryCourseCtrl, 'Primary Course', Icons.book_outlined),
                    ]),

                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Course Duration',
                      value: courseDuration,
                      icon: Icons.timer_outlined,
                      items: [
                        {'value': '1_month', 'label': '1 Month'},
                        {'value': '3_months', 'label': '3 Months'},
                        {'value': '6_months', 'label': '6 Months'},
                        {'value': '9_months', 'label': '9 Months'},
                      ],
                      onChanged: (v) => setState(() => courseDuration = v!),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Skills & Placement Status'),
                    const SizedBox(height: 16),
                    _buildSectionCard([
                       _textField(skillsCtrl, 'Skills (comma separated)', Icons.bolt_outlined),
                       _textField(resumeUrlCtrl, 'Resume Link (Google Drive/PDF)', Icons.link_outlined),
                    ]),

                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Eligibility Status',
                      value: eligibilityStatus,
                      icon: Icons.check_circle_outline,
                      items: [
                        {'value': 'training', 'label': 'Needs Training'},
                        {'value': 'ready', 'label': 'Ready for Placement'},
                        {'value': 'not_eligible', 'label': 'Not Eligible'},
                      ],
                      onChanged: (v) => setState(() => eligibilityStatus = v!),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
                          : Text(widget.student == null ? 'Save Student Profile' : 'Update Profile', 
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF1E293B),
        items: items.map((item) => DropdownMenuItem(
          value: item['value'], 
          child: Text(item['label']!, style: GoogleFonts.inter(color: Colors.white))
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.blue, size: 20),
          border: InputBorder.none,
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.02),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final student = Student(
        id: widget.student?.id,
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
        collegeName: collegeCtrl.text,
        qualification: qualificationCtrl.text,
        passingYear: int.tryParse(passingYearCtrl.text),
        batch: batchCtrl.text,
        primaryCourse: primaryCourseCtrl.text,
        courseDuration: courseDuration,
        skills: skillsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        resumeUrl: resumeUrlCtrl.text,
        eligibilityStatus: eligibilityStatus,
      );

      if (widget.student == null) {
        await _studentService.addStudent(student);
      } else {
        await _studentService.updateStudent(student);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student profile saved successfully!', style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); 
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

