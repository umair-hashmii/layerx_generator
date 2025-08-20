/// A Flutter package that auto-generates the LayerX directory structure for scalable MVVM projects.
///
/// The `layerx_generator` package simplifies the setup of a Flutter project by generating
/// a clean MVVM (Model-View-ViewModel) directory structure under `lib/app/`. It includes
/// pre-configured utilities for HTTP requests, local storage, location services, logging,
/// and API response handling, all integrated with GetX for state management, navigation,
/// and dependency injection.
///
/// ## Features
/// - Generates a well-organized MVVM directory structure with `config/`, `mvvm/`, `repository/`, `services/`, and `widgets/` directories.
/// - Includes services: `HttpsCalls` (with multipart support), `SharedPreferencesService`, `LocationService`, `ApiResponseHandler`, and `LoggerService` (with custom formatting).
/// - Provides a dynamic `ApiResponse<T>` model for flexible API data parsing.
/// - Integrates GetX for navigation and state management.
/// - Supports responsive design with `flutter_screenutil`.
/// - Includes standardized repositories (`AuthRepository`, `DataRepository`) for API interactions.
///
/// ## Installation
/// Add `layerx_generator` as a dev dependency in your `pubspec.yaml`:
/// ```yaml
/// dev_dependencies:
///   layerx_generator: ^2.0.0
/// ```
/// Run:
/// ```bash
/// flutter pub get
/// ```
///
/// ## Usage
/// Generate the LayerX structure using the command line:
/// ```bash
/// dart run layerx_generator --path .
/// ```
/// Or programmatically:
/// ```dart
/// import 'package:layerx_generator/layerx_generator.dart';
/// import 'dart:io';
///
/// void main() async {
///   final generator = LayerXGenerator(Directory.current.path);
///   await generator.generate();
/// }
/// ```
///
/// ## Generated Structure
/// - `config/`: App configurations (e.g., `AppUrls`, `AppRoutes`, `AppColors`).
/// - `mvvm/`: Models (`ApiResponse<T>`, body models), views, and view models.
/// - `repository/`: API and local data repositories (`AuthRepository`, `DataRepository`).
/// - `services/`: Utilities for HTTP (`HttpsCalls`), location (`LocationService`), logging (`LoggerService`), and more.
/// - `widgets/`: Custom widget directory.
/// - Updates `main.dart` and `pubspec.yaml` for immediate use.
///
/// ## Example
/// See the [example/](https://github.com/[your-username]/layerx_generator/tree/main/example) directory for a sample project using the generated structure.
///
/// ## Documentation
/// Full documentation is available on [pub.dev](https://pub.dev/packages/layerx_generator).
library layerx_generator;

import 'dart:io';
import 'package:path/path.dart' as path;

/// Generates the LayerX directory structure for a Flutter project.
///
/// The `LayerXGenerator` class is the main entry point for the package. It creates
/// a predefined MVVM structure under `lib/app/`, including configuration files,
/// services, repositories, and models, all integrated with GetX.
///
/// ## Example
/// ```dart
/// import 'package:layerx_generator/layerx_generator.dart';
/// import 'dart:io';
///
/// void main() async {
///   final generator = LayerXGenerator(Directory.current.path);
///   await generator.generate();
///   print('LayerX structure generated successfully!');
/// }
/// ```
class LayerXGenerator {
  /// The path to the Flutter project directory where the LayerX structure will be generated.
  final String projectPath;

  /// Creates a new instance of [LayerXGenerator].
  ///
  /// ## Parameters
  /// - [projectPath]: The path to the Flutter project directory. Must be a valid directory.
  ///
  /// ## Throws
  /// - [Exception]: If the [projectPath] does not exist.
  LayerXGenerator(this.projectPath);

