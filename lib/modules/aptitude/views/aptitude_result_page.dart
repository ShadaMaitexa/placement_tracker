import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/aptitude/models/aptitude_model.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AptitudeResultListPage extends StatefulWidget {
  const AptitudeResultListPage({super.key});

  @override
  State<AptitudeResultListPage> createState() => _AptitudeResultListPageState();
}

class _AptitudeResultListPageState extends State<AptitudeResultListPage> {
  final _aptService = AptitudeService();
  final _authService = AuthService();
  final _studentService = StudentService();

  List<AptitudeResult> _results = [];
  bool _isLoading = true;
  String? _userRole;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userRole = await _authService.getUserRole(user.id);
        if (_userRole == 'student') {
          final student = await _studentService.getStudentByEmail(user.email!);
          if (student != null) {
            _studentId = student.id;
          }
        }
      }
      await _loadResults();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadResults() async {
    try {
      List<AptitudeResult> data;
      if (_userRole == 'student' && _studentId != null) {
        data = await _aptService.getResultsForStudent(_studentId!);
      } else {
        data = await _aptService.getResults();
      }
      if (mounted) {
        setState(() {
          _results = data;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'admin' || _userRole == 'trainer';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Aptitude Results', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddResultPage()));
          if (res == true) _loadResults();
        },
        backgroundColor: const Color(0xFF3B82F6),
        label: Text('Record Result', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty 
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final res = _results[index];
                      return _buildResultCard(res);
                    },
                  ),
                ),
    );
  }

  Widget _buildResultCard(AptitudeResult res) {
    final percentage = (res.score / res.maxScore * 100).toInt();
    final color = percentage >= 70 ? const Color(0xFF10B981) : percentage >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('$percentage%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color)),
        ),
        title: Text(res.testTitle ?? 'General Aptitude', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userRole != 'student') Text(res.studentName ?? 'Student', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF3B82F6))),
            Text('Score: ${res.score}/${res.maxScore} • Time: ${res.timeTakenMinutes}m', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No results found', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class AddResultPage extends StatefulWidget {
  const AddResultPage({super.key});

  @override
  State<AddResultPage> createState() => _AddResultPageState();
}

class _AddResultPageState extends State<AddResultPage> {
  final _aptService = AptitudeService();
  final _stuService = StudentService();

  List<Student> _students = [];
  List<AptitudeTest> _tests = [];
  
  String? _selectedStudent;
  String? _selectedTest;
  final _scoreCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final s = await _stuService.getStudents();
    final t = await _aptService.getTests();
    setState(() {
      _students = s;
      _tests = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Record Result', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStudent,
                      hint: const Text('Select Student'),
                      items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (v) => setState(() => _selectedStudent = v),
                      decoration: InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTest,
                      hint: const Text('Select Test'),
                      items: _tests.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
                      onChanged: (v) => setState(() => _selectedTest = v),
                      decoration: InputDecoration(
                        labelText: 'Test',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _scoreCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Score Obtained',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _timeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Time Taken (mins)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Result', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
     if (_selectedStudent == null || _selectedTest == null || _scoreCtrl.text.isEmpty) return;
     
     setState(() => _isLoading = true);
     final test = _tests.firstWhere((t) => t.id == _selectedTest);

     try {
       await _aptService.addResult(AptitudeResult(
         studentId: _selectedStudent!,
         testId: _selectedTest!,
         score: int.parse(_scoreCtrl.text),
         maxScore: test.totalMarks,
         timeTakenMinutes: int.tryParse(_timeCtrl.text) ?? 0,
       ));
       if (!mounted) return;
       Navigator.pop(context, true);
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
  }
}
