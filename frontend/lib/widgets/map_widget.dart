import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _center = const LatLng(-7.2575, 112.7521); // Surabaya as default
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _fetchMarkers(); // Load markers for default location
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });

      _fetchMarkers(); // Refresh markers based on actual location
    } catch (e) {
      debugPrint('Failed to get location: $e');
    }
  }

  Future<void> _fetchMarkers() async {
    final lat = _center.latitude;
    final lon = _center.longitude;

    final response = await http.get(
      Uri.parse(
        'https://overpass-api.de/api/interpreter?data=[out:json];('
        'node["amenity"="blood_donation"](around:10000,$lat,$lon);'
        'node["amenity"="clinic"](around:10000,$lat,$lon);'
        'node["amenity"="dentist"](around:10000,$lat,$lon);'
        'node["amenity"="doctor"](around:10000,$lat,$lon);'
        'node["amenity"="hospital"](around:10000,$lat,$lon);'
        'node["amenity"="nursing_home"](around:10000,$lat,$lon);'
        'node["amenity"="pharmacy"](around:10000,$lat,$lon);'
        'node["amenity"="social_facility"](around:10000,$lat,$lon);'
        'node["amenity"="veterinary"](around:10000,$lat,$lon);'
        ');out;',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Marker> markers = [];

      for (var element in data['elements']) {
        if (element['lat'] != null && element['lon'] != null) {
          String amenity = element['tags']?['amenity'] ?? '';
          String iconPath = _getIconPath(amenity);

          markers.add(
            Marker(
              point: LatLng(element['lat'], element['lon']),
              width: 40,
              height: 40,
              child: Image.asset(iconPath),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
      });
    } else {
      throw Exception('Failed to load places');
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
      case 'doctor':
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: _center, initialZoom: 13.0),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}
