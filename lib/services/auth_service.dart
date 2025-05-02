import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

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
    print(user);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await storage.read(key: 'user');
    return data != null ? jsonDecode(data) : null;
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
