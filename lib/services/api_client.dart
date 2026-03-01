import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  // API_BASE_URL always wins. Otherwise pick a sensible default for local dev.
  static String get _baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://localhost:4000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.1.9:4000';
      case TargetPlatform.iOS:
        return 'http://localhost:4000';
      default:
        return 'http://192.168.1.9:4000';
    }
  }

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  String _normalizePath(String path) {
    return path.startsWith('/') ? path : '/$path';
  }

  Map<String, String> _headers({bool withAuth = true}) {
    return {
      'Content-Type': 'application/json',
      if (withAuth && _token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    try {
      final response = await _dio.get<dynamic>(
        _normalizePath(path),
        queryParameters: query,
        options: Options(headers: _headers()),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.post<dynamic>(
        _normalizePath(path),
        data: body,
        options: Options(headers: _headers()),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.put<dynamic>(
        _normalizePath(path),
        data: body,
        options: Options(headers: _headers()),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.patch<dynamic>(
        _normalizePath(path),
        data: body,
        options: Options(headers: _headers()),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete<dynamic>(
        _normalizePath(path),
        options: Options(headers: _headers()),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  dynamic _handleResponse(dynamic data) {
    if (data == null) {
      return null;
    }

    return data;
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Request failed';
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded['message']?.toString() ?? 'Request failed';
        }
      } catch (_) {
        return data;
      }
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server';
    }

    return e.message ?? 'Request failed';
  }
}
