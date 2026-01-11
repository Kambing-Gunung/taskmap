import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poi.dart';

class POIService {
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';

  /// Ambil POI di sekitar titik (radius meter)
  static Future<List<POI>> fetchPOIs({
    required double lat,
    required double lng,
    int radius = 800,
  }) async {
    final query =
        '''
    [out:json];
    (
      node["amenity"="hospital"](around:$radius,$lat,$lng);
      node["amenity"="restaurant"](around:$radius,$lat,$lng);
      node["amenity"="atm"](around:$radius,$lat,$lng);
      node["amenity"="school"](around:$radius,$lat,$lng);
    );
    out body;
    ''';

    final response = await http.post(
      Uri.parse(_endpoint),
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil POI');
    }

    final data = json.decode(response.body);
    final List elements = data['elements'];

    return elements.map((e) {
      final tags = e['tags'] ?? {};
      return POI(
        name: tags['name'] ?? 'POI Tanpa Nama',
        type: tags['amenity'] ?? 'unknown',
        latitude: e['lat'],
        longitude: e['lon'],
      );
    }).toList();
  }
}
