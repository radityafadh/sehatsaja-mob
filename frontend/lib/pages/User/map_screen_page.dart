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
  List<String> searchSuggestions = [];
  List<String> allFacilityNames = [];
  bool showSuggestions = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFacilityNames();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _loadFacilityNames() {
    final namedMarkers = _mapKey.currentState?.getNamedMarkers() ?? [];
    setState(() {
      allFacilityNames = namedMarkers.map((marker) => marker.name).toList();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    _updateSearchSuggestions(query);
  }

  void _updateSearchSuggestions(String query) {
    final lowerQuery = query.toLowerCase();
    final suggestions =
        allFacilityNames
            .where((name) => name.toLowerCase().contains(lowerQuery))
            .take(5) // Limit to 5 suggestions
            .toList();

    setState(() {
      searchSuggestions = suggestions;
    });

    _showSuggestionsOverlay();
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    if (searchSuggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx + 12,
            top: offset.dy + 120, // Adjust based on your search bar position
            width: size.width - 24,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: searchSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(searchSuggestions[index]),
                      onTap: () {
                        _searchController.text = searchSuggestions[index];
                        _searchFacility(searchSuggestions[index]);
                        _removeOverlay();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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
      _removeOverlay();
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
                    onTap: () {
                      if (_searchController.text.isNotEmpty) {
                        _updateSearchSuggestions(_searchController.text);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchFacility(_searchController.text);
                    FocusScope.of(context).unfocus();
                  },
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
