import 'package:flutter/material.dart';
import '/screens/task_list_screen.dart';
import '/screens/calendar_screen.dart';
import '/screens/maps_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = TaskListScreen();
        break;
      case 1:
        page = CalendarScreen();
        break;
      case 2:
        page = MapsScreen();
        break;
      default:
        page = TaskListScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
      ],
    );
  }
}
