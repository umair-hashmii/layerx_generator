part of layerx_generator;

// ========================= REPOSITORIES =========================

extension _RepositoriesPart on LayerXGenerator {
  Future<void> _createRepositoryFiles(String appDirPath) async {
    final authRepoDir =
    Directory(path.join(appDirPath, 'repository', 'auth_repo'));
    final apiRepoDir =
    Directory(path.join(appDirPath, 'repository', 'apis'));

    await authRepoDir.create(recursive: true);
    await apiRepoDir.create(recursive: true);

    // ================= AUTH REPOSITORY =================

    await File(path.join(authRepoDir.path, 'auth_repository.dart'))
        .writeAsString('''
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/driver_signup_body_model.dart';
import '../../mvvm/model/body_model/garage_signup_body_model.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

class AuthRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  // ================= DRIVER =================

  // Future<ApiResponse<void>> driverSignUpApi(
  //     DriverSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.signup;
  //     LoggerService.d('Driver signup → \$endPoint');
  //     final response =
  //         await _httpsCalls.multipartDriverProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }

  // Future<ApiResponse<void>> updateDriver(
  //     DriverSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.updateAccount;
  //     LoggerService.d('Driver update → \$endPoint');
  //     final response =
  //         await _httpsCalls.multipartDriverProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }

  // ================= GARAGE =================

  // Future<ApiResponse<void>> garageSignUpApi(
  //     GarageSignupBodyModel body) async {
  //   try {
  //     const endPoint = AppUrls.signup;
  //     LoggerService.d('Garage signup → \$endPoint');
  //     final response =
  //         await _httpsCalls.multipartGarageProfileApiHits(endPoint, body);
  //     return ApiResponseHandler.process(response, endPoint, (_) {});
  //   } catch (e, st) {
  //     ApiResponseHandler.logUnhandledError(e, st);
  //     rethrow;
  //   }
  // }
}
''');

    // ================= DATA REPOSITORY =================

    await File(path.join(apiRepoDir.path, 'data_repository.dart'))
        .writeAsString('''
import '../../config/app_urls.dart';
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../mvvm/model/body_model/add_car_body_model.dart';
import '../../mvvm/model/body_model/buy_car_request_model.dart';
import '../../services/api_response_handler.dart';
import '../../services/https_calls.dart';
import '../../services/logger_service.dart';

class DataRepository {
  final HttpsCalls _httpsCalls = HttpsCalls();

  // ================= ADD CAR =================

  Future<ApiResponse<void>> addCarApi(AddCarBodyModel body) async {
    try {
      const endPoint = AppUrls.signup; // TODO: replace endpoint
      LoggerService.d('Add car → \$endPoint');
      final response =
          await _httpsCalls.crudCarMultipartApi(endPoint, body);
      return ApiResponseHandler.process(response, endPoint, (_) {});
    } catch (e, st) {
      ApiResponseHandler.logUnhandledError(e, st);
      rethrow;
    }
  }

  // ================= BUY CAR =================

  Future<ApiResponse<void>> buyCarApi(BuyCarRequestModel body) async {
    try {
      const endPoint = AppUrls.signup; // TODO: replace endpoint
      LoggerService.d('Buy car → \$endPoint');
      final response =
          await _httpsCalls.multipartBuyCarRequestApi(endPoint, body);
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
}
