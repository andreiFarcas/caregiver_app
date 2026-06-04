import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppConfigService {
  static const String _appIdKey = 'app_id_key';

  /// Retrieves the unique App ID. If it doesn't exist, it generates and saves one.
  static Future<String> getAppId() async {
    final prefs = await SharedPreferences.getInstance();
    String? appId = prefs.getString(_appIdKey);

    if (appId == null) {
      appId = const Uuid().v4();
      await prefs.setString(_appIdKey, appId);
    }
    
    return appId;
  }
}
