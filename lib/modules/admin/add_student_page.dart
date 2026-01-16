import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/student_service.dart';
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
  late TextEditingController qualificationCtrl;
  late TextEditingController passingYearCtrl;
  late TextEditingController primaryCourseCtrl;

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
    qualificationCtrl = TextEditingController(text: s?.qualification);
    passingYearCtrl = TextEditingController(text: s?.passingYear?.toString());
    primaryCourseCtrl = TextEditingController(text: s?.primaryCourse);
    
    if (s?.courseDuration != null) courseDuration = s!.courseDuration!;
    if (s?.eligibilityStatus != null) eligibilityStatus = s!.eligibilityStatus!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student == null ? 'Add Student' : 'Edit Student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(nameCtrl, 'Name'),
              _textField(phoneCtrl, 'Phone', keyboard: TextInputType.phone),
              _textField(emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
              _textField(qualificationCtrl, 'Qualification'),
              _textField(passingYearCtrl, 'Passing Year', keyboard: TextInputType.number),
              _textField(primaryCourseCtrl, 'Primary Course'),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: courseDuration,
                items: const [
                  DropdownMenuItem(value: '1_month', child: Text('1 Month')),
                  DropdownMenuItem(value: '3_months', child: Text('3 Months')),
                  DropdownMenuItem(value: '6_months', child: Text('6 Months')),
                  DropdownMenuItem(value: '9_months', child: Text('9 Months')),
                ],
                onChanged: (v) => setState(() => courseDuration = v!),
                decoration: const InputDecoration(labelText: 'Course Duration'),
              ),

              DropdownButtonFormField<String>(
                value: eligibilityStatus,
                items: const [
                  DropdownMenuItem(value: 'training', child: Text('Needs Training')),
                  DropdownMenuItem(value: 'ready', child: Text('Ready for Placement')),
                  DropdownMenuItem(value: 'not_eligible', child: Text('Not Eligible')),
                ],
                onChanged: (v) => setState(() => eligibilityStatus = v!),
                decoration: const InputDecoration(labelText: 'Eligibility Status'),
              ),

              const SizedBox(height: 20),

              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveStudent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.student == null ? 'Save Student' : 'Update Student'),
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
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final student = Student(
        id: widget.student?.id, // Keep ID if editing
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        email: emailCtrl.text,
        qualification: qualificationCtrl.text,
        passingYear: int.tryParse(passingYearCtrl.text),
        primaryCourse: primaryCourseCtrl.text,
        courseDuration: courseDuration,
        eligibilityStatus: eligibilityStatus,
      );

      if (widget.student == null) {
        await _studentService.addStudent(student);
      } else {
        // We need an update method in service. For now, addStudent only inserts.
        // I will need to update StudentService to support update.
        // Or I can just call a new method updateStudent.
        await _studentService.updateStudent(student);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student saved successfully')),
      );
      Navigator.pop(context, true); 
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
