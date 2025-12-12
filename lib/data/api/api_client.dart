// lib/data/api/api_client.dart

import 'package:dio/dio.dart';
import '../../core/config/env.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl, // ej: http://10.0.2.2:8080
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? headers}) async {
    return _dio.get(
      path,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(String path, Map<String, dynamic> body,
      {Map<String, dynamic>? headers}) async {
    return _dio.post(
      path,
      data: body,
      options: Options(headers: headers),
    );
  }
}
