import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class SharedPreferencesService {
  static const String _keyUserData = 'user_data';
  static const String _deviceToken = 'deviceToken';
  static const String _apiToken = 'apiToken';

  static final logger = Logger();

  Future<void> saveDeviceToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceToken, token);
  }

  Future<String?> readDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceToken);
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiToken, token);
  }

  Future<String?> readToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiToken);
  }

  Future<void> saveUserData(dynamic userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = json.encode(userData.toJson());
    await prefs.setString(_keyUserData, data);
  }

  Future<dynamic> readUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyUserData);
    if (data != null) {
      Map<String, dynamic> jsonData = json.decode(data);
      return jsonData; // Modify this to return a specific model if needed
    }
    return null;
  }

  Future<void> clearAllPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.clear();
    if (result) {
      logger.i('All SharedPreferences data cleared successfully.');
    } else {
      logger.e('Failed to clear SharedPreferences data.');
    }
  }
}
