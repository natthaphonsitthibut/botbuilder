import 'package:botbuilder/models/courseCategory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseCategoryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<CourseCategory>> getAll() async {
    final response = await _dio.get('/coursecategories');
    return (response.data as List)
        .map((e) => CourseCategory.fromJson(e))
        .toList();
  }

  Future<CourseCategory> getById(int id) async {
    final response = await _dio.get('/coursecategories/$id');
    return CourseCategory.fromJson(response.data);
  }

  Future<CourseCategory> create(String name) async {
    final response = await _dio.post('/coursecategories', data: {'name': name});
    return CourseCategory.fromJson(response.data);
  }

  Future<CourseCategory> update(int id, String name) async {
    final response = await _dio.patch(
      '/coursecategories/$id',
      data: {'name': name},
    );
    return CourseCategory.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/coursecategories/$id');
  }
}
