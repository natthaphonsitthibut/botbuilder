import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await storage.write(key: 'user', value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_BASE_URL']}/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        return user;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await storage.deleteAll();
    Get.offAllNamed('/login');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
