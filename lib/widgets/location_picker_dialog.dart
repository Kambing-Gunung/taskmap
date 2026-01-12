import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../models/poi.dart';
import '../services/poi_service.dart';

Future<LatLng?> showLocationPickerDialog(
  BuildContext context, {
  LatLng? initialLocation,
  bool isSatellite = true,
}) {
  return showDialog<LatLng>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      LatLng? pickedLocation = initialLocation;
      LatLng currentCenter =
          initialLocation ?? const LatLng(-6.175392, 106.827153);

      List<POI> _pois = [];
      bool _loadingPOI = false;
      Timer? debounce;

      Future<void> loadPOI(void Function(void Function()) setState) async {
        try {
          setState(() => _loadingPOI = true);
          _pois = await POIService.fetchPOIs(
            lat: currentCenter.latitude,
            lng: currentCenter.longitude,
          );
        } catch (e) {
          debugPrint('POI dialog error: $e');
        }
        setState(() => _loadingPOI = false);
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pilih Lokasi Tugas'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: currentCenter,
                  initialZoom: 15,
                  onTap: (_, point) {
                    setState(() => pickedLocation = point);
                  },
                  onPositionChanged: (pos, hasGesture) {
                    if (!hasGesture || pos.center == null) return;
                    currentCenter = pos.center!;

                    debounce?.cancel();
                    debounce = Timer(
                      const Duration(milliseconds: 600),
                      () => loadPOI(setState),
                    );
                  },
                ),
                children: [
                  // =====================
                  // TILE
                  // =====================
                  TileLayer(
                    urlTemplate: isSatellite
                        // SATELIT (ESRI)
                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                              'World_Imagery/MapServer/tile/{z}/{y}/{x}'
                        // JALAN RAYA (OSM)
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.taskmap',
                  ),

                  // =====================
                  // POI MARKER
                  // =====================
                  MarkerLayer(
                    markers: _pois.map((poi) {
                      return Marker(
                        point: LatLng(poi.latitude, poi.longitude),
                        width: 40,
                        height: 40,
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
                            size: 22,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // =====================
                  // PICKED LOCATION
                  // =====================
                  if (pickedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pickedLocation!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
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
            ),

            actions: [
              Row(
                children: [
                  const Icon(Icons.map, size: 18),
                  Switch(
                    value: isSatellite,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        isSatellite = value;
                      });
                    },
                  ),
                  const Icon(Icons.satellite_alt, size: 18),
                  const SizedBox(width: 8),
                ],
              ),
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
