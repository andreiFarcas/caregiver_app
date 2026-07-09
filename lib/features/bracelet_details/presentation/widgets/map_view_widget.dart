import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/bracelet_model.dart';

class MapViewWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String source;
  final GeofenceModel? geofence;
  
  const MapViewWidget({
    super.key, 
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.source,
    this.geofence,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final MapController _mapController = MapController();

  Future<void> _openInExternalMap() async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch external map.');
    }
  }

  void _recenterMap() {
    _mapController.move(LatLng(widget.latitude, widget.longitude), 16.5);
  }

  List<LatLng> _createCirclePoints(LatLng center, double radiusInMeters, {int points = 64}) {
    final List<LatLng> circlePoints = [];
    const double earthRadius = 6371000.0;
    final double d = radiusInMeters / earthRadius;
    final double lat1 = center.latitude * math.pi / 180.0;
    final double lng1 = center.longitude * math.pi / 180.0;

    for (int i = 0; i <= points; i++) {
      final double brng = (i * 360 / points) * math.pi / 180.0;
      double lat2 = math.asin(math.sin(lat1) * math.cos(d) + math.cos(lat1) * math.sin(d) * math.cos(brng));
      double lng2 = lng1 + math.atan2(math.sin(brng) * math.sin(d) * math.cos(lat1), math.cos(d) - math.sin(lat1) * math.sin(lat2));
      circlePoints.add(LatLng(lat2 * 180.0 / math.pi, lng2 * 180.0 / math.pi));
    }
    return circlePoints;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: MapViewWidget build. Geofence is: ${widget.geofence != null ? 'Present (Lat: ${widget.geofence!.latitude}, Lng: ${widget.geofence!.longitude}, Radius: ${widget.geofence!.radius})' : 'Null'}');
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
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.latitude, widget.longitude),
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
                      point: LatLng(widget.latitude, widget.longitude),
                      radius: widget.accuracy > 0 ? widget.accuracy : 20.0, // Default to 20m if 0
                      useRadiusInMeter: true,
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                if (widget.geofence != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _createCirclePoints(
                          LatLng(widget.geofence!.latitude, widget.geofence!.longitude),
                          widget.geofence!.radius,
                        ),
                        color: Colors.orange,
                        strokeWidth: 3.0,
                        pattern: StrokePattern.dashed(segments: const [10, 10]),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.latitude, widget.longitude),
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
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source: ${widget.source.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Accuracy: ±${widget.accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 12,
              child: FloatingActionButton(
                heroTag: 'recenter_map',
                onPressed: _recenterMap,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                mini: true,
                child: const Icon(Icons.my_location),
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
