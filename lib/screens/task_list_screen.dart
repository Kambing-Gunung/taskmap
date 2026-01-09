import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../services/task_service.dart';
import '../models/task.dart';
import '../screens/add_task_screen.dart';
import '../screens/detail_task_screen.dart';
import '../widgets/bottom_nav.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _updateStatus(Task task, String newStatus) async {
    final updatedTask = Task(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      category: task.category,
      status: newStatus,
      createdAt: task.createdAt,
      deadline: task.deadline,
      latitude: task.latitude,
      longitude: task.longitude,
    );

    await _taskService.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await _taskService.getTasks();
    setState(() {
      _tasks = data;
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _goToAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen()),
    );
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Belum ada task'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];

                return Slidable(
                  key: ValueKey(task.id),

                  // ======================
                  // SWIPE KANAN → DELETE
                  // ======================
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Hapus Task'),
                              content: const Text(
                                'Apakah kamu yakin ingin menghapus task ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _taskService.deleteTask(task.id!);
                            _loadTasks();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task berhasil dihapus'),
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Hapus',
                      ),
                    ],
                  ),

                  // ======================
                  // SWIPE KIRI → STATUS
                  // ======================
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.75,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          await _taskService.updateTask(
                            task.copyWith(status: 'pending'),
                          );
                          _loadTasks();
                        },
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        icon: Icons.access_time,
                        label: 'Pending',
                      ),

                      SlidableAction(
                        onPressed: (_) async {
                          await _taskService.updateTask(
                            task.copyWith(status: 'selesai'),
                          );
                          _loadTasks();
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.check_circle,
                        label: 'Selesai',
                      ),

                      SlidableAction(
                        onPressed: (_) async {
                          await _taskService.updateTask(
                            task.copyWith(status: 'batal'),
                          );
                          _loadTasks();
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.cancel,
                        label: 'Batal',
                      ),
                    ],
                  ),

                  // ======================
                  // CARD TASK
                  // ======================
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: task.status == 'selesai'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text('${task.category} • ${task.status}'),
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }

  // =====================
  // STATUS ICON
  // =====================
  Widget _statusIcon(String status) {
    switch (status) {
      case 'selesai':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'batal':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  // =====================
  // SWIPE BACKGROUND
  // =====================
  Widget _buildSwipeBg({
    required Color color,
    required IconData icon,
    required String text,
    required bool alignLeft,
  }) {
    return Container(
      color: color,
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!alignLeft) Text(text, style: _swipeTextStyle),
          Icon(icon, color: Colors.white, size: 32),
          if (alignLeft) Text(text, style: _swipeTextStyle),
        ],
      ),
    );
  }

  TextStyle get _swipeTextStyle =>
      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
}
