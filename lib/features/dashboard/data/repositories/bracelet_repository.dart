import '../../../../services/api_service.dart';
import '../../../../core/models/bracelet_model.dart';

class BraceletRepository {
  /// Fetches raw data from the API and maps it to strongly-typed BraceletModels
  Future<List<BraceletModel>?> getPairedBracelets(String appId) async {
    try {
      final rawList = await ApiService.getPairedBracelets(appId);
      
      if (rawList == null) return null;

      return rawList.map((json) {
        return BraceletModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Repository Error mapping bracelets: $e");
      return null;
    }
  }
}