  /// Generates the LayerX directory structure and updates necessary files.
  ///
  /// Creates:
  /// - `lib/app/config/`: Configuration files (e.g., colors, routes).
  /// - `lib/app/mvvm/`: Model, view, and view model directories.
  /// - `lib/app/repository/`: Repositories for API and local data.
  /// - `lib/app/services/`: Services for HTTP, location, logging, etc.
  /// - `lib/app/widgets/`: Custom widget directory.
  ///
  /// Updates:
  /// - `lib/app/app_widget.dart`: Root widget with GetX and `flutter_screenutil`.
  /// - `lib/main.dart`: Entry point using `LayerXApp`.
  /// - `pubspec.yaml`: Adds required dependencies (e.g., `get`, `intl`).
  ///
  /// ## Throws
  /// - [Exception]: If the project directory is invalid or file operations fail.
  Future<void> generate() async {
    try {
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        throw Exception('Project directory does not exist: $projectPath');
      }

      final appDir = Directory(path.join(projectPath, 'lib', 'app'));
      await appDir.create(recursive: true);

      final directories = [
        'config',
        'mvvm/model/body_model',
        'mvvm/model/response_model',
        'mvvm/model/api_response_model',
        'mvvm/view',
        'mvvm/view_model',
        'repository/auth_repo',
        'repository/firebase',
        'repository/local_db',
        'repository/apis',
        'services',
        'widgets',
      ];

      for (final dir in directories) {
        final fullPath = path.join(appDir.path, dir);
        await Directory(fullPath).create(recursive: true);
        print('Created directory: $fullPath');
      }

      await _createConfigFiles(appDir.path);
      await _createModelFiles(appDir.path);
      await _createServiceFiles(appDir.path);
      await _createRepositoryFiles(appDir.path);
      await _createAppWidgetFile(projectPath);
      await _updateMainFile(projectPath);
      // await _updatePubspecFile(projectPath);
    } catch (e) {
      print('Error generating LayerX structure: $e');
      rethrow;
    }
  }

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
  static Color lightBgButtonColor = Color(0xfff5f5f5).withOpacity(0.05);
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
  static const Color positiveGreen = Color(0xff21D575);
  static const Color textDarkColor = Color(0xff1B0036);
  static const Color negativeRed = Color(0xffEA4334);
  static const Color transparent = Colors.transparent;
  static const Color textLightBlack = Color(0xff777E90);
  static const Color bgColor = Color(0xFFF0F1F6);
  static const Color darkBgColor = Color(0xFF1B1C1E);
  static const Color borderColor = Color(0xFFE6E7E9);
  static const Color borderGrey = Color(0xFFD7DDE5);
  static const Color lightTextColor = Color(0xFF777E90);

}
''');

    await File(path.join(configDir.path, 'app_enums.dart')).writeAsString('''
/// Defines enums for the LayerX app.
enum UserRole { USER, BUSINESS }
''');

    await File(path.join(configDir.path, 'app_routes.dart')).writeAsString('''
/// Defines navigation routes for the LayerX app.
abstract class AppRoutes {
  AppRoutes._();

  static const splashView = '/splashView';
  static const garageMaintenanceRecordView = '/garageMaintenanceRecordView';
 
}

abstract class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splashView,
      page: () => SplashView(),
      binding: BindingsBuilder(() {
        // Get.lazyPut<GetStartedController>(() => GetStartedController());
      }),
    ),
    GetPage(
      name: AppRoutes.garageMaintenanceRecordView,
      page: () => ImageViewerScreen(),
    ),

   
  ];
}

''');

    await File(path.join(configDir.path, 'app_theme.dart')).writeAsString('''
