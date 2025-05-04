import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/model.dart';

class ModelService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<Model>> getModels() async {
    final res = await _dio.get('/models');
    return (res.data as List).map((e) => Model.fromJson(e)).toList();
  }

  Future<Model> getModelById(int id) async {
    final res = await _dio.get('/models/$id');
    return Model.fromJson(res.data);
  }

  Future<Model> createModel(Model model, File? file) async {
    final formData = FormData.fromMap({
      'name': model.name,
      'pdfUrl': model.pdfUrl,
      'courseId': model.courseId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.post('/models', data: formData);
    return Model.fromJson(res.data);
  }

  Future<Model> updateModel(int id, Model model, File? file) async {
    final formData = FormData.fromMap({
      'name': model.name,
      'pdfUrl': model.pdfUrl,
      'courseId': model.courseId,
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
    });

    final res = await _dio.patch('/models/$id', data: formData);
    return Model.fromJson(res.data);
  }

  Future<void> deleteModel(int id) async {
    await _dio.delete('/models/$id');
  }
}
