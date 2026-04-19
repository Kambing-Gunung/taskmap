import 'package:flutter/material.dart';
import '/widgets/bottom_nav.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task List')),
      body: Center(
        child: ElevatedButton(
          child: Text('Daftar Task'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }
}
