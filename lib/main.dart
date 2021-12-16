import 'package:flutter/material.dart';
import 'package:todo/database/sqlhelper_dao.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'CRUD TodoApp',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const TodoAppHomePage());
  }
}

class TodoAppHomePage extends StatefulWidget {
  const TodoAppHomePage({Key? key}) : super(key: key);

  @override
  _TodoAppHomePageState createState() => _TodoAppHomePageState();
}

class _TodoAppHomePageState extends State<TodoAppHomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SqlHelper.readAllItem();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (_) => Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _insertItem(id);
                }

                if (id != null) {
                  await _updateItem(id);
                }

                _titleController.text = '';
                _descriptController.text = '';

                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Criar' : 'Atualizar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _insertItem() async {
    await SqlHelper.insertItem(
      _titleController.text,
      _descriptController.text,
    );

    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SqlHelper.updateItem(
      id,
      _titleController.text,
      _descriptController.text,
    );

    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excluído'),
      ),
    );

    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoApp'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length, itemBuilder: itemBuilder),
    );
  }
}
