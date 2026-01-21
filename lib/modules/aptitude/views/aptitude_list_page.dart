import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/aptitude/models/aptitude_model.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AddTestPage extends StatefulWidget {
  const AddTestPage({super.key});

  @override
  State<AddTestPage> createState() => _AddTestPageState();
}

class _AddTestPageState extends State<AddTestPage> {
  final _service = AptitudeService();
  final _titleCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  String _type = 'quant';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('New Aptitude Test', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Test Title',
                      prefixIcon: const Icon(Icons.title, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: ['quant', 'reasoning', 'verbal', 'coding']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: GoogleFonts.inter())))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF3B82F6)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _batchCtrl,
                    decoration: InputDecoration(
                      labelText: 'Assigned Batch (Optional)',
                      prefixIcon: const Icon(Icons.group_outlined, color: Color(0xFF3B82F6)),
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
                  : Text('Create Test', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _service.addTest(AptitudeTest(
        title: _titleCtrl.text, 
        type: _type,
        assignedBatch: _batchCtrl.text.isEmpty ? null : _batchCtrl.text,
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

class AptitudeTestListPage extends StatefulWidget {
  const AptitudeTestListPage({super.key});

  @override
  State<AptitudeTestListPage> createState() => _AptitudeTestListPageState();
}

class _AptitudeTestListPageState extends State<AptitudeTestListPage> with SingleTickerProviderStateMixin {
  final _service = AptitudeService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Aptitude Module', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tests'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TestList(service: _service),
          _ResultList(service: _service),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_tabController.index == 0) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTestPage()));
            setState(() {}); 
          } else {
             final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddResultPage()));
             if (result == true) setState(() {});
          }
        },
        backgroundColor: const Color(0xFF3B82F6),
        label: Text(_tabController.index == 0 ? 'Create Test' : 'Record Score', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _TestList extends StatefulWidget {
  final AptitudeService service;
  const _TestList({required this.service});

  @override
  State<_TestList> createState() => __TestListState();
}

class __TestListState extends State<_TestList> {
  @override
  Widget build(BuildContext context) {
     return FutureBuilder<List<AptitudeTest>>(
      future: widget.service.getTests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('No Tests Created');
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final test = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIcon(test.type), color: const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(test.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${test.type.toUpperCase()} • Max: ${test.totalMarks}', 
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                   if (test.assignedBatch != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(test.assignedBatch!, 
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(String type) {
    if (type == 'coding') return Icons.code_outlined;
    if (type == 'quant') return Icons.functions_outlined;
    if (type == 'reasoning') return Icons.psychology_outlined;
    return Icons.quiz_outlined;
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Text(msg, style: GoogleFonts.inter(color: Colors.grey)));
  }
}

class _ResultList extends StatelessWidget {
  final AptitudeService service;
  const _ResultList({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AptitudeResult>>(
      future: service.getResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Results Recorded'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final res = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(res.studentName?[0] ?? '?')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(res.studentName ?? 'Unknown', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            Text(res.testTitle ?? 'Test', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('${res.score}/${res.maxScore}', 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF3B82F6))),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniInfo('Accuracy', '${res.accuracy.toInt()}%'),
                      _miniInfo('Time', '${res.timeTakenMinutes}m'),
                      _miniInfo('Status', res.score >= (res.maxScore * 0.4) ? 'PASS' : 'FAIL'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniInfo(String label, String val) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
      ],
    );
  }
}

class AddResultPage extends StatefulWidget {
  const AddResultPage({super.key});

  @override
  State<AddResultPage> createState() => _AddResultPageState();
}

class _AddResultPageState extends State<AddResultPage> {
  final _service = AptitudeService();
  final _stuService = StudentService();
  
  List<Student> _students = [];
  List<AptitudeTest> _tests = [];
  
  String? _selectedStudent;
  String? _selectedTest;
  final _scoreCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController(text: '100');
  final _timeCtrl = TextEditingController(text: '30');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final s = await _stuService.getStudents();
    final t = await _service.getTests();
    setState(() {
      _students = s;
      _tests = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Record Aptitude Score')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
             DropdownButtonFormField<String>(
              value: _selectedStudent,
              hint: const Text('Select Student'),
              items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _selectedStudent = v),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTest,
              hint: const Text('Select Test'),
              items: _tests.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
              onChanged: (v) => setState(() => _selectedTest = v),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _field(_scoreCtrl, 'Score obtained')),
                const SizedBox(width: 12),
                Expanded(child: _field(_accuracyCtrl, 'Accuracy %')),
              ],
            ),
            const SizedBox(height: 16),
            _field(_timeCtrl, 'Time Taken (minutes)'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
              child: const Text('Save Result'),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Future<void> _save() async {
    if (_selectedStudent == null || _selectedTest == null) return;
    final test = _tests.firstWhere((t) => t.id == _selectedTest);
    
    try {
      await _service.addResult(AptitudeResult(
        studentId: _selectedStudent!,
        testId: _selectedTest!,
        score: int.parse(_scoreCtrl.text),
        maxScore: test.totalMarks,
        accuracy: double.parse(_accuracyCtrl.text),
        timeTakenMinutes: int.parse(_timeCtrl.text),
      ));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
