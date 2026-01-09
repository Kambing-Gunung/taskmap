import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/bottom_nav.dart';
import 'detail_task_screen.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasksWithLocation = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.getTasks();

    setState(() {
      _tasksWithLocation = tasks.where((task) {
        return task.latitude != null &&
            task.longitude != null &&
            task.latitude != 0.0 &&
            task.longitude != 0.0;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Tugas'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-6.175392, 106.827153), // Jakarta
          initialZoom: 13,
        ),
        children: [
          // =====================
          // TILE LAYER (SATELIT)
          // =====================
          TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/'
                'World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.taskmap',
          ),

          // =====================
          // MARKER LAYER
          // =====================
          MarkerLayer(
            markers: _tasksWithLocation.map((task) {
              return Marker(
                width: 80,
                height: 80,
                point: LatLng(task.latitude!, task.longitude!),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailTaskScreen(task: task),
                      ),
                    );
                    _loadTasks(); // refresh setelah edit
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2),
    );
  }
}
