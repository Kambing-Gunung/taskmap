import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '/widgets/bottom_nav.dart';
import '/data/task.dart';

class MapsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Filter tugas yang punya lokasi
    final tasksWithLocation = globalTasks.where((task) => 
      task.latitude != null && task.longitude != null
    ).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Peta Tugas (Satelit)')),
      body: FlutterMap(
        options: MapOptions(
          // Lokasi awal (Jakarta)
          initialCenter: LatLng(-6.175392, 106.827153), 
          initialZoom: 15.0, 
        ),
        children: [
          // --- PERHATIKAN KURUNG DI BAGIAN INI ---
          TileLayer(
            // Link Satelit Esri
            urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.taskmap',
          ),
          // ---------------------------------------
          
          MarkerLayer(
            markers: tasksWithLocation.map((task) {
              return Marker(
                point: LatLng(task.latitude!, task.longitude!),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(task.title),
                        content: Text("Kategori: ${task.category}\nStatus: ${task.status}"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: Text("Tutup")
                          ),
                        ],
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 40),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        color: Colors.white.withOpacity(0.8),
                        child: Text(
                          task.title,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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