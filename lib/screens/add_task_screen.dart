import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  String _status = 'Pending';
  final DateTime _selectedDate = DateTime.now();

  final TaskService _taskService = TaskService();

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      Task task = Task(
        userId: 1, // dummy user
        title: _titleController.text,
        description: _descController.text,
        category: _categoryController.text,
        status: _status,
        date: _selectedDate.toIso8601String(),
        latitude: 0.0,
        longitude: 0.0,
      );

      await _taskService.insertTask(task);

      Navigator.pop(context); // kembali ke list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Task'),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Kategori'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'On Progress', 'Done']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _saveTask, child: Text('Simpan Task')),
            ],
          ),
        ),
      ),
    );
  }
}
