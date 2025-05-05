import 'package:botbuilder/models/branch.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BranchService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  Future<List<Branch>> getAll() async {
    final res = await _dio.get('/branches');
    return (res.data as List).map((e) => Branch.fromJson(e)).toList();
  }
}
