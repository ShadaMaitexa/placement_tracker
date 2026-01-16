import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import 'package:placement_tracker/core/services/student_service.dart';
import 'package:placement_tracker/modules/aptitude/models/aptitude_model.dart';
import 'package:placement_tracker/modules/student/models/student_model.dart';

class AptitudeResultListPage extends StatelessWidget {
  const AptitudeResultListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AptitudeResult>>(
      future: AptitudeService().getResults(),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
         if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Results Recorded'));

         return ListView.builder(
           itemCount: snapshot.data!.length,
           itemBuilder: (context, index) {
             final res = snapshot.data![index];
             return Card(
               child: ListTile(
                 leading: CircleAvatar(
                   backgroundColor: res.score > (res.maxScore * 0.7) ? Colors.green : Colors.orange,
                   child: Text('${res.score}'),
                 ),
                 title: Text(res.studentName ?? 'Unknown Student'),
                 subtitle: Text('${res.testTitle ?? "Unknown Test"} • Accuracy: ${res.accuracy}%'),
               ),
             );
           },
         );
      },
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
      appBar: AppBar(title: const Text('Record Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              hint: const Text('Select Student'),
              items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _selectedStudent = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTest,
              hint: const Text('Select Test'),
              items: _tests.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
              onChanged: (v) => setState(() => _selectedTest = v),
            ),
             const SizedBox(height: 12),
            TextField(
              controller: _scoreCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Score Obtained'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time Taken (mins)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Result'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
     if (_selectedStudent == null || _selectedTest == null) return;
     
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
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
     }
  }
}
