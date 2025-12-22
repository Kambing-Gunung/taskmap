import 'package:flutter/material.dart';
import '/widgets/bottom_nav.dart';

class MapsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maps')),
      body: Center(child: Text('Peta')),
      bottomNavigationBar: BottomNav(currentIndex: 0),
    );
  }
}
