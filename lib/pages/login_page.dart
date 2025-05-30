import 'package:botbuilder/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  final storage = FlutterSecureStorage();
  final authService = AuthService();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError('Please enter email and password');
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse('${dotenv.env['API_BASE_URL']}/auth/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'emailOrUsername': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['access_token'] != null) {
        await authService.saveToken(data['access_token']);
        await authService.saveUser(data['user']);
        if (Get.isDialogOpen == true && mounted) {
          Get.back();
        }
        Get.offNamed('/home');
      } else {
        final message = data['message'] ?? 'Login failed';
        showError(message);
      }
    } catch (e) {
      showError('An error occurred: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void showError(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Try Again'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void loginWithGoogle() async {
    setState(() => loading = true);
    try {
      final callbackScheme = 'botbuilder';

      final result = await FlutterWebAuth2.authenticate(
        url: '${dotenv.env['API_BASE_URL']}/auth/google',
        callbackUrlScheme: callbackScheme,
        preferEphemeral: true, // ไม่จำ session (login ใหม่ตลอด)
      );

      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];

      if (token != null) {
        // เก็บ token
        await authService.saveToken(token);
        final meRes = await http.get(
          Uri.parse('${dotenv.env['API_BASE_URL']}/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (meRes.statusCode == 200) {
          final userData = json.decode(meRes.body);
          await authService.saveUser(userData);
        } else {
          showError('Cannot fetch user profile from token');
          return;
        }
        //ไปหน้า home
        Get.offNamed('/home');
      } else {
        showError('Token not found in callback URL');
      }
    } catch (e) {
      showError('Google Sign-In failed: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset('assets/logos/logo.png', height: 200, width: 200),
                  const SizedBox(height: 20),
                  Container(
                    width: 350,
                    height: 450,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9A9A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Email or Username',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CupertinoTextField(
                            controller: emailController,
                            placeholder: 'Enter your email or username',
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                CupertinoIcons.mail,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CupertinoTextField(
                            controller: passwordController,
                            placeholder: 'Enter your password',
                            obscureText: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                CupertinoIcons.lock,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 0, 0),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                        (0.3 * 255).toInt(),
                                      ),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: const Offset(2, 5),
                                    ),
                                  ],
                                ),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: login,
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CupertinoButton(
                                color: Colors.white,
                                onPressed: loginWithGoogle,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.globe,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Sign in with Google',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/images/legospike.png',
                      height: 150,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            Container(
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 20),
              ),
            ),
        ],
      ),
    );
  }
}
