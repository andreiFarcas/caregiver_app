import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapViewWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String source;
  
  const MapViewWidget({
    super.key, 
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.source,
  });

  Future<void> _openInExternalMap() async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch external map.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380, // Increased height
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 16.5, // Increased zoom to focus on the accuracy circle
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.caregiverApp',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      radius: accuracy > 0 ? accuracy : 20.0, // Default to 20m if 0
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter, // Pulls the marker up so the bottom point sits exactly on the coordinate
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
            
            // Source & Accuracy Info Box
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source: ${source.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Accuracy: ±${accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.extended(
                heroTag: 'open_external_map',
                onPressed: _openInExternalMap,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Google Maps'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
