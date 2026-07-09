import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/repositories/bracelet_details_repository.dart';

class GeofenceSetupScreen extends StatefulWidget {
  final String braceletId;
  final double? initialLatitude;
  final double? initialLongitude;

  const GeofenceSetupScreen({
    super.key, 
    required this.braceletId,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<GeofenceSetupScreen> createState() => _GeofenceSetupScreenState();
}

class _GeofenceSetupScreenState extends State<GeofenceSetupScreen> {
  final BraceletDetailsRepository _repository = BraceletDetailsRepository();

  // Starting center is last seen location or Cluj Napoca :)
  late final LatLng _center = (widget.initialLatitude != null && widget.initialLongitude != null) 
      ? LatLng(widget.initialLatitude!, widget.initialLongitude!) 
      : const LatLng(46.770439, 23.591423); 

  late LatLng _currentMapCenter = _center;

  double _radius = 50.0; // Initial radius in meters
  final MapController _mapController = MapController();

  Future<void> _saveGeofence() async {
    final success = await _repository.setGeofence(
      braceletId: widget.braceletId,
      latitude: _currentMapCenter.latitude,
      longitude: _currentMapCenter.longitude,
      radius: _radius,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geofence set successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set geofence.', style: TextStyle(color: Colors.red))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGeofence,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 18.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentMapCenter = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.caregiverApp',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentMapCenter,
                    radius: _radius,
                    useRadiusInMeter: true,
                    color: Colors.grey.withOpacity(0.75),
                    borderColor: Colors.deepOrangeAccent,
                    borderStrokeWidth: 7,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Radius: ${_radius.toInt()} meters',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _radius,
                      min: 10,
                      max: 500,
                      divisions: 51,
                      label: _radius.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                    Text(
                      'Center: Lat: ${_currentMapCenter.latitude.toStringAsFixed(4)}, Lng: ${_currentMapCenter.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
