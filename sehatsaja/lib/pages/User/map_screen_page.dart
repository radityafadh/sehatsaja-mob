import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const HealthFacilitiesMapApp());
}

class HealthFacilitiesMapApp extends StatelessWidget {
  const HealthFacilitiesMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Facilities Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  late _MapWidgetState _mapWidgetState;
  final GlobalKey<_MapWidgetState> _mapWidgetKey = GlobalKey();

  bool _isRouting = false;
  NamedMarker? _selectedDestination;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapWidgetState = _mapWidgetKey.currentState!;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final markers = _mapWidgetState.getNamedMarkers();
      final match = markers.firstWhere(
        (marker) => marker.name.toLowerCase().contains(query.toLowerCase()),
        orElse:
            () => NamedMarker(
              marker: Marker(
                point: const latlong.LatLng(0, 0),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on),
              ),
              name: '',
              amenity: '',
            ),
      );

      if (match.name.isNotEmpty) {
        setState(() {
          _isRouting = true;
          _selectedDestination = match;
        });
        await _mapWidgetState.moveToLocation(match.marker.point);
        await _mapWidgetState.showRouteToDestination(match.marker.point);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _isRouting = false;
      _selectedDestination = null;
    });
    _searchController.clear();
    _mapWidgetState.clearRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRouting ? 'Navigation' : 'Health Facilities Map',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          if (_isRouting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _clearRoute,
            ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapWidgetState.centerOnUserLocation(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search health facilities...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                ),
              ),
              Expanded(child: _MapWidget(key: _mapWidgetKey)),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton:
          _isRouting
              ? FloatingActionButton.extended(
                onPressed: () {
                  if (_selectedDestination != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Navigating to ${_selectedDestination!.name} (${_selectedDestination!.amenity})',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.directions),
                label: const Text('Start Navigation'),
              )
              : null,
    );
  }
}

class NamedMarker {
  final Marker marker;
  final String name;
  final String amenity;

  NamedMarker({
    required this.marker,
    required this.name,
    required this.amenity,
  });
}

class _MapWidget extends StatefulWidget {
  const _MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<_MapWidget> {
  latlong.LatLng _center = const latlong.LatLng(-7.2575, 112.7521);
  List<NamedMarker> _namedMarkers = [];
  late MapController _mapController;
  List<latlong.LatLng> _routePoints = [];
  Position? _currentPosition;
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchMarkers();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _center = latlong.LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_center, 15.0);
    } catch (e) {
      // Error handling removed as per request
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  Future<void> moveToLocation(latlong.LatLng newLocation) async {
    setState(() => _center = newLocation);
    _mapController.move(newLocation, 17.0);
  }

  Future<void> centerOnUserLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }
    if (_currentPosition != null) {
      final userLocation = latlong.LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      await moveToLocation(userLocation);
    }
  }

  Future<void> showRouteToDestination(latlong.LatLng destination) async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return;
    }

    final origin = latlong.LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}?'
          'overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          final geometry = data['routes'][0]['geometry']['coordinates'];
          setState(() {
            _routePoints =
                geometry
                    .map<latlong.LatLng>(
                      (coord) => latlong.LatLng(coord[1], coord[0]),
                    )
                    .toList();
          });
        }
      }
    } catch (e) {
      // Error handling removed as per request
    }
  }

  void clearRoute() {
    setState(() => _routePoints = []);
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

    try {
      final response = await http.get(
        Uri.parse(
          'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<NamedMarker> namedMarkers = [];

        for (var element in data['elements']) {
          final lat = element['lat'] ?? element['center']?['lat'];
          final lon = element['lon'] ?? element['center']?['lon'];

          if (lat != null && lon != null) {
            String amenity = element['tags']?['amenity'] ?? '';
            String name =
                element['tags']?['name'] ?? 'Unnamed ${_capitalize(amenity)}';

            final marker = Marker(
              point: latlong.LatLng(lat, lon),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showFacilityInfo(name, amenity, lat, lon),
                child: Image.asset(
                  _getIconPath(amenity),
                  width: 30,
                  height: 30,
                ),
              ),
            );

            namedMarkers.add(
              NamedMarker(marker: marker, name: name, amenity: amenity),
            );
          }
        }

        setState(() => _namedMarkers = namedMarkers);
      }
    } catch (e) {
      // Error handling removed as per request
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

  void _showFacilityInfo(String name, String amenity, double lat, double lon) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${_capitalize(amenity)}'),
                const SizedBox(height: 8),
                Text('Latitude: ${lat.toStringAsFixed(5)}'),
                Text('Longitude: ${lon.toStringAsFixed(5)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showRouteToDestination(latlong.LatLng(lat, lon));
                },
                child: const Text('Get Directions'),
              ),
            ],
          ),
    );
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
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 13.0,
        onMapReady: () {
          _mapController.mapEventStream.listen((event) {
            if (event is MapEventMove) {
              _fetchMarkers();
            }
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.healthfacilities',
        ),
        CurrentLocationLayer(
          alignPositionOnUpdate: AlignOnUpdate.never,
          alignDirectionOnUpdate: AlignOnUpdate.never,
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(color: Colors.blue),
            markerSize: const Size(40, 40),
            accuracyCircleColor: Colors.blue.withOpacity(0.3),
          ),
        ),
        MarkerLayer(markers: _namedMarkers.map((e) => e.marker).toList()),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue.withOpacity(0.7),
                strokeWidth: 4,
              ),
            ],
          ),
        if (_locationLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
