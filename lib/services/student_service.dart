import 'dart:io';
import 'package:botbuilder/models/student.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<Student>> getStudents() async {
    final res = await _dio.get('/students');
    return (res.data as List).map((e) => Student.fromJson(e)).toList();
  }

  Future<Student> getStudentById(int id) async {
    final res = await _dio.get('/students/$id');
    return Student.fromJson(res.data);
  }

  Future<Student> createStudent(Student student, File? file) async {
    final formData = FormData.fromMap({
      'firstname': student.firstname,
      'lastname': student.lastname,
      'birthdate': student.birthdate,
      'branchId': student.branchId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.post('/students', data: formData);
    return Student.fromJson(res.data);
  }

  Future<Student> updateStudent(int id, Student student, File? file) async {
    final formData = FormData.fromMap({
      'firstname': student.firstname,
      'lastname': student.lastname,
      'birthdate': student.birthdate,
      'branchId': student.branchId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.patch('/students/$id', data: formData);
    return Student.fromJson(res.data);
  }

  Future<void> deleteStudent(int id) async {
    await _dio.delete('/students/$id');
  }
}
