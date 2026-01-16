import 'package:flutter/material.dart';
import 'package:placement_tracker/core/services/aptitude_service.dart';
import 'package:placement_tracker/modules/aptitude/models/aptitude_model.dart';
import 'aptitude_result_page.dart';

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
      appBar: AppBar(title: const Text('New Aptitude Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Test Title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: ['quant', 'reasoning', 'verbal', 'coding']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _batchCtrl,
              decoration: const InputDecoration(labelText: 'Assigned Batch (Optional)'),
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _save,
                  child: const Text('Create Test'),
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
      appBar: AppBar(
        title: const Text('Aptitude Module'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
          const AptitudeResultListPage(), // Need to implement this
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_tabController.index == 0) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTestPage()));
            setState(() {}); // refresh
          } else {
            // Navigate to Add Result
             await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddResultPage()));
             setState(() {});
          }
        },
        child: const Icon(Icons.add),
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
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No Tests Created'));
        
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final test = snapshot.data![index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(_getIcon(test.type))),
                title: Text(test.title),
                subtitle: Text('${test.type.toUpperCase()} • ${test.totalMarks} Marks'),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(String type) {
    if (type == 'coding') return Icons.code;
    return Icons.quiz;
  }
}
