import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NamedMarker {
  final Marker marker;
  final String name;

  NamedMarker({required this.marker, required this.name});
}

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  LatLng _center = const LatLng(-7.2575, 112.7521);
  List<NamedMarker> _namedMarkers = [];
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchMarkers();
  }

  Future<void> moveToLocation(LatLng newLocation) async {
    setState(() {
      _center = newLocation;
    });
    _mapController.move(newLocation, 17.0); // Zoom to level 17
  }

  Future<void> _fetchMarkers() async {
    final lat = _center.latitude;
    final lon = _center.longitude;

    final bbox = '${lat - 0.1},${lon - 0.1},${lat + 0.1},${lon + 0.1}';

    final query = '''
    [out:json][timeout:25];
    (
      node["amenity"="hospital"]($bbox);
      way["amenity"="hospital"]($bbox);
      relation["amenity"="hospital"]($bbox);

      node["amenity"="clinic"]($bbox);
      way["amenity"="clinic"]($bbox);
      relation["amenity"="clinic"]($bbox);

      node["amenity"="pharmacy"]($bbox);
      node["amenity"="doctors"]($bbox);
      node["amenity"="dentist"]($bbox);
      node["amenity"="veterinary"]($bbox);
      node["amenity"="nursing_home"]($bbox);
      node["amenity"="social_facility"]($bbox);
      node["amenity"="blood_donation"]($bbox);
    );
    out center;
    ''';

    final encodedQuery = Uri.encodeComponent(query);

    try {
      final response = await http.get(
        Uri.parse('https://overpass-api.de/api/interpreter?data=$encodedQuery'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched data: $data');

        List<NamedMarker> namedMarkers = [];

        for (var element in data['elements']) {
          final lat = element['lat'] ?? element['center']?['lat'];
          final lon = element['lon'] ?? element['center']?['lon'];

          if (lat != null && lon != null) {
            String amenity = element['tags']?['amenity'] ?? '';
            String name =
                element['tags']?['name'] ?? 'Unnamed ${_capitalize(amenity)}';
            String iconPath = _getIconPath(amenity);

            print('Adding marker: Lat: $lat, Lon: $lon, Name: $name');

            final marker = Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Location Info'),
                          content: Text(name),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
                child: Image.asset(iconPath),
              ),
            );

            namedMarkers.add(NamedMarker(marker: marker, name: name));
          }
        }

        setState(() {
          _namedMarkers = namedMarkers;
        });
      } else {
        print(
          'Error fetching data: ${response.statusCode}, Response: ${response.body}',
        );
        throw Exception('Failed to load markers');
      }
    } catch (e) {
      print('Error fetching markers: $e');
    }
  }

  String _getIconPath(String amenity) {
    switch (amenity) {
      case 'blood_donation':
        return 'assets/icon maps/blood donation icon.png';
      case 'clinic':
        return 'assets/icon maps/clinic icon.png';
      case 'dentist':
        return 'assets/icon maps/dentist icon.png';
      case 'doctors':
        return 'assets/icon maps/doctors icon.png';
      case 'hospital':
        return 'assets/icon maps/hospital icon.png';
      case 'nursing_home':
        return 'assets/icon maps/nursing home icon.png';
      case 'pharmacy':
        return 'assets/icon maps/pharmacy icon.png';
      case 'social_facility':
        return 'assets/icon maps/social facility icon.png';
      case 'veterinary':
        return 'assets/icon maps/veterinary icon.png';
      default:
        return 'assets/icon maps/clinic icon.png';
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  List<NamedMarker> getNamedMarkers() => _namedMarkers;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _center, initialZoom: 13.0),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _namedMarkers.map((e) => e.marker).toList()),
      ],
    );
  }
}
