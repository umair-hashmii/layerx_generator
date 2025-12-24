part of layerx_generator;

// ========================= MODELS =========================

extension _ModelsPart on LayerXGenerator {
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
}
