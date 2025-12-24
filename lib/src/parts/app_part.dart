part of layerx_generator;

// ========================= APP WIDGET + MAIN =========================

extension _AppPart on LayerXGenerator {
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

          // ✅ Future-ready (optional)
          // initialBinding: InitialBinding(),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Uncomment when Firebase / Notifications are enabled
  // await Firebase.initializeApp();
  // NotificationService.initialize();

  runApp(const LayerXApp());
}
''');

    stdout.writeln('Updated main.dart');
  }
}
