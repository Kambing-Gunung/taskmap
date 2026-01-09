import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/task.dart';
import '../models/subtask.dart';
import '../services/task_service.dart';
import '../services/subtask_service.dart';
import '../widgets/location_picker_dialog.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;

  late String _status;
  late DateTime _deadline;
  LatLng? _selectedLocation;

  final TaskService _taskService = TaskService();
  final SubtaskService _subtaskService = SubtaskService();

  List<Subtask> _tempSubtasks = [];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _categoryController = TextEditingController(text: widget.task.category);

    _status = widget.task.status;
    _deadline = DateTime.parse(widget.task.deadline ?? widget.task.createdAt);

    if (widget.task.latitude != null && widget.task.longitude != null) {
      _selectedLocation = LatLng(widget.task.latitude!, widget.task.longitude!);
    }

    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final all = await _subtaskService.getSubtasks();
    setState(() {
      _tempSubtasks = all.where((s) => s.taskId == widget.task.id).toList();
    });
  }

  // =====================
  // PICK DEADLINE
  // =====================
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  // =====================
  // PICK LOCATION
  // =====================
  Future<void> _pickLocation() async {
    final result = await showLocationPickerDialog(
      context,
      initialLocation: _selectedLocation,
    );

    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  // =====================
  // SAVE TASK + SUBTASK
  // =====================
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Task(
      id: widget.task.id,
      userId: widget.task.userId,
      title: _titleController.text,
      description: _descController.text,
      category: _categoryController.text,
      status: _status,
      createdAt: widget.task.createdAt,
      deadline: _deadline.toIso8601String(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    await _taskService.updateTask(updated);

    // 🔥 SYNC SUBTASK
    for (final s in _tempSubtasks) {
      if (s.id == null) {
        await _subtaskService.insertSubtask(s);
      } else {
        await _subtaskService.updateSubtask(s);
      }
    }

    Navigator.pop(context, updated);
  }

  // =====================
  // SUBTASK HANDLER
  // =====================
  void _addSubtaskTemp(String title) {
    setState(() {
      _tempSubtasks.add(
        Subtask(taskId: widget.task.id!, title: title, status: 'Pending'),
      );
    });
  }

  void _toggleSubtask(Subtask s) {
    setState(() {
      s.status = s.status == 'Done' ? 'Pending' : 'Done';
    });
  }

  void _removeSubtask(Subtask s) {
    setState(() => _tempSubtasks.remove(s));
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    final deadlineText =
        "${_deadline.day}/${_deadline.month}/${_deadline.year}";
    final locationText = _selectedLocation == null
        ? 'Pilih Lokasi'
        : "Lat ${_selectedLocation!.latitude.toStringAsFixed(4)}, "
              "Lng ${_selectedLocation!.longitude.toStringAsFixed(4)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Task'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 24),

              // DEADLINE
              InkWell(
                onTap: _pickDeadline,
                child: _pickerBox(deadlineText, Icons.calendar_today),
              ),
              const SizedBox(height: 16),

              // LOCATION
              InkWell(
                onTap: _pickLocation,
                child: _pickerBox(locationText, Icons.map),
              ),
              const SizedBox(height: 24),

              // STATUS
              Row(
                children: [
                  _statusButton('pending', Icons.access_time, Colors.orange),
                  const SizedBox(width: 8),
                  _statusButton('selesai', Icons.check_circle, Colors.green),
                  const SizedBox(width: 8),
                  _statusButton('batal', Icons.cancel, Colors.red),
                ],
              ),

              const Divider(height: 40),

              // SUBTASK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtask',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddSubtaskDialog(),
                  ),
                ],
              ),

              ..._tempSubtasks.map(
                (s) => ListTile(
                  leading: IconButton(
                    icon: Icon(
                      s.status == 'Done'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: s.status == 'Done' ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleSubtask(s),
                  ),
                  title: Text(
                    s.title,
                    style: TextStyle(
                      decoration: s.status == 'Done'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSubtask(s),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text)),
          Icon(icon),
        ],
      ),
    );
  }

  Widget _statusButton(String value, IconData icon, Color color) {
    final isSelected = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
            border: Border.all(color: isSelected ? color : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              Text(value.toUpperCase(), style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubtaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Subtask'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSubtaskTemp(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
