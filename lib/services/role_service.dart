import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:botbuilder/models/role.dart';

class RoleService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<Role>> getAll() async {
    final response = await _dio.get('/roles');
    return (response.data as List).map((e) => Role.fromJson(e)).toList();
  }

  Future<Role> getById(int id) async {
    final response = await _dio.get('/roles/$id');
    return Role.fromJson(response.data);
  }

  Future<Role> create(String name) async {
    final response = await _dio.post('/roles', data: {'name': name});
    return Role.fromJson(response.data);
  }

  Future<Role> update(int id, String name) async {
    final response = await _dio.patch('/roles/$id', data: {'name': name});
    return Role.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/roles/$id');
  }
}
