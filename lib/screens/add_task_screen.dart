import 'package:flutter/material.dart';
import '/widgets/bottom_nav.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Center(child: Text('Tambah Task')),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }
}
