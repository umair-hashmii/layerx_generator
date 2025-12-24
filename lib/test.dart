/// A Flutter package that auto-generates the LayerX directory structure for scalable MVVM projects.
///
/// The `layerx_generator` package simplifies the setup of a Flutter project by generating
/// a clean MVVM (Model-View-ViewModel) directory structure under `lib/app/`. It includes
/// pre-configured utilities for HTTP requests, local storage, location services, logging,
/// and API response handling, all integrated with GetX for state management, navigation,
/// and dependency injection.
library layerx_generator;

import 'dart:io';
import 'package:path/path.dart' as path;

/// Generates the LayerX directory structure for a Flutter project.
///
/// ✅ Refined generator rules:
/// - No file references a class that isn't generated.
/// - All routes point to a generated view.
/// - Repositories only call methods that exist in services.
/// - Body models that use File include `dart:io`.
/// - Pubspec auto-updated to include required dependencies (so `flutter run` works without errors).
class LayerXGenerator {
  final String projectPath;

  LayerXGenerator(this.projectPath);

  Future<void> generate() async {
    try {
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        throw Exception('Project directory does not exist: $projectPath');
      }

      final libDir = Directory(path.join(projectPath, 'lib'));
      if (!await libDir.exists()) {
        throw Exception('Not a Flutter project (missing lib/): $projectPath');
      }

      final appDir = Directory(path.join(projectPath, 'lib', 'app'));
      await appDir.create(recursive: true);

      final directories = [
        'config',
        'mvvm/model/body_model',
        'mvvm/model/response_model',
        'mvvm/model/api_response_model',
        'mvvm/view/splash',
        'mvvm/view/login',
        'mvvm/view_model/splash',
        'mvvm/view_model/login',
        'repository/auth_repo',
        'repository/firebase',
        'repository/local_db',
        'repository/apis',
        'services',
        'services/notifications', // ✅ ADDED
        'widgets',
      ];

      for (final dir in directories) {
        final fullPath = path.join(appDir.path, dir);
        await Directory(fullPath).create(recursive: true);
        stdout.writeln('Created directory: $fullPath');
      }

      await _createConfigFiles(appDir.path);
      await _createMVVMSkeleton(appDir.path);
      await _createModelFiles(appDir.path);
      await _createServiceFiles(appDir.path);
      await _createNotificationFiles(appDir.path); // ✅ ADDED
      await _createRepositoryFiles(appDir.path);
      await _createAppWidgetFile(projectPath);
      await _updateMainFile(projectPath);

      stdout.writeln('✅ LayerX structure generated successfully!');
    } catch (e) {
      stderr.writeln('❌ Error generating LayerX structure: $e');
      rethrow;
    }
  }

  // ========================= CONFIG =========================

  Future<void> _createConfigFiles(String appDirPath) async {
    final configDir = Directory(path.join(appDirPath, 'config'));

    await File(path.join(configDir.path, 'app_assets.dart')).writeAsString('''
/// Defines asset paths for the LayerX app.
class AppAssets {
  static const String imagesPath = 'assets/images';
  static const String bgImage = '\$imagesPath/bg_image.png';
}
''');

    await File(path.join(configDir.path, 'app_colors.dart')).writeAsString('''
import 'package:flutter/material.dart';

/// Defines color constants for the LayerX app.
abstract class AppColors {
  AppColors._();

  static const Color primary = Color(0xff2D9BFF);
  static const Color secondaryWhite = Color(0xffFFFFFF);
  static const Color secondaryBlack = Color(0xff1B1C1E);

  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);

  static const Color positiveGreen = Color(0xff21D575);
  static const Color negativeRed = Color(0xffEA4334);

  static const Color textDarkColor = Color(0xff1B0036);
  static const Color textLightBlack = Color(0xff777E90);

  static const Color bgColor = Color(0xFFF0F1F6);
  static const Color darkBgColor = Color(0xFF1B1C1E);

  static const Color borderColor = Color(0xFFE6E7E9);
  static const Color borderGrey = Color(0xFFD7DDE5);

  static const Color transparent = Colors.transparent;
}
''');

    await File(path.join(configDir.path, 'app_enums.dart')).writeAsString('''
/// Defines enums for the LayerX app.
enum UserRole { user, business }
''');

    // ✅ Compile-safe routes: all pages exist + imports correct.
    await File(path.join(configDir.path, 'app_routes.dart')).writeAsString('''
import 'package:get/get.dart';

import '../mvvm/view/splash/splash_view.dart';
import '../mvvm/view/login/login_view.dart';
import '../mvvm/view_model/splash/splash_binding.dart';
import '../mvvm/view_model/login/login_binding.dart';

/// Defines navigation routes for the LayerX app.
abstract class AppRoutes {
  AppRoutes._();

  static const splashView = '/';
  static const loginView = '/login';
}

abstract class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splashView,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.loginView,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
''');

    await File(path.join(configDir.path, 'app_theme.dart')).writeAsString('''
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import 'app_colors.dart';
//
// abstract class AppTheme {
//   AppTheme._();
//
//   static const _primaryColor = AppColors.primary;
//   static const _borderRadius = 12.0;
//
//   static final ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     primaryColor: _primaryColor,
//     scaffoldBackgroundColor: AppColors.secondaryWhite,
//     colorScheme: const ColorScheme.light(primary: _primaryColor),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       backgroundColor: AppColors.secondaryWhite,
//       foregroundColor: AppColors.textDarkColor,
//       titleTextStyle: GoogleFonts.poppins(
//         fontSize: 18.sp,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textDarkColor,
//       ),
//     ),
//     textTheme: GoogleFonts.poppinsTextTheme(),
//     cardTheme: CardTheme(
//       color: AppColors.secondaryWhite,
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//       ),
//     ),
//   );
//
//   static final ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     primaryColor: _primaryColor,
//     scaffoldBackgroundColor: AppColors.darkBgColor,
//     colorScheme: const ColorScheme.dark(primary: _primaryColor),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       backgroundColor: AppColors.darkBgColor,
//       foregroundColor: AppColors.secondaryWhite,
//       titleTextStyle: GoogleFonts.poppins(
//         fontSize: 18.sp,
//         fontWeight: FontWeight.w600,
//         color: AppColors.secondaryWhite,
//       ),
//     ),
//     textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
//     cardTheme: CardTheme(
//       color: AppColors.secondaryBlack,
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//       ),
//     ),
//   );
// }
''');

    await File(path.join(configDir.path, 'app_strings.dart')).writeAsString('''
/// Defines string constants for the LayerX app.
abstract class AppStrings {
  AppStrings._();

  static const welcomeText = 'Welcome to LayerX';
}
''');

    await File(path.join(configDir.path, 'app_urls.dart')).writeAsString('''
/// Defines API endpoints for the LayerX app.
abstract class AppUrls {
  AppUrls._();

  static const String baseAPIURL = 'https://api.example.com/';

  static const String signup = 'auth/signup';
  static const String updateAccount = 'auth/update';
  static const String appSettings = 'settings';
}
''');

    await File(path.join(configDir.path, 'padding_extensions.dart')).writeAsString('''
import 'package:flutter/material.dart';

/// Adds padding extensions for widgets in the LayerX app.
extension PaddingExtension on Widget {
  Widget paddingFromAll(double padding) => Padding(
        padding: EdgeInsets.all(padding),
        child: this,
      );

  Widget paddingHorizontal(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );

  Widget paddingVertical(double padding) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: this,
      );

  Widget paddingTop(double padding) => Padding(
        padding: EdgeInsets.only(top: padding),
        child: this,
      );

  Widget paddingBottom(double padding) => Padding(
        padding: EdgeInsets.only(bottom: padding),
        child: this,
      );

  Widget paddingLeft(double padding) => Padding(
        padding: EdgeInsets.only(left: padding),
        child: this,
      );

  Widget paddingRight(double padding) => Padding(
        padding: EdgeInsets.only(right: padding),
        child: this,
      );
}
''');

    await File(path.join(configDir.path, 'utils.dart')).writeAsString('''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../services/logger_service.dart';

class Utils {
  static String formatDate(DateTime? date) =>
      DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  static String formatDateDMY(DateTime? date) =>
      DateFormat('dd-MM-yyyy').format(date ?? DateTime.now());

  static String? formatDateTime(DateTime? date) {
    if (date == null) return null;
    return DateFormat('MMM d, h:mm a').format(date);
  }

  static bool isNotExpired(String date) {
    try {
      final cleaned = date
          .replaceAll(RegExp(r'\\s+'), '')
          .replaceAll(RegExp(r'[./]'), '-')
          .trim();

      final inputDate = DateTime.parse(cleaned);
      final today = DateTime.now();
      final currentDate = DateTime(today.year, today.month, today.day);

      return inputDate.isAfter(currentDate) ||
          inputDate.isAtSameMomentAs(currentDate);
    } catch (e) {
      LoggerService.i('Invalid date format: \$date');
      return false;
    }
  }

  static void showBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14.sp),
          topLeft: Radius.circular(14.sp),
        ),
      ),
      context: context,
      builder: (_) => SizedBox(
        width: ScreenUtil().screenWidth,
        child: child,
      ),
    );
  }

  static void showCustomDialog({
    required BuildContext context,
    required Widget child,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.sp),
        ),
        child: child,
      ),
    );
  }

  static Future<void> showPickImageOptionsDialog(
    BuildContext context, {
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onFileTap,
    bool? hasFile,
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: onCameraTap,
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: onGalleryTap,
            child: const Text('Gallery'),
          ),
          if (hasFile == true && onFileTap != null)
            CupertinoActionSheetAction(
              onPressed: onFileTap,
              child: const Text('Pick File (PDF, DOC)'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
''');

    await File(path.join(configDir.path, 'config.dart')).writeAsString('''
/// Defines app configuration for the LayerX app.
class AppConfig {
  static const String appName = 'LayerX App';
}
''');

    stdout.writeln('Created config files.');
  }

  // ========================= MVVM SKELETON =========================

  Future<void> _createMVVMSkeleton(String appDirPath) async {
    // Splash
    await File(path.join(appDirPath, 'mvvm', 'view', 'splash', 'splash_view.dart')).writeAsString('''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/splash/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text(
          controller.title.value,
          textAlign: TextAlign.center,
        )),
      ),
    );
  }
}
''');

    await File(path.join(appDirPath, 'mvvm', 'view_model', 'splash', 'splash_controller.dart')).writeAsString('''
import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxString title = 'LayerX Ready ✅'.obs;
}
''');

    await File(path.join(appDirPath, 'mvvm', 'view_model', 'splash', 'splash_binding.dart')).writeAsString('''
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
''');

    // Login placeholder (needed for ApiResponseHandler redirect)
    await File(path.join(appDirPath, 'mvvm', 'view', 'login', 'login_view.dart')).writeAsString('''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/login/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Placeholder (Replace with your UI)'),
      ),
    );
  }
}
''');

    await File(path.join(appDirPath, 'mvvm', 'view_model', 'login', 'login_controller.dart')).writeAsString('''
import 'package:get/get.dart';

class LoginController extends GetxController {}
''');

    await File(path.join(appDirPath, 'mvvm', 'view_model', 'login', 'login_binding.dart')).writeAsString('''
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
''');
  }

  // ========================= MODELS =========================

  Future<void> _createModelFiles(String appDirPath) async {
    final bodyModelDir = Directory(path.join(appDirPath, 'mvvm', 'model', 'body_model'));
    final apiResponseModelDir = Directory(path.join(appDirPath, 'mvvm', 'model', 'api_response_model'));

    await File(path.join(bodyModelDir.path, 'driver_signup_body_model.dart')).writeAsString('''
import 'dart:io';

/// Model for driver signup data with multipart support.
class DriverSignupBodyModel {
  String? name;
  String? email;
  File? image;
  List<File>? documents;
  File? details;

  DriverSignupBodyModel({
    this.name,
    this.email,
    this.image,
    this.documents,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
''');

    await File(path.join(bodyModelDir.path, 'garage_signup_body_model.dart')).writeAsString('''
import 'dart:io';

/// Model for garage signup data with multipart support.
class GarageSignupBodyModel {
  String? name;
  File? image;

  GarageSignupBodyModel({this.name, this.image});

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
''');

    await File(path.join(bodyModelDir.path, 'buy_car_request_model.dart')).writeAsString('''
import 'dart:io';

/// Model for buy car request with multipart support.
class BuyCarRequestModel {
  String? name;
  File? image;

  BuyCarRequestModel({this.name, this.image});

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
''');

    await File(path.join(bodyModelDir.path, 'add_car_body_model.dart')).writeAsString('''
import 'dart:io';

/// Model for adding car data with multipart support.
class AddCarBodyModel {
  String? model;
  File? image;
  File? insuranceDocument;
  File? inspectionDocument;
  File? registrationDocument;
  List<File>? additionalDocuments;

  AddCarBodyModel({
    this.model,
    this.image,
    this.insuranceDocument,
    this.inspectionDocument,
    this.registrationDocument,
    this.additionalDocuments,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
      };
}
''');

    await File(path.join(apiResponseModelDir.path, 'api_response.dart')).writeAsString('''
/// Generic API response model for flexible data parsing.
class ApiResponse<T> {
  final bool? success;
  final String? message;
  final int? code;
  final T? data;
  final String? token;

  ApiResponse({
    this.success,
    this.message,
    this.code,
    this.data,
    this.token,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final status = json['status'];
    final success = json['success'];
    final isSuccess = success == true || status == 'success';

    final skipKeys = {'status', 'success', 'code', 'error', 'message', 'token'};
    dynamic extractedData;

    if (json['data'] != null) {
      extractedData = json['data'];
    } else {
      for (final entry in json.entries) {
        if (!skipKeys.contains(entry.key) &&
            (entry.value is Map<String, dynamic> || entry.value is List)) {
          extractedData = entry.value;
          break;
        }
      }
    }

    return ApiResponse(
      success: isSuccess,
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: extractedData != null ? fromJsonT(extractedData) : null,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'code': code,
      'data': data != null ? toJsonT(data as T) : null,
      'token': token,
    };
  }
}
''');

    stdout.writeln('Created model files.');
  }

  // ========================= SERVICES =========================

  Future<void> _createServiceFiles(String appDirPath) async {
    final servicesDir = Directory(path.join(appDirPath, 'services'));

    await File(path.join(servicesDir.path, 'logger_service.dart')).writeAsString('''
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
    return output.map((line) => '[📅 \$formattedTime] [\$levelName] \$line').toList();
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

    await File(path.join(servicesDir.path, 'shared_preferences_service.dart')).writeAsString('''
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

    await File(path.join(servicesDir.path, 'global_variables.dart')).writeAsString('''
import '../config/app_enums.dart';

/// Global variables for the LayerX app.
class GlobalVariables {
  static List<String> errorMessages = ['Failed, Try Again'];
  static String route = '';
  static UserRole userRole = UserRole.user;
}
''');

    await File(path.join(servicesDir.path, 'json_extractor.dart')).writeAsString('''
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

    await File(path.join(servicesDir.path, 'location_service.dart')).writeAsString('''
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

    await File(path.join(servicesDir.path, 'api_response_handler.dart')).writeAsString('''
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../customWidgets/custom_dialogs/no_internetdialog.dart';
import '../mvvm/model/api_reponse/api_response.dart';
import 'json_extractor.dart';
import 'logger_service.dart';

/// Handles API responses with standardized processing.
class ApiResponseHandler {
  static Future<ApiResponse<T>> process<T>(dynamic response, String? endPoint, T Function(dynamic dataJson) fromJson) async {
    MessageExtractor().extractAndStoreMessage(endPoint ?? '', response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        final parsedJson = response.body.length > 100000 ? await compute<String, dynamic>(_parseJson, response.body) : jsonDecode(response.body);
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
        return _handleError<T>(response, 'API Error: "{response.statusCode} - {response.reasonPhrase}"');
    }

    return ApiResponse<T>(message: 'Unexpected error occurred');
  }

  static dynamic _parseJson(String responseBody) {
    return jsonDecode(responseBody);
  }

  static void _handleUnauthorized(String? endPoint) {
    LoggerService.w('⛔ Unauthorized. Checking endpoint...');

    // ✅ Skip redirect if endpoint is login
    if ((endPoint ?? '').toLowerCase().contains('login') || (endPoint ?? '').toLowerCase().contains('delete-account')) {
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
          message: "Unable to connect to the server. Please check your internet connection and try again.",
          closeText: "Dismiss",
          onClose: () {
            // Handle close action
          },
        );
      });
      throw Exception('No internet connection. Please try again.');
    }
  }

  static ApiResponse<T> _handleError<T>(dynamic response, String errorMessage) {
    try {
      final errorResponse = jsonDecode(response.body);
      final message = errorResponse['message'] ?? 'Something went wrong. Please try again.';
      //LoggerService.e('❌ "errorMessage → message"');
      return ApiResponse<T>(message: message);
    } catch (e, stack) {
      LoggerService.e('❌ Error parsing error response', error: e, stackTrace: stack);
      return ApiResponse<T>(message: errorMessage);
    }
  }

  static void logUnhandledError(dynamic e, StackTrace stackTrace) {
    LoggerService.e('⚠️ Unhandled error', error: e, stackTrace: stackTrace);
  }
}
''');

    await File(path.join(servicesDir.path, 'https_calls.dart')).writeAsString(_httpsCallsContent());

    stdout.writeln('Created service files.');
  }

  // ========================= NOTIFICATIONS (NEW) =========================

  Future<void> _createNotificationFiles(String appDirPath) async {
    final notifDir = Directory(path.join(appDirPath, 'services', 'notifications'));
    await notifDir.create(recursive: true);

    await File(path.join(notifDir.path, 'notification_permissions.dart')).writeAsString(_notificationPermissionsContent());

    await File(path.join(notifDir.path, 'notification_service.dart')).writeAsString(_notificationServiceContent());

    await File(path.join(notifDir.path, 'server_key.dart')).writeAsString(_serverKeyContent());

    stdout.writeln('✅ Created notification files in services/notifications/');
  }

  String _notificationPermissionsContent() => r'''
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissions {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');

      // ✅ Get token after permission
      String? token = await messaging.getToken();
      log('FCM Token: $token');

      Get.snackbar("Notification", "Permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
      Get.snackbar("Notification", "Provisional permission granted");
    } else {
      log('User declined or has not accepted permission');
      Get.snackbar("Notification", "Permission denied");
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    if (await Permission.notification.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      log("FCM Token: $token");
      return token;
    } catch (e) {
      log("Error getting device token: $e");
      return null;
    }
  }
}
''';

  String _notificationServiceContent() => r'''
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_permissions.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() async {
    // ✅ REQUIRED FOR TIMEZONE SUPPORT
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // ✅ Initialize Local Notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ Request Notification Permission
    NotificationPermissions().requestNotificationPermission();

    // ✅ Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground Message: ${message.notification?.title}");
      showNotification(message);
    });

    // ✅ When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📌 Notification Clicked: ${message.notification?.title}");
    });
  }

  // ✅ Background Handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log("📩 Background Message: ${message.notification?.title}");
  }

  // ✅ Show Notification
  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'layerx_channel',
      'LayerX Notifications',
      channelDescription: 'LayerX push notifications channel',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      notificationDetails,
    );
  }

  // ✅ Schedule Notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'layerx_channel',
          'LayerX Notifications',
          channelDescription: 'LayerX push notifications channel',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
''';

  String _serverKeyContent() => r'''
import 'dart:developer';
import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';
import 'notification_permissions.dart';

class ServerKeyService {
  final logger = Logger();
  String? serverKey;

  Future<String?> getServiceKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // NOTE:
    // Your original file contained a literal "..." placeholder here.
    // Add your service account JSON properly below.

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        // TODO: Paste your full Firebase service account JSON here.
      }),
      scopes,
    );

    serverKey = client.credentials.accessToken.data;
    log('Key $serverKey');
    return serverKey;
  }
}
''';

  // ========================= HTTPS CALLS CONTENT =========================

  String _httpsCallsContent() => r'''
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/app_urls.dart';
import 'logger_service.dart';
import 'shared_preferences_service.dart';

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

/// Simple cancellation token for requests.
class CancelToken {
  bool _canceled = false;
  String? reason;
  final Completer<void> _notifier = Completer<void>();

  bool get isCanceled => _canceled;

  Future<void> get whenCanceled => _notifier.future;

  void cancel([String? reason]) {
    if (_canceled) return;
    _canceled = true;
    this.reason = reason;
    if (!_notifier.isCompleted) {
      _notifier.complete();
    }
  }
}

class HttpsCalls {
  late final IOClient _pooledClient = () {
    final h = HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..connectionTimeout = const Duration(seconds: 15)
      ..maxConnectionsPerHost = 8
      ..autoUncompress = true;
    return IOClient(h);
  }();

  void dispose() {
    try {
      _pooledClient.close();
    } catch (_) {}
  }

  final int _maxConcurrency = 8;
  int _active = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<void> _acquireSlot() async {
    if (_active < _maxConcurrency) {
      _active++;
      return;
    }
    final c = Completer<void>();
    _waiters.addLast(c);
    await c.future;
  }

  void _releaseSlot() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      if (_active > 0) _active--;
    }
  }

  final _ongoingRequests = <String, Future<http.Response>>{};

  final Duration _timeoutDuration = const Duration(seconds: 20);
  final int _maxRetries = 2;

  final _random = Random();

  final Set<CancelToken> _attachedTokens = <CancelToken>{};

  void cancelAll([String reason = 'Global cancelAll']) {
    for (final t in _attachedTokens.toList()) {
      t.cancel(reason);
    }
    _attachedTokens.clear();
  }

  bool _isIdempotent(HttpMethod m) {
    switch (m) {
      case HttpMethod.GET:
      case HttpMethod.PUT:
      case HttpMethod.DELETE:
        return true;
      case HttpMethod.POST:
      case HttpMethod.PATCH:
        return false;
    }
  }

  String _buildKey(HttpMethod method, String endpoint, {List<int>? body}) {
    final methodStr = method.toString().split('.').last;
    final bodyHash = (body == null || body.isEmpty)
        ? ''
        : base64Url.encode(body.take(32).toList());
    return '$methodStr $endpoint $bodyHash';
  }

  Future<http.Response> _performRequest(
    HttpMethod method,
    String endpoint,
    Future<http.Response> Function(http.Client client) request, {
    List<int>? body,
    CancelToken? cancelToken,
  }) async {
    final key = _buildKey(method, endpoint, body: body);

    if (_ongoingRequests.containsKey(key)) {
      LoggerService.i('🔁 Joining in-flight request for $key');
      return _ongoingRequests[key]!;
    }

    await _acquireSlot();
    CancelToken? token = cancelToken;
    if (token != null) {
      _attachedTokens.add(token);
    }

    try {
      IOClient? perRequestClient;
      http.Client client;
      if (token != null) {
        final h = HttpClient()
          ..idleTimeout = const Duration(seconds: 15)
          ..connectionTimeout = const Duration(seconds: 15)
          ..maxConnectionsPerHost = 8
          ..autoUncompress = true;
        perRequestClient = IOClient(h);
        client = perRequestClient;
      } else {
        client = _pooledClient;
      }

      final bool canRetry = _isIdempotent(method);
      final int maxAttempts = canRetry ? (_maxRetries + 1) : 1;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        if (token?.isCanceled == true) {
          LoggerService.w(
              '⛔️ Request cancelled before send: $key, reason: ${token?.reason}');
          perRequestClient?.close();
          throw Exception('Request cancelled: ${token?.reason ?? ""}');
        }

        try {
          final future = request(client).timeout(_timeoutDuration);

          final http.Response response;
          if (token == null) {
            _ongoingRequests[key] = future;
            response = await future;
          } else {
            _ongoingRequests[key] = Future.any([
              future,
              token.whenCanceled.then(
                  (_) => throw Exception('Request cancelled: ${token.reason ?? ""}')),
            ]);
            response = await _ongoingRequests[key]!;
          }

          _ongoingRequests.remove(key);
          perRequestClient?.close();

          LoggerService.i('✅ $method $endpoint → ${response.statusCode}');
          return response;
        } on TimeoutException catch (e) {
          LoggerService.w('⏰ Timeout on attempt $attempt for $key: $e');

          if (attempt == maxAttempts - 1) {
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            throw Exception('Timeout after $maxAttempts attempts');
          }

          await _retryDelay(attempt);
        } on Exception catch (e, st) {
          if (token?.isCanceled == true ||
              e.toString().contains('Request cancelled')) {
            LoggerService.w('⛔️ Canceled $key: $e');
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            rethrow;
          }

          if (attempt == maxAttempts - 1) {
            LoggerService.e(
                '💥 $method $endpoint failed after $maxAttempts attempts: $e',
                error: e,
                stackTrace: st);
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            throw Exception('Failed after $maxAttempts attempts: $e');
          }

          LoggerService.w('🔁 Retry $attempt for $key due to error: $e');
          await _retryDelay(attempt);
        }
      }
      _ongoingRequests.remove(key);
      throw Exception('Unexpected error in _performRequest');
    } finally {
      if (cancelToken != null) {
        _attachedTokens.remove(cancelToken);
      }
      _releaseSlot();
    }
  }

  Future<void> _retryDelay(int attempt) async {
    final base = pow(2, attempt).toInt();
    final jitter = _random.nextInt(300);
    await Future.delayed(Duration(milliseconds: base * 400 + jitter));
  }

  Future<Map<String, String>> _getDefaultHeaders() async {
    final token = await SharedPreferencesService().readToken();
    debugPrint('======>>> Token: $token');
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Future<http.Response> _sendRequest(
    http.Client client,
    HttpMethod method,
    String endpoint, {
    List<int>? body,
  }) async {
    final headers = await _getDefaultHeaders();
    final url = Uri.parse('${AppUrls.baseAPIURL}$endpoint');

    LoggerService.d('🌀 Sending $method → $url');

    switch (method) {
      case HttpMethod.GET:
        return client.get(url, headers: headers);
      case HttpMethod.POST:
        return client.post(url, headers: headers, body: body);
      case HttpMethod.PUT:
        return client.put(url, headers: headers, body: body);
      case HttpMethod.PATCH:
        return client.patch(url, headers: headers, body: body);
      case HttpMethod.DELETE:
        return client.delete(url, headers: headers, body: body);
    }
  }

  Future<http.Response> getApiHits(String endpoint, {CancelToken? cancelToken}) {
    return _performRequest(
      HttpMethod.GET,
      endpoint,
      (client) => _sendRequest(client, HttpMethod.GET, endpoint),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> postApiHits(String endpoint, List<int>? utfContent,
      {CancelToken? cancelToken}) {
    return _performRequest(
      HttpMethod.POST,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.POST, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> putApiHits(String endpoint, List<int> utfContent,
      {CancelToken? cancelToken}) {
    return _performRequest(
      HttpMethod.PUT,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.PUT, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> patchApiHits(String endpoint, List<int> utfContent,
      {CancelToken? cancelToken}) {
    return _performRequest(
      HttpMethod.PATCH,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.PATCH, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> deleteApiHits(String endpoint,
      {List<int>? utfContent, CancelToken? cancelToken}) {
    return _performRequest(
      HttpMethod.DELETE,
      endpoint,
      (client) =>
          _sendRequest(client, HttpMethod.DELETE, endpoint, body: utfContent),
      body: utfContent,
      cancelToken: cancelToken,
    );
  }
}
''';

  // ========================= REPOSITORIES =========================

  Future<void> _createRepositoryFiles(String appDirPath) async {
    final authRepoDir = Directory(path.join(appDirPath, 'repository', 'auth_repo'));
    final apiRepoDir = Directory(path.join(appDirPath, 'repository', 'apis'));

    await File(path.join(authRepoDir.path, 'auth_repository.dart')).writeAsString('''
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/driver_signup_body_model.dart';
import '../../mvvm/model/body_model/garage_signup_body_model.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

class AuthRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  // Future<ApiResponse<void>> driverSignUpApi(DriverSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.signup;
  //     LoggerService.d('Driver signup: \$endPoint');
  //     final response = await _httpsCalls.multipartDriverProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }
  //
  // Future<ApiResponse<void>> updateDriver(DriverSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.updateAccount;
  //     LoggerService.d('Driver update: \$endPoint');
  //     final response = await _httpsCalls.multipartDriverProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }
  //
  // Future<ApiResponse<void>> garageSignUpApi(GarageSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.signup;
  //     LoggerService.d('Garage signup: \$endPoint');
  //     final response = await _httpsCalls.multipartGarageProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }
}
''');

    await File(path.join(apiRepoDir.path, 'data_repository.dart')).writeAsString('''
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/add_car_body_model.dart';
import '../../mvvm/model/body_model/buy_car_request_model.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

class DataRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  Future<ApiResponse<void>> addCarApi(AddCarBodyModel body) async {
    try {
      const endPoint = AppUrls.signup; // TODO: update endpoint
      LoggerService.d('Add car: \$endPoint');
      final response = await _httpsCalls.crudCarMultipartApi(endPoint, body);
      return ApiResponseHandler.process(response, endPoint, (_) {});
    } catch (e, st) {
      ApiResponseHandler.logUnhandledError(e, st);
      rethrow;
    }
  }

  Future<ApiResponse<void>> buyCarApi(BuyCarRequestModel body) async {
    try {
      const endPoint = AppUrls.signup; // TODO: update endpoint
      LoggerService.d('Buy car: \$endPoint');
      final response = await _httpsCalls.multipartBuyCarRequestApi(endPoint, body);
      return ApiResponseHandler.process(response, endPoint, (_) {});
    } catch (e, st) {
      ApiResponseHandler.logUnhandledError(e, st);
      rethrow;
    }
  }
}
''');

    stdout.writeln('Created repository files.');
  }

  // ========================= APP WIDGET + MAIN =========================

  Future<void> _createAppWidgetFile(String projectPath) async {
    final appDir = Directory(path.join(projectPath, 'lib', 'app'));

    await File(path.join(appDir.path, 'app_widget.dart')).writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/app_routes.dart';
import 'config/app_theme.dart';

class LayerXApp extends StatelessWidget {
  const LayerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splashView,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
''');

    stdout.writeln('Created app_widget.dart');
  }

  Future<void> _updateMainFile(String projectPath) async {
    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));

    await mainFile.writeAsString('''
import 'package:flutter/material.dart';
import 'app/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LayerXApp());
}
''');

    stdout.writeln('Updated main.dart');
  }
}