/// Defines navigation routes for the LayerX app.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static const _primaryColor = AppColors.primary;
  static const _secondaryColor = AppColors.secondaryWhite;
  static const _borderRadius = 12.0;
  static const _buttonPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 20);

  // Container colors for light and dark themes
  static const Color _lightContainerColor = AppColors.secondaryWhite; // For light theme containers
  static const Color _darkContainerColor = AppColors.darkBgColor; // For dark theme containers

  static const Color _lightScaffoldColor = AppColors.secondaryWhite;
  static const Color _darkScaffoldColor = Color(0xff1B1C1E);

  static final ThemeData lightTheme = ThemeData(
    fontFamily: "Poppins",
    
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _lightScaffoldColor,
    colorScheme: ColorScheme.light(primary: _primaryColor, secondary: _secondaryColor),
    appBarTheme: _appBarTheme(_primaryColor, AppColors.textDarkColor),
    // textTheme: _lightTextTheme,
    cardColor: _lightContainerColor, // Light theme container color
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.light),
    inputDecorationTheme: _inputDecorationTheme(AppColors.secondaryBlack, AppColors.textLightBlack),
    iconTheme: IconThemeData(color: _primaryColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: _primaryColor, foregroundColor: AppColors.secondaryWhite),
    bottomNavigationBarTheme: _bottomNavigationBarTheme(AppColors.bgColor, _primaryColor, AppColors.textDarkColor),
    cardTheme: _cardTheme(_lightContainerColor, AppColors.borderGrey), // Light theme card color
    switchTheme: _switchTheme(_primaryColor),
    checkboxTheme: _checkboxTheme(_primaryColor),
    sliderTheme: _sliderTheme(_primaryColor),
    tabBarTheme: _tabBarTheme(_primaryColor, AppColors.textDarkColor),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: _primaryColor),
    dividerTheme: DividerThemeData(color: AppColors.textLightBlack, thickness: 1),
    tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(_borderRadius))),
    popupMenuTheme: PopupMenuThemeData(color: AppColors.secondaryWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius))),
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: "Poppins",
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _darkScaffoldColor,
    colorScheme: ColorScheme.dark(primary: _primaryColor, secondary: _secondaryColor),
    appBarTheme: _appBarTheme(AppColors.secondaryBlack, AppColors.secondaryWhite),
    // textTheme: _darkTextTheme,
    cardColor: _darkContainerColor, // Dark theme container color
    elevatedButtonTheme: _elevatedButtonTheme(Brightness.dark),
    inputDecorationTheme: _inputDecorationTheme(AppColors.secondaryBlack, AppColors.textLightBlack),
    iconTheme: IconThemeData(color: AppColors.secondaryWhite),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: _primaryColor, foregroundColor: AppColors.secondaryWhite),
    bottomNavigationBarTheme: _bottomNavigationBarTheme(AppColors.secondaryBlack, _primaryColor, AppColors.secondaryWhite),
    cardTheme: _cardTheme(_darkContainerColor, AppColors.textLightBlack), // Dark theme card color
    switchTheme: _switchTheme(_primaryColor),
    checkboxTheme: _checkboxTheme(_primaryColor),
    sliderTheme: _sliderTheme(_primaryColor),
    tabBarTheme: _tabBarTheme(_primaryColor, AppColors.secondaryWhite),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: _primaryColor),
    dividerTheme: DividerThemeData(color: AppColors.textLightBlack, thickness: 1),
    tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(_borderRadius))),
    popupMenuTheme: PopupMenuThemeData(color: AppColors.secondaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius))),
  );

  static AppBarTheme _appBarTheme(Color bgColor, Color fgColor) => AppBarTheme(
    backgroundColor: bgColor,
    foregroundColor: fgColor,
    elevation: 3,
    titleTextStyle: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: fgColor),
  );

  static BottomNavigationBarThemeData _bottomNavigationBarTheme(Color bgColor, Color selected, Color unselected) => BottomNavigationBarThemeData(
    backgroundColor: bgColor,
    selectedItemColor: selected,
    unselectedItemColor: unselected,
  );

  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textDarkColor),
    displayMedium: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.normal, color: AppColors.textDarkColor),
    bodyLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.normal, color: AppColors.textDarkColor),
    bodyMedium: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textLightBlack),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.secondaryWhite),
    displayMedium: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.normal, color: AppColors.secondaryWhite),
    bodyLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.normal, color: AppColors.secondaryWhite),
    bodyMedium: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textLightBlack),
  );

  static ElevatedButtonThemeData _elevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brightness == Brightness.dark ? AppColors.borderGrey : _primaryColor,
        foregroundColor: AppColors.secondaryWhite,
        textStyle: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        padding: _buttonPadding,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color fillColor, Color hintColor) => InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_borderRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _primaryColor, width: 2), borderRadius: BorderRadius.circular(_borderRadius)),
    hintStyle: GoogleFonts.poppins(color: hintColor),
  );

  static CardTheme _cardTheme(Color bgColor, Color shadowColor) => CardTheme(
    color: bgColor,
    shadowColor: shadowColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
    elevation: 4,
  );

  static SwitchThemeData _switchTheme(Color activeColor) => SwitchThemeData(
    trackColor: MaterialStateProperty.resolveWith<Color>((states) => states.contains(MaterialState.selected) ? activeColor : Colors.grey),
    thumbColor: MaterialStateProperty.all(AppColors.secondaryWhite),
  );

  static CheckboxThemeData _checkboxTheme(Color activeColor) => CheckboxThemeData(
    checkColor: MaterialStateProperty.all(AppColors.secondaryWhite),
    fillColor: MaterialStateProperty.all(activeColor),
  );

  static SliderThemeData _sliderTheme(Color activeColor) => SliderThemeData(
    activeTrackColor: activeColor,
    inactiveTrackColor: activeColor.withOpacity(0.5),
    thumbColor: activeColor,
    overlayColor: activeColor.withOpacity(0.2),
    valueIndicatorColor: activeColor,
  );

  static TabBarTheme _tabBarTheme(Color indicatorColor, Color labelColor) => TabBarTheme(
    indicator: BoxDecoration(border: Border(bottom: BorderSide(color: indicatorColor, width: 2))),
    labelColor: labelColor,
    unselectedLabelColor: AppColors.textLightBlack,
  );
}
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

    await File(path.join(configDir.path, 'app_text_style.dart'))
        .writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines text styles for the LayerX app.
abstract class AppTextStyles {
  AppTextStyles._();

