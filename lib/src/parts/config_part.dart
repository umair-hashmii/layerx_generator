part of layerx_generator;

// ========================= CONFIG =========================

extension _ConfigPart on LayerXGenerator {
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
}
