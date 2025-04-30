import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? '',
      connectTimeout: Duration(
        milliseconds: int.parse(dotenv.env['TIMEOUT'] ?? '10000'),
      ),
      receiveTimeout: Duration(
        milliseconds: int.parse(dotenv.env['TIMEOUT'] ?? '10000'),
      ),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, dynamic data) =>
      _dio.post(path, data: data);

  Future<Response> patch(String path, dynamic data) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> upload(String path, FormData formData) =>
      _dio.post(path, data: formData);
}

final api = ApiService();
