import 'package:flutter/foundation.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String source;

  LocationModel({
    required this.latitude, 
    required this.longitude,
    this.accuracy = 50.0,
    this.source = 'Unknown',
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,   //basically cast the value to num first, then to double, and if it's null, default to 0.0
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 50.0,
      source: json['method'] ?? 'Unknown',
    );
  }
}

class GeofenceModel {
  final double latitude;
  final double longitude;
  final double radius;

  GeofenceModel({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) {
    debugPrint('DEBUG: Parsing GeofenceModel from json: $json');
    return GeofenceModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radius: (json['radius'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BraceletModel {
  final String id;
  final String patientName;
  final String status;
  final int batteryPercent;
  final LocationModel lastLocation;
  final String lastSeen;
  final GeofenceModel? geofence;

  BraceletModel({
    required this.id,
    required this.patientName,
    required this.status,
    required this.batteryPercent,
    required this.lastLocation,
    required this.lastSeen,
    this.geofence,
  });

  factory BraceletModel.fromJson(Map<String, dynamic> json) {
    return BraceletModel(
      id: json['id']?.toString() ?? '',
      patientName: json['user_name'] ?? 'Unknown Patient',
      status: json['status'] ?? 'OK',
      batteryPercent: json['battery_percent'] ?? 100,
      lastLocation: json['last_location'] != null 
          ? LocationModel.fromJson(json['last_location']) 
          : LocationModel(latitude: 0.0, longitude: 0.0),
      lastSeen: json['last_seen'] ?? '',
      geofence: json['geofence'] != null
          ? GeofenceModel.fromJson(json['geofence'])
          : null,
    );
  }
}

