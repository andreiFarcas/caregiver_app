import '../../../../services/api_service.dart';
import '../../../../core/models/bracelet_model.dart';

/// The BraceletDetailsRepository acts as a bridge between the raw HTTP network 
/// calls in ApiService and the UI in BraceletDetailsScreen. 
/// 
/// Instead of the UI directly parsing complex JSON maps, this repository fetches 
/// the raw data from the server and safely converts it into structured Dart 
/// objects (the BraceletModel from ../../../../core/models/bracelet_model.dart)
/// This keeps the UI screen clean and entirely focused on rendering pixels.
class BraceletDetailsRepository {
  Future<BraceletModel?> getDetails(String braceletId) async {
    final rawData = await ApiService.getBraceletDetails(braceletId);
    if (rawData == null) return null;
    return BraceletModel.fromJson(rawData);
  }

  Future<List<Map<String, dynamic>>?> getEvents(String braceletId) async {
    final rawData = await ApiService.getBraceletEvents(braceletId);
    if (rawData == null) return null;
    return rawData.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<bool> unpair(String braceletId, String appId) async {
    return await ApiService.unpairBracelet(braceletId, appId);
  }

  Future<bool> setGeofence({
    required String braceletId,
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    return await ApiService.setGeofence(
      braceletId: braceletId,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  Future<bool> resolveEmergency(String braceletId) async {
      return await ApiService.resolveEmergency(braceletId);
    }
}