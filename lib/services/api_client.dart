import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  // API_BASE_URL always wins. Otherwise pick a sensible default for local dev.
  static String get _baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://localhost:4000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.1.80:4000';
      case TargetPlatform.iOS:
        return 'http://localhost:4000';
      default:
        return 'http://192.168.1.80:4000';
    }
  }

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath').replace(queryParameters: query);
  }

  Map<String, String> _headers({bool withJson = true, bool withAuth = true}) {
    return {
      if (withJson) 'Content-Type': 'application/json',
      if (withAuth && _token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await http.get(_uri(path, query), headers: _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers());
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map<String, dynamic>
        ? (decoded['message']?.toString() ?? 'Request failed')
        : 'Request failed';
    throw Exception(message);
  }
}
