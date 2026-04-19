import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(TaskMapApp());
}

class TaskMapApp extends StatelessWidget {
  const TaskMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
