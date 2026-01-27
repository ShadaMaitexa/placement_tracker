import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/core/utils/responsive.dart';
import 'package:placement_tracker/modules/aptitude/models/aptitude_model.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AddTestPage extends StatefulWidget {
  const AddTestPage({super.key});

  @override
  State<AddTestPage> createState() => _AddTestPageState();
}

class _AddTestPageState extends State<AddTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = AptitudeService();
  final _titleCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _totalMarksCtrl = TextEditingController(text: '100');
  String _type = 'quant';
  bool _isLoading = false;

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
          title: Text('New Aptitude Test', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsive(20.0, tablet: 40.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildField(_titleCtrl, 'Test Title', Icons.title),
                          const SizedBox(height: 16),
                          _buildDropdown(),
                          const SizedBox(height: 16),
                          _buildField(_totalMarksCtrl, 'Total Marks', Icons.score, keyboard: TextInputType.number),
                          const SizedBox(height: 16),
                          _buildField(_batchCtrl, 'Assigned Batch (Optional)', Icons.group_outlined, required: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                          : Text('Create Test', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool required = true, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.blue, size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      dropdownColor: const Color(0xFF1E293B),
      items: ['quant', 'reasoning', 'verbal', 'coding']
          .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: GoogleFonts.inter(color: Colors.white))))
          .toList(),
      onChanged: (v) => setState(() => _type = v!),
      decoration: InputDecoration(
        labelText: 'Test Type',
        labelStyle: GoogleFonts.inter(color: Colors.white60),
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.blue, size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _service.addTest(AptitudeTest(
        title: _titleCtrl.text, 
        type: _type,
        totalMarks: int.tryParse(_totalMarksCtrl.text) ?? 100,
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
          title: Text('Aptitude Module', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFF3B82F6),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Available Tests'),
              Tab(text: 'Recent Results'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: TabBarView(
              controller: _tabController,
              children: [
                _TestList(service: _service),
                _ResultList(service: _service),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (_tabController.index == 0) {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTestPage()));
              if (result == true) setState(() {}); 
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
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('No Tests Created');
        
        final gridCount = context.responsive(1, tablet: 2, desktop: 2);
        
        return ListView.builder(
          padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0)),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final test = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                   Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getIcon(test.type), color: const Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(test.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                              child: Text(test.type.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Text('Max Marks: ${test.totalMarks}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
                          ],
                        ),
                      ],
                    ),
                  ),
                   if (test.assignedBatch != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
                      ),
                      child: Text(test.assignedBatch!, 
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
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
    if (type == 'coding') return Icons.code_rounded;
    if (type == 'quant') return Icons.functions_rounded;
    if (type == 'reasoning') return Icons.psychology_rounded;
    return Icons.quiz_rounded;
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
        ],
      ),
    );
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
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Results Recorded', style: TextStyle(color: Colors.white60)));

        return ListView.builder(
          padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0)),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final res = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]), shape: BoxShape.circle),
                        child: Center(child: Text(res.studentName?[0].toUpperCase() ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(res.studentName ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                            Text(res.testTitle ?? 'General Aptitude', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${res.score}/${res.maxScore}', 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF3B82F6))),
                          Text('SCORE', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniInfo('Accuracy', '${res.accuracy.toInt()}%', Icons.track_changes_outlined, const Color(0xFF10B981)),
                      _miniInfo('Time Taken', '${res.timeTakenMinutes}m', Icons.timer_outlined, Colors.orange),
                      _miniInfo('Status', res.score >= (res.maxScore * 0.4) ? 'PASS' : 'FAIL', Icons.verified_outlined, 
                        res.score >= (res.maxScore * 0.4) ? Colors.blue : Colors.red),
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

  Widget _miniInfo(String label, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
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
  final _formKey = GlobalKey<FormState>();
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
          title: Text('Record Skill Score', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsive(20.0, tablet: 40.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildDropdown('Student', _selectedStudent, _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(color: Colors.white)))).toList(), (v) => setState(() => _selectedStudent = v)),
                          const SizedBox(height: 16),
                          _buildDropdown('Test', _selectedTest, _tests.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, style: const TextStyle(color: Colors.white)))).toList(), (v) => setState(() => _selectedTest = v)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _field(_scoreCtrl, 'Score', Icons.stars_outlined)),
                              const SizedBox(width: 16),
                              Expanded(child: _field(_accuracyCtrl, 'Accuracy %', Icons.track_changes)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _field(_timeCtrl, 'Time (minutes)', Icons.timer_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                          : Text('Save Result', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? val, List<DropdownMenuItem<String>> items, ValueChanged<String?>? onChanged) {
    return DropdownButtonFormField<String>(
      value: val,
      dropdownColor: const Color(0xFF1E293B),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white60),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.blue, size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final test = _tests.firstWhere((t) => t.id == _selectedTest);
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

