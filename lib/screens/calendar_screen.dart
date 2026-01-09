import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/bottom_nav.dart';
import 'detail_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskService _taskService = TaskService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.getTasks();
    setState(() => _allTasks = tasks);
  }

  // =====================
  // FILTER TASK PER DAY
  // =====================
  List<Task> _getTasksForDay(DateTime day) {
    return _allTasks.where((task) {
      if (task.deadline == null) return false;
      final taskDate = DateTime.parse(task.deadline!);
      return isSameDay(taskDate, day);
    }).toList();
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    final selectedTasks = _getTasksForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // =====================
          // CALENDAR
          // =====================
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,

            eventLoader: _getTasksForDay,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const Divider(),

          // =====================
          // HEADER
          // =====================
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Task: ${_selectedDay.day}/"
              "${_selectedDay.month}/"
              "${_selectedDay.year}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // =====================
          // TASK LIST
          // =====================
          Expanded(
            child: selectedTasks.isEmpty
                ? const Center(child: Text('Tidak ada task di tanggal ini'))
                : ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.category),
                          trailing: _statusIcon(task.status),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailTaskScreen(task: task),
                              ),
                            );
                            _loadTasks();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 1),
    );
  }

  // =====================
  // STATUS ICON
  // =====================
  Widget _statusIcon(String status) {
    switch (status) {
      case 'checklist':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'batal':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.access_time, color: Colors.orange);
    }
  }
}
