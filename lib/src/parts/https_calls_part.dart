part of layerx_generator;

// ========================= HTTPS CALLS CONTENT =========================

extension _HttpsCallsPart on LayerXGenerator {
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
}''';
}
