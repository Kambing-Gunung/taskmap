import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Variabel untuk menyimpan lokasi yang dipilih user
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi Tugas'),
        actions: [
          // Tombol Simpan (Centang) hanya muncul jika sudah pilih lokasi
          if (_pickedLocation != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // Kembalikan data lokasi ke halaman sebelumnya
                Navigator.pop(context, _pickedLocation);
              },
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          // Lokasi awal (Jakarta)
          initialCenter: LatLng(-6.175392, 106.827153),
          initialZoom: 15.0,
          // Fungsi saat peta diklik (Tap)
          onTap: (tapPosition, point) {
            setState(() {
              _pickedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            // Menggunakan Peta Satelit agar sama dengan halaman Maps
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.taskmap',
          ),
          // Menampilkan Pin Merah di lokasi yang dipilih
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation!,
                  width: 80,
                  height: 80,
                  child: Icon(Icons.location_on, color: Colors.red, size: 50),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
