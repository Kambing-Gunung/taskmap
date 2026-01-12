import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/task.dart';
import '../models/poi.dart';
import '../services/task_service.dart';
import '../services/poi_service.dart';
import '../widgets/bottom_nav.dart';
import 'detail_task_screen.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final TaskService _taskService = TaskService();
  final MapController _mapController = MapController();

  List<Task> _tasksWithLocation = [];
  List<POI> _pois = [];
  bool _loadingPOI = true;
  bool _isSatellite = true;

  LatLng _currentCenter = LatLng(-6.175392, 106.827153);
  LatLng? _lastPOICenter;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _setCurentCenter();
    _loadPOI();
  }

  Timer? _poiDebounce;

  void _debouncedFetchPOI() {
    if (_lastPOICenter != null) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        _lastPOICenter!,
        _currentCenter,
      );

      if (distance < 300) return; // geser dikit → skip
    }

    _lastPOICenter = _currentCenter;

    _poiDebounce?.cancel();
    _poiDebounce = Timer(const Duration(milliseconds: 800), _loadPOI);
  }

  Future<void> _setCurentCenter() async {
    if (_tasksWithLocation.isNotEmpty) {
      final firstTask = _tasksWithLocation.first;
      setState(() {
        _currentCenter = LatLng(firstTask.latitude!, firstTask.longitude!);
        _mapController.move(_currentCenter, 15);
      });
    }
  }

  Future<void> _loadPOI() async {
    setState(() => _loadingPOI = true);

    try {
      _pois = await POIService.fetchPOIs(
        lat: _currentCenter.latitude,
        lng: _currentCenter.longitude,
      );
    } catch (e) {
      debugPrint('POI error: $e');
    }

    if (mounted) {
      setState(() => _loadingPOI = false);
    }
  }

  // final List<POI> dummyPOIs = [
  //   POI(
  //     name: 'RS Umum Jakarta',
  //     type: 'hospital',
  //     latitude: -6.176,
  //     longitude: 106.827,
  //   ),
  //   POI(
  //     name: 'Restoran Nusantara',
  //     type: 'restaurant',
  //     latitude: -6.174,
  //     longitude: 106.829,
  //   ),
  //   POI(
  //     name: 'ATM Mandiri',
  //     type: 'atm',
  //     latitude: -6.173,
  //     longitude: 106.826
  //   ),
  // ];

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
        actions: [
          Row(
            children: [
              const Icon(Icons.map, size: 18),
              Switch(
                value: _isSatellite,
                activeColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    _isSatellite = value;
                  });
                },
              ),
              const Icon(Icons.satellite_alt, size: 18),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentCenter,
          initialZoom: 15,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              _currentCenter = position.center!;
              _debouncedFetchPOI();
            }
          },
        ),

        children: [
          // =====================
          // TILE LAYER
          // =====================
          TileLayer(
            urlTemplate: _isSatellite
                // SATELIT (ESRI)
                ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}'
                // JALAN RAYA (OSM)
                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          MarkerLayer(
            markers: _pois.map((poi) {
              return Marker(
                point: LatLng(poi.latitude, poi.longitude),
                width: 50,
                height: 50,

                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(poi.name),
                        content: Text('Jenis: ${poi.type}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    _poiIcon(poi.type),
                    color: _poiColor(poi.type),
                    size: 25,
                  ),
                ),
              );
            }).toList(),
          ),

          if (_pois.isEmpty && !_loadingPOI)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'POI tidak tersedia saat ini',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (_loadingPOI)
            const Positioned(
              top: 10,
              right: 10,
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Color.fromARGB(126, 255, 255, 255),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2),
    );
  }

  IconData _poiIcon(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'restaurant':
        return Icons.restaurant;
      case 'atm':
        return Icons.account_balance;
      case 'school':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  Color _poiColor(String type) {
    switch (type) {
      case 'hospital':
        return Colors.red;
      case 'restaurant':
        return Colors.green;
      case 'atm':
        return Colors.blue;
      case 'school':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
