part of layerx_generator;

// ========================= MVVM SKELETON =========================

extension _MvvmPart on LayerXGenerator {
  Future<void> _createMVVMSkeleton(String appDirPath) async {
    // ================= SPLASH =================

    await File(
      path.join(appDirPath, 'mvvm', 'view', 'splash', 'splash_view.dart'),
    ).writeAsString('''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_model/splash/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => Text(
            controller.title.value,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
''');

    await File(
      path.join(
        appDirPath,
        'mvvm',
        'view_model',
        'splash',
        'splash_controller.dart',
      ),
    ).writeAsString('''
import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxString title = 'LayerX Ready ✅'.obs;
}
''');

    await File(
      path.join(
        appDirPath,
        'mvvm',
        'view_model',
        'splash',
        'splash_binding.dart',
      ),
    ).writeAsString('''
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
''');

    // ================= LOGIN =================
    // Placeholder view (required for routing + ApiResponseHandler redirect)

    await File(
      path.join(appDirPath, 'mvvm', 'view', 'login', 'login_view.dart'),
    ).writeAsString('''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_model/login/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Login Placeholder (Replace with your UI)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
''');

    await File(
      path.join(
        appDirPath,
        'mvvm',
        'view_model',
        'login',
        'login_controller.dart',
      ),
    ).writeAsString('''
import 'package:get/get.dart';

class LoginController extends GetxController {}
''');

    await File(
      path.join(
        appDirPath,
        'mvvm',
        'view_model',
        'login',
        'login_binding.dart',
      ),
    ).writeAsString('''
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
}
