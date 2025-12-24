part of 'package:layerx_generator/src/layerx_generator.dart';


extension _ModelsPart on LayerXGenerator {
  Future<void> _createModelFiles(String appDirPath) async {
    final bodyModelDir = Directory(
      path.join(appDirPath, 'mvvm', 'model', 'body_model'),
    );
    final apiResponseModelDir = Directory(
      path.join(appDirPath, 'mvvm', 'model', 'api_response_model'),
    );

    await File(
      path.join(bodyModelDir.path, 'test_body_model.dart'),
    ).writeAsString('''
/// Basic test body model (JSON only).
class TestBodyModel {
  String? name;
  String? email;

  TestBodyModel({
    this.name,
    this.email,
  });

  factory TestBodyModel.fromJson(Map<String, dynamic> json) => TestBodyModel(
        name: json['name'] as String?,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
''');

    // ✅ TEST UPLOAD BODY MODEL (single file)
    await File(
      path.join(bodyModelDir.path, 'test_upload_body_model.dart'),
    ).writeAsString('''
import 'dart:io';

/// Test body model with single file upload support.
class TestUploadBodyModel {
  String? title;
  File? file;

  TestUploadBodyModel({
    this.title,
    this.file,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}
''');

    // ✅ TEST REQUEST BODY MODEL (another simple sample)
    await File(
      path.join(bodyModelDir.path, 'test_request_body_model.dart'),
    ).writeAsString('''
import 'dart:io';

/// Test request model with basic multipart structure.
class TestRequestBodyModel {
  String? note;
  File? image;

  TestRequestBodyModel({
    this.note,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'note': note,
      };
}
''');

    // ✅ TEST MULTIPART BODY MODEL (multiple docs)
    await File(
      path.join(bodyModelDir.path, 'test_multipart_body_model.dart'),
    ).writeAsString('''
import 'dart:io';

/// Test multipart model showing all common file fields.
class TestMultipartBodyModel {
  String? title;
  File? image;
  File? document;
  List<File>? documents;

  TestMultipartBodyModel({
    this.title,
    this.image,
    this.document,
    this.documents,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}
''');

    // ✅ API RESPONSE MODEL (core)
    await File(
      path.join(apiResponseModelDir.path, 'api_response.dart'),
    ).writeAsString('''
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
