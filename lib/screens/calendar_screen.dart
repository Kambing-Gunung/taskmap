import 'package:flutter/material.dart';
import '/widgets/bottom_nav.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: Center(child: Text('Kalender')),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }
}
