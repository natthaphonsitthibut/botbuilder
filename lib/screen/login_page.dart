import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ใช้สำหรับบางอย่างเช่น SnackBar (optional)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == 'admin' && password == '1234') {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Login Success'),
              content: const Text('Welcome back!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Invalid username or password.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Try Again'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // navigationBar: const CupertinoNavigationBar(middle: Text('Login')),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              width: 300,
              height: 500,
              clipBehavior: Clip.hardEdge, // <<< ตัดให้ขอบมนจริง
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A9A), // พื้นหลัง Container
                borderRadius: BorderRadius.circular(16), // ขอบมน 16 px
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ), // <<< Padding ข้างในทั้งหมด
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: usernameController,
                      placeholder: 'Enter your username',
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: passwordController,
                      placeholder: 'Enter your password',
                      obscureText: true,
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 50,
                        child: CupertinoButton(
                          onPressed: login,
                          color: const Color.fromARGB(255, 255, 0, 0),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
