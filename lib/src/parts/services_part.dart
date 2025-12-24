part of layerx_generator;

// ========================= SERVICES =========================

extension _ServicesPart on LayerXGenerator {
  Future<void> _createServiceFiles(String appDirPath) async {
    final servicesDir = Directory(path.join(appDirPath, 'services'));

    await File(
      path.join(servicesDir.path, 'logger_service.dart'),
    ).writeAsString('''
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// Custom log printer with enhanced formatting and timestamps.
class CustomPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter;

  CustomPrinter()
      : _prettyPrinter = PrettyPrinter(
          methodCount: 1,
          errorMethodCount: 6,
          lineLength: 120,
          colors: true,
          printEmojis: true,
        );

  @override
  List<String> log(LogEvent event) {
    final output = _prettyPrinter.log(event);
    final formattedTime =
        DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.now());
    final levelName = event.level.name.toUpperCase();
    return output
        .map((line) => '[📅 \$formattedTime] [\$levelName] \$line')
        .toList();
  }
}

class LoggerService {
  LoggerService._();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: CustomPrinter(),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
''');

    await File(
      path.join(servicesDir.path, 'shared_preferences_service.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class SharedPreferencesService {
  static const String _keyUserData = 'user_data';
  static const String _deviceToken = 'deviceToken';
  static const String _apiToken = 'apiToken';

  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceToken, token);
    LoggerService.i('Saved device token');
  }

  Future<String?> readDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceToken);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiToken, token);
    LoggerService.i('Saved API token');
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiToken);
  }

  Future<void> saveUserData(dynamic userData) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(userData.toJson());
    await prefs.setString(_keyUserData, data);
    LoggerService.i('Saved user data');
  }

  Future<dynamic> readUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUserData);
    if (data == null) return null;
    return json.decode(data);
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
''');

    await File(
      path.join(servicesDir.path, 'global_variables.dart'),
    ).writeAsString('''
import '../config/app_enums.dart';

/// Global variables for the LayerX app.
class GlobalVariables {
  static List<String> errorMessages = ['Failed, Try Again'];
  static String route = '';
  static UserRole userRole = UserRole.user;
}
''');

    await File(
      path.join(servicesDir.path, 'json_extractor.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:logger/logger.dart';
import 'global_variables.dart';

class MessageExtractor {
  final Logger _logger = Logger();

  void extractAndStoreMessage(String endPoint, String responseBody) {
    GlobalVariables.errorMessages.clear();

    try {
      _logger.i("💡 API EndPoint: \$endPoint - Raw Response: \$responseBody");

      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        GlobalVariables.errorMessages.add("Unexpected server response format.");
        return;
      }

      final jsonMap = decoded;

      if (jsonMap['errors'] is Map<String, dynamic>) {
        final errorsMap = jsonMap['errors'] as Map<String, dynamic>;
        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List) {
            for (final msg in value) {
              if (msg != null && msg.toString().trim().isNotEmpty) {
                GlobalVariables.errorMessages.add(msg.toString().trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(value.trim());
          }
        }
      } else if (jsonMap['errors'] is List) {
        final errorsList = jsonMap['errors'] as List;
        for (final error in errorsList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      } else if (jsonMap['data'] is List) {
        final dataList = jsonMap['data'] as List;
        for (final error in dataList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      }

      if (GlobalVariables.errorMessages.isEmpty &&
          jsonMap['message'] != null &&
          jsonMap['message'].toString().trim().isNotEmpty) {
        GlobalVariables.errorMessages.add(jsonMap['message'].toString().trim());
      }

      if (GlobalVariables.errorMessages.isEmpty) {
        GlobalVariables.errorMessages.add("Something went wrong.");
      }
    } catch (e, st) {
      _logger.e("❌ Error extracting message: \$e", error: e, stackTrace: st);
      GlobalVariables.errorMessages.add("Connection issue. Please retry.");
    }

    _logger.i("✅ Extracted Errors: \${GlobalVariables.errorMessages}");
  }
}
''');

    await File(
      path.join(servicesDir.path, 'location_service.dart'),
    ).writeAsString('''
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logger_service.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      LoggerService.w('Location services are disabled');
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      throw Exception('Location permission denied forever.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
''');

    await File(
      path.join(servicesDir.path, 'api_response_handler.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../customWidgets/custom_dialogs/no_internetdialog.dart';
import '../mvvm/model/api_response_model/api_response.dart';
import 'json_extractor.dart';
import 'logger_service.dart';

/// Handles API responses with standardized processing.
class ApiResponseHandler {
  static Future<ApiResponse<T>> process<T>(
    dynamic response,
    String? endPoint,
    T Function(dynamic dataJson) fromJson,
  ) async {
    MessageExtractor().extractAndStoreMessage(endPoint ?? '', response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        final parsedJson = response.body.length > 100000
            ? await compute<String, dynamic>(_parseJson, response.body)
            : jsonDecode(response.body);
        LoggerService.i('✅ API response processed: "endPoint"');
        return ApiResponse<T>.fromJson(parsedJson, fromJson);

      case 401:
        _handleUnauthorized(endPoint);
        break;

      case 422:
        return _handleError<T>(response, 'Validation Error');

      case 500:
        return _handleError<T>(response, 'Internal Server Error');

      case 503:
        return _handleNoInternet();

      default:
        return _handleError<T>(
          response,
          'API Error: "{response.statusCode} - {response.reasonPhrase}"',
        );
    }

    return ApiResponse<T>(message: 'Unexpected error occurred');
  }

  static dynamic _parseJson(String responseBody) {
    return jsonDecode(responseBody);
  }

  static void _handleUnauthorized(String? endPoint) {
    LoggerService.w('⛔ Unauthorized. Checking endpoint...');

    if ((endPoint ?? '').toLowerCase().contains('login') ||
        (endPoint ?? '').toLowerCase().contains('delete-account')) {
      LoggerService.w('🔁 401 on login endpoint. Skipping redirect.');
      return;
    }

    LoggerService.w('⛔ Unauthorized. Redirecting to login.');
    // Get.offAllNamed(AppRoutes.loginView);
    throw Exception('Unauthorized access. Please log in.');
  }

  static _handleNoInternet() {
    LoggerService.w('📴 No internet detected (503)');
    if (!(Get.isDialogOpen ?? false)) {
      Future.delayed(Duration.zero, () {
        NoInternetDialog.show(
          title: "Network Error",
          message:
              "Unable to connect to the server. Please check your internet connection and try again.",
          closeText: "Dismiss",
          onClose: () {},
        );
      });
      throw Exception('No internet connection. Please try again.');
    }
  }

  static ApiResponse<T> _handleError<T>(dynamic response, String errorMessage) {
    try {
      final errorResponse = jsonDecode(response.body);
      final message =
          errorResponse['message'] ?? 'Something went wrong. Please try again.';
      return ApiResponse<T>(message: message);
    } catch (e, stack) {
      LoggerService.e('❌ Error parsing error response',
          error: e, stackTrace: stack);
      return ApiResponse<T>(message: errorMessage);
    }
  }

  static void logUnhandledError(dynamic e, StackTrace stackTrace) {
    LoggerService.e('⚠️ Unhandled error', error: e, stackTrace: stackTrace);
  }
}
''');

    await File(
      path.join(servicesDir.path, 'https_calls.dart'),
    ).writeAsString(_httpsCallsContent());

    stdout.writeln('Created service files.');
  }
}
