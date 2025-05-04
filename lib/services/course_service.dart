import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/course.dart';

class CourseService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  /// ดึงคอร์สทั้งหมด
  Future<List<Course>> getCourses() async {
    final res = await _dio.get('/courses');
    return (res.data as List).map((e) => Course.fromJson(e)).toList();
  }

  Future<Course> getCourseById(int id) async {
    final res = await _dio.get('/courses/$id');
    return Course.fromJson(res.data);
  }

  Future<Course> createCourse({
    required String name,
    required int courseCategoryId,
    List<int>? modelsId,
  }) async {
    final body = {
      'name': name,
      'courseCategoryId': courseCategoryId,
      if (modelsId != null) 'modelsId': modelsId,
    };

    final res = await _dio.post('/courses', data: body);
    return Course.fromJson(res.data);
  }

  /// แก้ไขคอร์ส
  Future<Course> updateCourse({
    required int id,
    required String name,
    required int courseCategoryId,
    List<int>? modelsId,
  }) async {
    final body = {
      'name': name,
      'courseCategoryId': courseCategoryId,
      if (modelsId != null) 'modelsId': modelsId,
    };

    final res = await _dio.patch('/courses/$id', data: body);
    return Course.fromJson(res.data);
  }

  Future<void> deleteCourse(int id) async {
    await _dio.delete('/courses/$id');
  }
}
