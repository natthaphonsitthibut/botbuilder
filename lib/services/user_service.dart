import 'dart:io';
import 'package:dio/dio.dart';
import 'package:botbuilder/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<User>> getUsers() async {
    final res = await _dio.get('/users');
    return (res.data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<User> getUserById(int id) async {
    final res = await _dio.get('/users/$id');
    return User.fromJson(res.data);
  }

  Future<User> createUser(User user, File? file) async {
    final formData = FormData.fromMap({
      'username': user.username,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'gender': user.gender,
      'birthdate': user.birthdate,
      'roleId': user.roleId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.post('/users', data: formData);
    return User.fromJson(res.data);
  }

  Future<User> updateUser(int id, User user, File? file) async {
    final formData = FormData.fromMap({
      'username': user.username,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'gender': user.gender,
      'birthdate': user.birthdate,
      'roleId': user.roleId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.patch('/users/$id', data: formData);
    return User.fromJson(res.data);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id');
  }
}
