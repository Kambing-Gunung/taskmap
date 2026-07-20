import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/location_picker_dialog.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  final TaskService _taskService = TaskService();

  String _status = 'pending';
  DateTime? _selectedDeadline;
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // =====================
  // PICK DEADLINE
  // =====================
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
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
  // SAVE TASK
  // =====================
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      userId: 1, // dummy user
      title: _titleController.text,
      description: _descController.text,
      category: _categoryController.text.isEmpty
          ? 'Umum'
          : _categoryController.text,
      status: _status,
      createdAt: DateTime.now().toIso8601String(),
      deadline: _selectedDeadline?.toIso8601String(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    await _taskService.insertTask(task);
    Navigator.pop(context, true);
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    final deadlineText = _selectedDeadline == null
        ? 'Pilih Deadline'
        : "${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}";

    final locationText = _selectedLocation == null
        ? 'Pilih Lokasi di Peta'
        : "Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, "
              "Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Task'),
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
              // =====================
              // TITLE
              // =====================
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Task',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // =====================
              // DESCRIPTION
              // =====================
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // =====================
              // CATEGORY
              // =====================
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // =====================
              // DEADLINE
              // =====================
              const Text(
                'Deadline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDeadline,
                child: _buildPickerBox(
                  text: deadlineText,
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(height: 24),

              // =====================
              // LOCATION
              // =====================
              const Text(
                'Lokasi Tugas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickLocation,
                child: _buildPickerBox(text: locationText, icon: Icons.map),
              ),

              const SizedBox(height: 24),

              // =====================
              // STATUS
              // =====================
              const Text(
                'Status Awal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statusButton('pending', Icons.access_time, Colors.orange),
                  const SizedBox(width: 8),
                  _statusButton('selesai', Icons.check_circle, Colors.green),
                  const SizedBox(width: 8),
                  _statusButton('batal', Icons.cancel, Colors.red),
                ],
              ),
              const SizedBox(height: 32),

              // =====================
              // SAVE BUTTON
              // =====================
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================
  // HELPER WIDGETS
  // =====================
  Widget _buildPickerBox({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
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
              const SizedBox(height: 4),
              Text(
                value.toUpperCase(),
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
