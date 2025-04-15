import 'package:flutter/material.dart';
import 'package:frontend/widgets/map_widget.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();
  final TextEditingController _searchController = TextEditingController();

  void _searchFacility(String query) {
    final namedMarkers = _mapKey.currentState?.getNamedMarkers() ?? [];

    final match = namedMarkers.firstWhere(
      (namedMarker) =>
          namedMarker.name.toLowerCase().contains(query.toLowerCase()),
      orElse:
          () => NamedMarker(
            marker: Marker(
              point: const LatLng(0, 0),
              width: 0,
              height: 0,
              child: const SizedBox(),
            ),
            name: '',
          ),
    );

    if (match.name.isNotEmpty) {
      _mapKey.currentState?.moveToLocation(match.marker.point);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Facility not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for facility...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onSubmitted: _searchFacility,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchFacility(_searchController.text),
                ),
              ],
            ),
          ),
          Expanded(child: MapWidget(key: _mapKey)),
        ],
      ),
    );
  }
}
