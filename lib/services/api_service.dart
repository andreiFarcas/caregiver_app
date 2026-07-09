import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String _baseUrl = "http://20.251.201.46:8000";

  /// Fetches the dynamically loaded environment variable.
  static String get _appToken => dotenv.env['APP_TOKEN'] ?? '';

  /// Fetches the list of bracelets paired to this specific app.
  static Future<List<dynamic>?> getPairedBracelets(String appId) async {
    final url = Uri.parse('$_baseUrl/api/bracelets?app_id=$appId');
    try {
      final response = await http.get(
        url,
        headers: {"X-App-Token": _appToken, "Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        print("DEBUG: Paired Bracelets Response: $decoded");
        return decoded;
      } else {
        print("Failed to fetch bracelets: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Network error fetching bracelets: $e");
      return null;
    }
  }

  /// Pairs a new bracelet with the application
  static Future<bool> pairBracelet({
    required String appId,
    required String patientName,
    required String braceletId,
    required String securityCode,
  }) async {
    final url = Uri.parse('$_baseUrl/api/bracelets');

    try {
      final response = await http.post(
        url,
        headers: {"X-App-Token": _appToken, "Content-Type": "application/json"},
        body: jsonEncode({
          "bracelet_id": braceletId,
          "security_code": securityCode,
          "user_name": patientName,
          "app_id": appId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Pairing failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network error during pairing: $e");
      return false;
    }
  }

  /// Fetches details for a specific bracelet
  static Future<Map<String, dynamic>?> getBraceletDetails(
    String braceletId,
  ) async {
    final url = Uri.parse('$_baseUrl/api/bracelets/$braceletId');
    try {
      final response = await http.get(url, headers: {"X-App-Token": _appToken});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        print("DEBUG: Bracelet Details Response for $braceletId: $decoded");
        return decoded;
      }
      return null;
    } catch (e) {
      print("Network error fetching details: $e");
      return null;
    }
  }

  /// Fetches events for a specific bracelet
  static Future<List<dynamic>?> getBraceletEvents(String braceletId) async {
    final url = Uri.parse(
      '$_baseUrl/api/bracelets/$braceletId/events?limit=20',
    );
    try {
      final response = await http.get(url, headers: {"X-App-Token": _appToken});
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print("Network error fetching events: $e");
      return null;
    }
  }

  /// Unpairs a bracelet from this app
  static Future<bool> unpairBracelet(String braceletId, String appId) async {
    final url = Uri.parse('$_baseUrl/api/bracelets/$braceletId?app_id=$appId');
    try {
      final response = await http.delete(
        url,
        headers: {"X-App-Token": _appToken},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Network error during unpairing: $e");
      return false;
    }
  }

  /// Registers the FCM token for this app with the backend
  static Future<bool> registerFCMToken(String appId, String fcmToken) async {
    final url = Uri.parse('$_baseUrl/api/notifications/register');
    try {
      final response = await http.post(
        url,
        headers: {"X-App-Token": _appToken, "Content-Type": "application/json"},
        body: jsonEncode({"app_id": appId, "fcm_token": fcmToken}),
      );
      if (response.statusCode == 200) {
        print("FCM Token registered successfully with server.");
        return true;
      } else {
        print(
          "Failed to register FCM token: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("Network error registering FCM token: $e");
      return false;
    }
  }

  /// Sets a geofence for a specific bracelet
  static Future<bool> setGeofence({
    required String braceletId,
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final url = Uri.parse('$_baseUrl/api/bracelets/$braceletId/geofence');
    try {
      final response = await http.post(
        url,
        headers: {"X-App-Token": _appToken, "Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "radius": radius,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Geofence set successfully for bracelet $braceletId.");
        return true;
      } else {
        print("Failed to set geofence: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network error setting geofence: $e");
      return false;
    }
  }
}
