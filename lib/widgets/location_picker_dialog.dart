import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng?> showLocationPickerDialog(
  BuildContext context, {
  LatLng? initialLocation,
}) {
  return showDialog<LatLng>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      LatLng? pickedLocation = initialLocation;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pilih Lokasi Tugas'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      pickedLocation ?? const LatLng(-6.175392, 106.827153),
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      pickedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.example.taskmap',
                  ),
                  if (pickedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pickedLocation!,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: pickedLocation == null
                    ? null
                    : () => Navigator.pop(context, pickedLocation),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}
