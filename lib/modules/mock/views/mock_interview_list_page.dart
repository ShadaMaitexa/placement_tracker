import 'package:flutter/material.dart';
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
  
  // Scores
  double _communication = 5;
  double _technical = 5;
  double _confidence = 5;
  double _bodyLanguage = 5;
  
  final _feedbackCtrl = TextEditingController();
  String _status = 'ready';
  bool _isLoading = false;

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
    return Scaffold(
      appBar: AppBar(title: const Text('New Mock Interview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              hint: const Text('Select Student'),
              items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _selectedStudent = v),
              decoration: const InputDecoration(labelText: 'Student'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: ['hr', 'technical', 'managerial']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Interview Type'),
            ),
            
            const SizedBox(height: 20),
            const Text('Scores (1-10)', style: TextStyle(fontWeight: FontWeight.bold)),
            _scoreSlider('Communication', _communication, (v) => setState(() => _communication = v)),
            _scoreSlider('Technical', _technical, (v) => setState(() => _technical = v)),
            _scoreSlider('Confidence', _confidence, (v) => setState(() => _confidence = v)),
            _scoreSlider('Body Language', _bodyLanguage, (v) => setState(() => _bodyLanguage = v)),

            TextField(
              controller: _feedbackCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Feedback & Comments'),
            ),
             const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'ready', child: Text('✅ Ready')),
                DropdownMenuItem(value: 'needs_improvement', child: Text('⚠ Needs Improvement')),
                DropdownMenuItem(value: 'not_ready', child: Text('❌ Not Ready')),
              ],
              onChanged: (v) => setState(() => _status = v!),
              decoration: const InputDecoration(labelText: 'Final Verdict'),
            ),

            const SizedBox(height: 24),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Interview'),
                ),
          ],
        ),
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
            Text(label),
            Text(val.toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_selectedStudent == null) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Interviews')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMockInterviewPage()));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<MockInterview>>(
        future: _service.getInterviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Interviews Recorded'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final interview = snapshot.data![index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(interview.status),
                    child: Icon(_getTypeIcon(interview.interviewType), color: Colors.white, size: 18),
                  ),
                  title: Text(interview.studentName ?? 'Unknown'),
                  subtitle: Text('${interview.interviewType.toUpperCase()} • ${interview.status.replaceAll('_', ' ')}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _scoreRow('Communication', interview.communication),
                          _scoreRow('Technical', interview.technical),
                          _scoreRow('Confidence', interview.confidence),
                          const Divider(),
                          Text('Feedback: ${interview.feedback ?? "None"}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _scoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$score/10', style: TextStyle(fontWeight: FontWeight.bold, color: score < 5 ? Colors.red : Colors.green)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'ready') return Colors.green;
    if (status == 'needs_improvement') return Colors.orange;
    return Colors.red;
  }

  IconData _getTypeIcon(String type) {
    if (type == 'technical') return Icons.computer;
    if (type == 'hr') return Icons.people;
    return Icons.manage_accounts;
  }
}