  static TextStyle customText({
    Color? color,
    Paint? foreground,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double fontSize = 12,
    double? height,
  }) {
    // Using Get.textTheme.displayMedium everywhere
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: fontSize.sp,
      color: color,
      foreground: foreground,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customTextLexend({
    Color? color,
    double? height,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? fontSize,
    TextDecoration decoration = TextDecoration.none,
    Color? decorationColor,
  }) {
    return GoogleFonts.lexend(
        fontSize: fontSize ?? 14.sp,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        decoration: decoration,
        height: height,
        decorationColor: decorationColor);
  }

  static TextStyle customText10({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 10.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText12({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 12.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText14({
    Color? color,
    double? height,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    TextDecoration decoration = TextDecoration.none,
    Color? decorationColor,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 14.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
      decorationColor: decorationColor,
    );
  }

  static TextStyle customText16({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? height,
    TextDecoration decoration = TextDecoration.none,
    Color? decorationColor,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 16.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      height: height,
    );
  }

  static TextStyle customText32({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    TextDecoration decoration = TextDecoration.none,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 32.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle customText38({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    TextDecoration decoration = TextDecoration.none,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 38.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle customText18({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 18.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText20({
    Color? color,
    double? height,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 20.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText22({
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
    double? height,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 22.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText24({
    double? height,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 24.sp,
      height: height,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle customText26({
    Color? color,
    double? height,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 26.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customText28({
    Color? color,
    double? height,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return Get.textTheme.displayMedium!.copyWith(
      fontSize: 28.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle customTextPoppins({
    Color? color,
    double? fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
''');

    await File(path.join(configDir.path, 'padding_extensions.dart'))
        .writeAsString('''
import 'package:flutter/material.dart';

/// Adds padding extensions for widgets in the LayerX app.
extension PaddingExtension on Widget {

  Widget paddingFromAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  Widget paddingHorizontal(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  Widget paddingVertical(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }

  Widget paddingRight(double padding) {
    return Padding(
      padding: EdgeInsets.only(right: padding),
      child: this,
    );
  }

  Widget paddingLeft(double padding) {
    return Padding(
      padding: EdgeInsets.only(left: padding),
      child: this,
    );
  }

  Widget paddingTop(double padding) {
    return Padding(
      padding: EdgeInsets.only(top: padding),
      child: this,
    );
  }

  Widget paddingBottom(double padding) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: this,
    );
  }
}
''');

    await File(path.join(configDir.path, 'utils.dart')).writeAsString('''
/// Provides utility functions for the LayerX app.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date ?? DateTime.now());
  }

  static String formatDateDMY(DateTime? date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date ?? DateTime.now());
  }

  static calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String? formatDateTime(DateTime? date) {
    if (date == null) return null;
    return DateFormat('MMM d, h:mm a').format(date); // e.g., Apr 18, 3:45 PM
  }

  static bool isNotExpired(String date) {
    try {
      final cleanedDate = date
          .replaceAll(RegExp(r'\s+'), '') // Remove all spaces
          .replaceAll(RegExp(r'[./]'), '-') // Replace '/' and '.' with '-'
          .trim();

      final DateTime inputDate = DateTime.parse(cleanedDate);

      final DateTime today = DateTime.now();
      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      return inputDate.isAfter(currentDate) ||
          inputDate.isAtSameMomentAs(currentDate);
    } catch (e) {
      LoggerService.i("Invalid date format or error parsing date: e");
      return false;
    }
  }

  static void showBottomSheet(
      {required BuildContext context, required Widget child}) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(14.sp),
              topLeft: Radius.circular(14.sp))),
      context: context,
      builder: (context) {
        return Container(
          width: ScreenUtil().screenWidth,
          child: child,
        );
      },
    );
  }

  static void showCustomDialog(
      {required BuildContext context, required Widget child}) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing when tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.sp), // Rounded corners for the dialog
          ),
          child: child, // Your custom widget inside the dialog
        );
      },
    );
  }

  static Future<void> showPickImageOptionsDialog(
    BuildContext context, {
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onFileTap, // <-- made nullable
    bool? hasFile, // <-- nullable param
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: onCameraTap,
            child: const Text("Camera"),
          ),
          CupertinoActionSheetAction(
            onPressed: onGalleryTap,
            child: const Text("Gallery"),
          ),
          if (hasFile == true && onFileTap != null) // <-- safe null check
            CupertinoActionSheetAction(
              onPressed: onFileTap,
              child: const Text("Pick File (PDF, DOC)"),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  static showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
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

    print('Created config files in config/');
  }

  Future<void> _createModelFiles(String appDirPath) async {
    final bodyModelDir =
        Directory(path.join(appDirPath, 'mvvm', 'model', 'body_model'));
    final apiResponseModelDir =
        Directory(path.join(appDirPath, 'mvvm', 'model', 'api_response_model'));

    await File(path.join(bodyModelDir.path, 'driver_signup_body_model.dart'))
        .writeAsString('''
/// Model for driver signup data with multipart support.
class DriverSignupBodyModel {
  String? name;
  String? email;
  File? image;
  List<File>? documents;
  File? details;

  DriverSignupBodyModel({this.name, this.email, this.image, this.documents, this.details});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
''');

    await File(path.join(bodyModelDir.path, 'garage_signup_body_model.dart'))
        .writeAsString('''
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

    await File(path.join(bodyModelDir.path, 'buyCar_request_model.dart'))
        .writeAsString('''
/// Model for garage signup data with multipart support.
class BuyCarRequestModel {
  String? name;
  File? image;

  BuyCarRequestModel({this.name, this.image});

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
''');

    await File(path.join(bodyModelDir.path, 'add_car_body_model.dart'))
        .writeAsString('''
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

    await File(path.join(apiResponseModelDir.path, 'api_response.dart'))
        .writeAsString('''
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

    // First try 'data' if it exists
    if (json['data'] != null) {
      extractedData = json['data'];
    } else {
      // Otherwise try to find any nested Map or List not part of skipKeys
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

    print('Created model files in mvvm/model/');
  }

  Future<void> _createServiceFiles(String appDirPath) async {
    final servicesDir = Directory(path.join(appDirPath, 'services'));

    await File(path.join(servicesDir.path, 'https_calls.dart'))
        .writeAsString('''
      import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/app_urls.dart';
import '../config/global_variables.dart';
import 'internet_service.dart';
import 'logger_service.dart';
import 'shared_preferences_service.dart';

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }
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
    if (!_notifier.isCompleted) _notifier.complete();
  }
}

class HttpsCalls {
// lower CPU per call.
  late final IOClient _pooledClient = () {
    final h = HttpClient()
      ..idleTimeout = const Duration(seconds: 15)
      ..connectionTimeout = const Duration(seconds: 15)
      ..maxConnectionsPerHost = 8
      ..autoUncompress = true;
    return IOClient(h);
  }();

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
      _active = (_active > 0) ? _active - 1 : 0;
    }
  }

  final _ongoingRequests = <String, Future<http.Response>>{};
  final Duration _timeoutDuration = const Duration(seconds: 20);
  final int _maxRetries = 2;
  final _random = Random();

  Future<http.Response> _performRequest(
      String key,
      Future<http.Response> Function(http.Client client) request, {
        CancelToken? cancelToken,
      }) async {
    final hasInternet = await InternetService.hasWorkingInternet();
    LoggerService.d('Internet status: \$hasInternet');

    if (!hasInternet) {
      GlobalVariables.errorMessages = ["No internet connection"];
      return http.Response('No internet connection', 503);
    }

    if (_ongoingRequests.containsKey(key)) {
      return _ongoingRequests[key]!;
    }

    await _acquireSlot();
    try {
      IOClient? perRequestClient;
      http.Client client;
      if (cancelToken != null) {
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
      for (int attempt = 0; attempt <= _maxRetries; attempt++) {
        if (cancelToken?.isCanceled == true) {
          LoggerService.w('Request cancelled for \$key: \${cancelToken?.reason}');
          perRequestClient?.close();
          throw Exception('Request cancelled: \${cancelToken?.reason ?? ""}');
        }

        try {
          final future = request(client).timeout(_timeoutDuration);
          final response = (cancelToken == null)
              ? await (_ongoingRequests[key] = future)
              : await (_ongoingRequests[key] = Future.any([
            future,
            cancelToken.whenCanceled.then((_) => throw Exception('Request cancelled: \${cancelToken.reason ?? ""}')),
          ]));

          _ongoingRequests.remove(key);
          LoggerService.i('Request succeeded for \$key');
          perRequestClient?.close();
          return response;
        } on TimeoutException catch (e) {
          if (attempt == _maxRetries) {
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            LoggerService.e('Request timed out after \$_maxRetries retries: \$e');
            throw Exception('Timeout after \$_maxRetries retries');
          }
          await _retryDelay(attempt);
        } on Exception catch (e, st) {
          if (cancelToken?.isCanceled == true ||
              e.toString().contains('Request cancelled')) {
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            LoggerService.w('Canceled \$key: \$e');
            rethrow;
          }

          if (attempt == _maxRetries) {
            _ongoingRequests.remove(key);
            perRequestClient?.close();
            LoggerService.e('Request failed after \$_maxRetries retries: \$e', error: e, stackTrace: st);
            throw Exception('Failed after retries: \$e');
          }
          await _retryDelay(attempt);
        }
      }

      _ongoingRequests.remove(key);
      perRequestClient?.close();
      throw Exception('Failed to perform request');
    } finally {
      _releaseSlot();
    }
  }

  Future<void> _retryDelay(int attempt) async {
    final base = pow(2, attempt).toInt();
    final jitter = _random.nextInt(400);
    await Future.delayed(Duration(milliseconds: base * 500 + jitter));
  }

  Future<Map<String, String>> _getDefaultHeaders() async {
    final token = await SharedPreferencesService().readToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer \$token',
    };
  }


  Future<http.Response> _sendRequest(
      http.Client client,
      HttpMethod method,
      String lControllerUrl, {
        List<int>? body,
      }) async {
    final headers = await _getDefaultHeaders();
    final url = Uri.parse(AppUrls.baseAPIURL + lControllerUrl);
    LoggerService.d('Sending \$method request to \$url');

    switch (method) {
      case HttpMethod.GET:
        return await client.get(url, headers: headers);
      case HttpMethod.POST:
        return await client.post(url, headers: headers, body: body);
      case HttpMethod.PUT:
        return await client.put(url, headers: headers, body: body);
      case HttpMethod.PATCH:
        return await client.patch(url, headers: headers, body: body);
      case HttpMethod.DELETE:
        return await client.delete(url, headers: headers, body: body);
    }
  }

  Future<http.Response> getApiHits(String lControllerUrl, {CancelToken? cancelToken}) {
    return _performRequest(
      lControllerUrl,
          (client) => _sendRequest(client, HttpMethod.GET, lControllerUrl),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> postApiHits(String lControllerUrl, List<int>? lUtfContent, {CancelToken? cancelToken}) {
    return _performRequest(
      lControllerUrl,
          (client) => _sendRequest(client, HttpMethod.POST, lControllerUrl, body: lUtfContent),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> putApiHits(String lControllerUrl, List<int> lUtfContent, {CancelToken? cancelToken}) {
    return _performRequest(
      lControllerUrl,
          (client) => _sendRequest(client, HttpMethod.PUT, lControllerUrl, body: lUtfContent),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> patchApiHits(String lControllerUrl, List<int> lUtfContent, {CancelToken? cancelToken}) {
    return _performRequest(
      lControllerUrl,
          (client) => _sendRequest(client, HttpMethod.PATCH, lControllerUrl, body: lUtfContent),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> deleteApiHits(String lControllerUrl, {List<int>? lUtfContent, CancelToken? cancelToken}) {
    return _performRequest(
      lControllerUrl,
          (client) => _sendRequest(client, HttpMethod.DELETE, lControllerUrl, body: lUtfContent),
      cancelToken: cancelToken,
    );
  }

  Future<http.Response> _genericMultipartRequest(
      http.Client client,
      String endpointUrl,
      dynamic model, {
        Map<String, dynamic Function()>? fileExtractors,
        String? type,
      }) async {
    final token = await SharedPreferencesService().readToken();
    final url = Uri.parse(AppUrls.baseAPIURL + endpointUrl);
    final request = http.MultipartRequest(type ?? 'POST', url);
    request.headers.addAll({
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer \$token',
    });

    final json = model.toJson();
    json.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          request.fields['\$key[\$i]'] = value[i].toString();
        }
      } else if (value is String || value is num || value is bool) {
        request.fields[key] = value.toString();
      }
    });

    if (fileExtractors != null) {
      for (var entry in fileExtractors.entries) {
        final fKey = entry.key;
        final v = entry.value();
        if (v is File) {
          request.files.add(await http.MultipartFile.fromPath(fKey, v.path));
        } else if (v is List<File>) {
          for (final f in v) {
            request.files.add(await http.MultipartFile.fromPath(fKey, f.path));
          }
        }
      }
    }

    LoggerService.d('Sending multipart request to \$endpointUrl');
    final streamedResponse = await client.send(request);
    return await http.Response.fromStream(streamedResponse);
  }


}

      
      ''');

    await File(path.join(servicesDir.path, 'shared_preferences_service.dart'))
        .writeAsString('''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Service for managing local storage using SharedPreferences.
class SharedPreferencesService {
  static const String _keyDataModel = 'data_model';
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
    final token = prefs.getString(_deviceToken);
    LoggerService.d('Read device token: \$token');
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiToken, token);
    LoggerService.i('Saved API token');
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_apiToken);
    LoggerService.d('Read API token: \$token');
    return token;
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
    if (data != null) {
      final jsonData = json.decode(data);
      LoggerService.d('Read user data: \$jsonData');
      return jsonData;
    }
    LoggerService.d('No user data found');
    return null;
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.clear();
    if (result) {
      LoggerService.i('All SharedPreferences data cleared successfully');
    } else {
      LoggerService.e('Failed to clear SharedPreferences data');
    }
  }
}
''');

    await File(path.join(servicesDir.path, 'json_extractor.dart'))
        .writeAsString('''
import 'dart:convert';
import '../config/global_variables.dart';
import 'logger_service.dart';

/// Extracts and stores error messages from API responses.
class MessageExtractor {
  void extractAndStoreMessage(String endPoint, String responseBody) {
    try {
      LoggerService.i('Api EndPoint: \$endPoint - Body: \$responseBody');
      final jsonMap = jsonDecode(responseBody);
      GlobalVariables.errorMessages.clear();
      if (jsonMap['errors'] is List) {
        GlobalVariables.errorMessages = List<String>.from(jsonMap['errors']);
      } else if (jsonMap['message'] != null) {
        GlobalVariables.errorMessages.add(jsonMap['message']);
      } else {
        GlobalVariables.errorMessages.add('Unknown error occurred.');
      }
      LoggerService.i('Stored Error Messages: \${GlobalVariables.errorMessages}');
    } catch (e) {
      LoggerService.e('Error extracting and storing message: \$e');
      GlobalVariables.errorMessages.add('Error extracting message.');
    }
  }
}
''');

    await File(path.join(servicesDir.path, 'global_variables.dart'))
        .writeAsString('''
import 'app_enums.dart';

/// Global variables for the LayerX app.
class GlobalVariables {
  static List<String> errorMessages = ['Failed, Try Again'];
  // static UserRole userRole = UserRole.DRIVER;
  static String route = '';
}
''');

    await File(path.join(servicesDir.path, 'location_service.dart'))
        .writeAsString('''
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logger_service.dart';

/// Service for retrieving the user's current location.
class LocationService {
  /// Retrieves the current location of the user.
  /// Returns a [Position] with latitude and longitude.
  /// Throws [Exception] with detailed messages on failure.
  Future<Position> getCurrentLocation() async {
    // Step 1: Check if location services are enabled
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      LoggerService.w('Location services are disabled');
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    // Step 2: Check permission status
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      LoggerService.d('Requesting location permission');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        LoggerService.w('Location permission denied');
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LoggerService.w('Location permission permanently denied');
      await openAppSettings();
      throw Exception(
          'Location permission permanently denied. Please enable it in app settings.');
    }

    // Step 3: Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LoggerService.i(
          'Location retrieved: \${position.latitude}, \${position.longitude}');
      return position;
    } catch (e) {
      LoggerService.e('Error fetching location: \$e');
      throw Exception('Error fetching location: \$e');
    }
  }
}
''');

    await File(path.join(servicesDir.path, 'api_response_handler.dart'))
        .writeAsString('''
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../mvvm/model/api_response_model/api_response.dart';
import 'json_extractor.dart';
import 'logger_service.dart';

/// Handles API responses with standardized processing.
class ApiResponseHandler {
  /// Processes an API response and returns an [ApiResponse<T>].
  /// Uses [fromJson] to parse the data field into type [T].
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
        LoggerService.i('API response processed successfully: \$endPoint');
        return ApiResponse<T>.fromJson(parsedJson, fromJson);

      case 401:
        _handleUnauthorized();
        break;

      case 422:
        _handleError(response, 'Validation Error');
        break;

      case 500:
        _handleError(response, 'Internal Server Error');
        break;

      default:
        _handleError(
            response, 'API Error: \${response.statusCode} - \${response.reasonPhrase}');
    }
    throw Exception('Unexpected error occurred.');
  }

  static dynamic _parseJson(String responseBody) {
    return jsonDecode(responseBody);
  }

  static void _handleUnauthorized() {
    LoggerService.w('Unauthorized access. Redirecting to login.');
    Get.offAllNamed(AppRoutes.loginView);
    throw Exception('Unauthorized access. Please log in.');
  }

  static void _handleError(dynamic response, String errorMessage) {
    try {
      final errorResponse = jsonDecode(response.body);
      final message =
          'errorMessage: \${errorResponse['message'] ?? 'No details available'}';
      LoggerService.e(message);
      throw Exception(message);
    } catch (e, stack) {
      LoggerService.e('Error handling failed: \$e',
          error: e, stackTrace: stack);
      throw Exception(errorMessage);
    }
  }

  static void logUnhandledError(dynamic e, StackTrace stackTrace) {
    LoggerService.e('Unhandled error: \$e', error: e, stackTrace: stackTrace);
  }
}
''');

    await File(path.join(servicesDir.path, 'logger_service.dart'))
        .writeAsString('''
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// Custom log printer with enhanced formatting, colors, and timestamps.
class CustomPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter;

  CustomPrinter()
      : _prettyPrinter = PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          excludeBox: const {},
          noBoxingByDefault: false,
          excludePaths: const [],
          levelColors: {
            Level.trace: AnsiColor.fg(93), // Electric Purple 💜
            Level.debug: AnsiColor.fg(200), // Neon Cyan 🌀
            Level.info: AnsiColor.fg(200), // Bright Cyan 🩵
            Level.warning: AnsiColor.fg(214), // Vivid Orange ⚠️
            Level.error: AnsiColor.fg(197), // Bright Crimson ⛔
            Level.wtf: AnsiColor.fg(200), // Hot Pink 🔥
          },
          levelEmojis: {
            Level.trace: '💜 ',
            Level.debug: '🌀 ',
            Level.info: '🩵 ',
            Level.warning: '⚡ ',
            Level.error: '⛔ ',
            Level.wtf: '🔥 ',
          },
        );

  @override
  List<String> log(LogEvent event) {
    final output = _prettyPrinter.log(event);
    final dateTime = DateTime.now();
    final formattedTime = DateFormat('dd-MM-yyyy hh:mm:ss a').format(dateTime);
    final levelName = event.level.name.toUpperCase();
    return output
        .map((line) => '[📅 \$formattedTime] [\$levelName] \$line')
        .toList();
  }
}

/// Singleton service for logging with custom formatting.
class LoggerService {
  LoggerService._();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: CustomPrinter(),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// Returns the singleton logger instance.
  static Logger get instance => _logger;

  /// Logs a debug message (only in debug mode).
  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message (only in debug mode).
  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message (only in debug mode).
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message (only in debug mode).
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a verbose message (only in debug mode).
  static void v(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.v(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a WTF message (only in debug mode).
  static void wtf(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}
''');

    print('Created service files in services/');
  }

  Future<void> _createRepositoryFiles(String appDirPath) async {
    final authRepoDir =
        Directory(path.join(appDirPath, 'repository', 'auth_repo'));
    final apiRepoDir = Directory(path.join(appDirPath, 'repository', 'apis'));

    await File(path.join(authRepoDir.path, 'auth_repository.dart'))
        .writeAsString('''
import 'package:http/http.dart' as http;
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/driver_signup_body_model.dart';
import '../../mvvm/model/body_model/garage_signup_body_model.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

/// Repository for authentication-related API calls.
class AuthRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  Future<ApiResponse<void>> driverSignUpApi(
      DriverSignupBodyModel signUpBodyModel) async {
    try {
      const endPoint = AppUrls.signup;
      LoggerService.d('Initiating driver signup API call');
      final response =
          await _httpsCalls.multipartDriverProfileApiHits(endPoint, signUpBodyModel);
      return await ApiResponseHandler.process(response, endPoint, (dataJson) {});
    } catch (e, stackTrace) {
      ApiResponseHandler.logUnhandledError(e, stackTrace);
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateDriver(
      DriverSignupBodyModel signUpBodyModel) async {
    try {
      const endPoint = AppUrls.updateAccount;
      LoggerService.d('Initiating driver update API call');
      final response =
          await _httpsCalls.multipartDriverProfileApiHits(endPoint, signUpBodyModel);
      return await ApiResponseHandler.process(response, endPoint, (dataJson) {});
    } catch (e, stackTrace) {
      ApiResponseHandler.logUnhandledError(e, stackTrace);
      rethrow;
    }
  }

  Future<ApiResponse<void>> garageSignUpApi(
      GarageSignupBodyModel signUpBodyModel) async {
    try {
      const endPoint = AppUrls.signup;
      LoggerService.d('Initiating garage signup API call');
      final response =
          await _httpsCalls.multipartGarageProfileApiHits(endPoint, signUpBodyModel);
      return await ApiResponseHandler.process(response, endPoint, (dataJson) {});
    } catch (e, stackTrace) {
      ApiResponseHandler.logUnhandledError(e, stackTrace);
      rethrow;
    }
  }
}
''');

    await File(path.join(apiRepoDir.path, 'data_repository.dart'))
        .writeAsString('''
import 'package:http/http.dart' as http;
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/add_car_body_model.dart';
import '../../mvvm/model/body_model/buy_car_request.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

/// Repository for data-related API calls (e.g., car operations).
class DataRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  Future<ApiResponse<void>> addCarApi(AddCarBodyModel carDataModel) async {
    try {
      const endPoint = AppUrls.signup; // TODO: Update with correct endpoint
      LoggerService.d('Initiating add car API call');
      final response = await _httpsCalls.crudCarMultipartApi(endPoint, carDataModel);
      return await ApiResponseHandler.process(response, endPoint, (dataJson) {});
    } catch (e, stackTrace) {
      ApiResponseHandler.logUnhandledError(e, stackTrace);
      rethrow;
    }
  }

  Future<ApiResponse<void>> buyCarApi(BuyCarRequestModel buyRequestModel) async {
    try {
      const endPoint = AppUrls.signup; // TODO: Update with correct endpoint
      LoggerService.d('Initiating buy car API call');
      final response =
          await _httpsCalls.multipartBuyCarRequestApi(endPoint, buyRequestModel);
      return await ApiResponseHandler.process(response, endPoint, (dataJson) {});
    } catch (e, stackTrace) {
      ApiResponseHandler.logUnhandledError(e, stackTrace);
      rethrow;
    }
  }
}
''');

    print('Created repository files in repository/');
  }

  Future<void> _createAppWidgetFile(String projectPath) async {
    final appDir = Directory(path.join(projectPath, 'lib', 'app'));
    await File(path.join(appDir.path, 'app_widget.dart')).writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'config/app_colors.dart';
import 'config/app_routes.dart';

/// Root widget for the LayerX app with GetX and responsive design.
class LayerXApp extends StatelessWidget {
  const LayerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splashView,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
''');

    print('Created app_widget.dart');
  }

  Future<void> _updateMainFile(String projectPath) async {
    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));
    await File(mainFile.path).writeAsString('''
import 'package:flutter/material.dart';
import 'app/app_widget.dart';

void main() {
  runApp(const LayerXApp());
}
''');

    print('Updated main.dart');
  }
}
