import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/subtask.dart';
import '../services/subtask_service.dart';
import 'edit_task_screen.dart';

class DetailTaskScreen extends StatefulWidget {
  final Task task;

  const DetailTaskScreen({super.key, required this.task});

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  final SubtaskService _subtaskService = SubtaskService();
  List<Subtask> _subtasks = [];

  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final all = await _subtaskService.getSubtasks();
    setState(() {
      _subtasks = all.where((s) => s.taskId == _task.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = _task.deadline != null
        ? _formatDate(_task.deadline!)
        : 'Tidak ada deadline';

    final completed = _subtasks.where((s) => s.status == 'Done').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Task'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedTask = await Navigator.push<Task>(
                context,
                MaterialPageRoute(builder: (_) => EditTaskScreen(task: _task)),
              );

              if (updatedTask != null) {
                setState(() {
                  _task = updatedTask;
                });
                _loadSubtasks(); // tetap reload subtask
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE & STATUS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusChip(_task.status),
              ],
            ),
            const SizedBox(height: 16),

            _infoRow(Icons.category, _task.category),
            _infoRow(Icons.calendar_today, 'Deadline: $deadlineText'),

            if (_task.latitude != null && _task.longitude != null)
              _infoRow(
                Icons.location_on,
                'Lokasi: ${_task.latitude}, ${_task.longitude}',
              ),

            const Divider(height: 40),

            // ===== DESCRIPTION =====
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _boxText(
              _task.description.isEmpty
                  ? 'Tidak ada deskripsi.'
                  : _task.description,
            ),

            const Divider(height: 40),

            // ===== SUBTASK =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtask',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$completed / ${_subtasks.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_subtasks.isEmpty)
              const Text(
                'Tidak ada subtask.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._subtasks.map((s) => _subtaskItem(s)),
          ],
        ),
      ),
    );
  }

  // =====================
  // WIDGET HELPERS
  // =====================

  Widget _subtaskItem(Subtask s) {
    final isDone = s.status == 'Done';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : Colors.grey,
      ),
      title: Text(
        s.title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _boxText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text),
    );
  }

  Widget _statusChip(String status) {
    late Color color;
    late String label;
    late IconData icon;

    switch (status) {
      case 'selesai':
        color = Colors.green;
        label = 'Selesai';
        icon = Icons.check_circle;
        break;
      case 'batal':
        color = Colors.red;
        label = 'Batal';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.access_time;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
      shape: StadiumBorder(side: BorderSide(color: color)),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}/${d.month}/${d.year}';
  }
}
