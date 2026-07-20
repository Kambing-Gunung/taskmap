import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
<<<<<<< HEAD

void main() {
  runApp(TaskMapApp());
}

class TaskMapApp extends StatelessWidget {
  const TaskMapApp({super.key});
=======
import 'screens/task_list_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await SessionService.isLoggedIn();
  final userName = await SessionService.getUserName();

  runApp(MyApp(isLoggedIn: isLoggedIn, userName: userName));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;

  const MyApp({super.key, required this.isLoggedIn, this.userName});
>>>>>>> working

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'TaskMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
=======
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? TaskListScreen() : const LoginScreen(),
>>>>>>> working
    );
  }
}
