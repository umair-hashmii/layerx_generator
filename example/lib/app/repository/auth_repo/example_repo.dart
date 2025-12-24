// class ExampleRepo {
//   final HttpsCalls _httpsCalls = HttpsCalls();
//   final MessageExtractor _messageExtractor = MessageExtractor();
//
//   Future<void> fetchData(String endpoint) async {
//     try {
//       final response = await _httpsCalls.getApiHits(endpoint);
//       _messageExtractor.extractAndStoreMessage(endpoint, response.body);
//       // Process response as needed
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

// class AppSettingsRepo {
//   final logger = Logger();
//
//   Future<ApiResponse<SettingsData>> fetchAppSettingsApi() async {
//     try {
//       String? endPoint = ApiUrls.appSettings;
//       final response = await HttpsCalls().getApiHits(endPoint);
//       return await _processResponse(response, (dataJson) => SettingsData.fromJson(dataJson));
//     } catch (e, stackTrace) {
//       _logUnhandledError(e, stackTrace);
//       rethrow;
//     }
//   }
//
//   Future<ApiResponse<T>> _processResponse<T>(
//       dynamic response,
//       T Function(dynamic dataJson) fromJson,
//       ) async {
//     MessageExtractor().extractAndStoreMessage('', response.body);
//
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       // Use compute for large JSON payloads, otherwise decode directly
//         final parsedJson = response.body.length > 100000
//             ? await compute<String, dynamic>(_parseJson, response.body) // Explicit type arguments
//             : jsonDecode(response.body);
//
//         return ApiResponse<T>.fromJson(parsedJson, fromJson);
//
//       case 401:
//         _handleUnauthorized();
//         break;
//
//       case 422:
//         _handleError(response, "Validation Error");
//         break;
//
//       case 500:
//         _handleError(response, "Internal Server Error");
//         break;
//
//       default:
//         _handleError(
//           response,
//           "API Error: {response.statusCode} - {response.reasonPhrase}",
//         );
//     }
//     throw Exception("Unexpected error occurred.");
//   }
//
//
//   dynamic _parseJson(String responseBody) {
//     return jsonDecode(responseBody);
//   }
//
//   void _handleUnauthorized() {
//     logger.w("Unauthorized access. Redirecting to login.");
//     Get.offAllNamed(AppRoutes.signInView);
//     throw Exception("Unauthorized access. Please log in.");
//   }
//
//   void _handleError(dynamic response, String errorMessage) {
//     try {
//       final errorResponse = jsonDecode(response.body);
//       throw Exception("errorMessage: {errorResponse['message'] ?? 'No details available'}");
//     } catch (e) {
//       logger.e("Error handling failed: e");
//       throw Exception(errorMessage);
//     }
//   }
//
//   void _logUnhandledError(dynamic e, StackTrace stackTrace) {
//     logger.e('Unhandled error: e', error: e, stackTrace: stackTrace);
//   }
// }
