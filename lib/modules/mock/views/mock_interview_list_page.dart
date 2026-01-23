import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/auth_service.dart';
import 'package:placement_tracker/core/services/mock_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/mock/models/mock_interview.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AddMockInterviewPage extends StatefulWidget {
  const AddMockInterviewPage({super.key});

  @override
  State<AddMockInterviewPage> createState() => _AddMockInterviewPageState();
}

class _AddMockInterviewPageState extends State<AddMockInterviewPage> {
  final _mockService = MockInterviewService();
  final _stuService = StudentService();

  List<Student> _students = [];
  String? _selectedStudent;
  String _type = 'hr';
  
  double _communication = 5;
  double _technical = 5;
  double _confidence = 5;
  double _bodyLanguage = 5;
  
  final _feedbackCtrl = TextEditingController();
  String _status = 'ready';
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final s = await _stuService.getStudents();
    setState(() => _students = s);
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
          title: Text('Record Interview', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectionCard(),
                const SizedBox(height: 24),
                Text('Performance Scores', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildScoreCard(),
                const SizedBox(height: 24),
                Text('Conclusion', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildConclusionCard(),
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
                      : Text('Save Interview Results', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedStudent,
            hint: Text('Select Student', style: GoogleFonts.inter()),
            items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => _selectedStudent = v),
            validator: (v) => v == null ? 'Please select a student' : null,
            decoration: InputDecoration(
              labelText: 'Student',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF3B82F6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            items: ['hr', 'technical', 'managerial']
                .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: GoogleFonts.inter())))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: InputDecoration(
              labelText: 'Interview Type',
              prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF3B82F6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _scoreSlider('Communication', _communication, (v) => setState(() => _communication = v)),
          _scoreSlider('Technical', _technical, (v) => setState(() => _technical = v)),
          _scoreSlider('Confidence', _confidence, (v) => setState(() => _confidence = v)),
          _scoreSlider('Body Language', _bodyLanguage, (v) => setState(() => _bodyLanguage = v)),
        ],
      ),
    );
  }

  Widget _scoreSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white70)),
            Text(val.toInt().toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
          ],
        ),
        Slider(
          value: val,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: const Color(0xFF3B82F6),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildConclusionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _feedbackCtrl,
            maxLines: 3,
            validator: (v) => v == null || v.isEmpty ? 'Please provide feedback' : null,
            decoration: InputDecoration(
              hintText: 'Detailed feedback...',
              labelText: 'Feedback & Comments',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'ready', child: Text('✅ Ready')),
              DropdownMenuItem(value: 'needs_improvement', child: Text('⚠ Needs Improvement')),
              DropdownMenuItem(value: 'not_ready', child: Text('❌ Not Ready')),
            ],
            onChanged: (v) => setState(() => _status = v!),
            validator: (v) => v == null ? 'Required' : null,
            decoration: InputDecoration(
              labelText: 'Final Verdict',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _mockService.addInterview(MockInterview(
        studentId: _selectedStudent!,
        interviewType: _type,
        communication: _communication.toInt(),
        technical: _technical.toInt(),
        confidence: _confidence.toInt(),
        bodyLanguage: _bodyLanguage.toInt(),
        feedback: _feedbackCtrl.text,
        status: _status,
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

class MockInterviewListPage extends StatefulWidget {
  const MockInterviewListPage({super.key});

  @override
  State<MockInterviewListPage> createState() => _MockInterviewListPageState();
}

class _MockInterviewListPageState extends State<MockInterviewListPage> {
  final _service = MockInterviewService();
  final _authService = AuthService();
  final _studentService = StudentService();
  
  List<MockInterview> _interviews = [];
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
      await _loadInterviews();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInterviews() async {
    try {
      List<MockInterview> data;
      if (_userRole == 'student' && _studentId != null) {
        data = await _service.getInterviewsForStudent(_studentId!);
      } else {
        data = await _service.getInterviews();
      }
      if (mounted) {
        setState(() {
          _interviews = data;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'admin' || _userRole == 'trainer';

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
          title: Text('Mock Interviews', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMockInterviewPage()));
          if (result == true) _loadInterviews();
        },
        backgroundColor: const Color(0xFF3B82F6),
        label: Text('Record Interview', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _interviews.isEmpty 
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadInterviews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _interviews.length,
                    itemBuilder: (context, index) {
                      final interview = _interviews[index];
                      return _buildInterviewCard(interview);
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildInterviewCard(MockInterview interview) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(interview.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getTypeIcon(interview.interviewType), color: _getStatusColor(interview.status)),
        ),
        title: Text(
          interview.studentName ?? 'Student',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        subtitle: Text(
          '${interview.interviewType.toUpperCase()} • ${_formatDate(interview.conductedAt)}',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
        ),
        trailing: _buildStatusBadge(interview.status),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniScore('Comm', interview.communication),
                    _buildMiniScore('Tech', interview.technical),
                    _buildMiniScore('Conf', interview.confidence),
                    _buildMiniScore('Body', interview.bodyLanguage),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Feedback', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  interview.feedback ?? "No feedback provided.",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScore(String label, int score) {
    return Column(
      children: [
        Text(score.toString(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    String label = status.replaceAll('_', ' ').toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'ready') return const Color(0xFF10B981);
    if (status == 'needs_improvement') return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getTypeIcon(String type) {
    if (type == 'technical') return Icons.computer_outlined;
    if (type == 'hr') return Icons.people_outline;
    return Icons.manage_accounts_outlined;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No interviews recorded yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white60)),
        ],
      ),
    );
  }
}
