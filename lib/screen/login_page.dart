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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logos/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 350,
                  height: 450,
                  clipBehavior: Clip.hardEdge, // <<< ตัดให้ขอบมนจริง
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9A9A), // พื้นหลัง Container
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        spreadRadius: 2, // ขนาดกระจาย
                        blurRadius: 4, // ความเบลอ
                        offset: Offset(
                          2,
                          2,
                        ), // ทิศทาง x, y (0 คือกึ่งกลาง, 4 คือดันลงล่าง)
                      ),
                    ], // ขอบมน 16 px
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // <<< Padding ข้างในทั้งหมด
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        const Text(
                          'Username',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                spreadRadius: 2, // ขนาดกระจาย
                                blurRadius: 4, // ความเบลอ
                                offset: Offset(
                                  2,
                                  5,
                                ), // ทิศทาง x, y (0 คือกึ่งกลาง, 4 คือดันลงล่าง)
                              ),
                            ],
                          ),
                          height: 55,
                          child: CupertinoTextField(
                            controller: usernameController,
                            placeholder: 'Enter your username',
                            padding: const EdgeInsets.all(12),
                            suffix: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                CupertinoIcons.person,
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
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                spreadRadius: 2, // ขนาดกระจาย
                                blurRadius: 4, // ความเบลอ
                                offset: Offset(
                                  2,
                                  5,
                                ), // ทิศทาง x, y (0 คือกึ่งกลาง, 4 คือดันลงล่าง)
                              ),
                            ],
                          ),
                          height: 55,
                          child: CupertinoTextField(
                            controller: passwordController,
                            placeholder: 'Enter your password',
                            obscureText: true,
                            padding: const EdgeInsets.all(12),
                            suffix: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                CupertinoIcons.lock,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.2 * 255).toInt(),
                                  ),
                                  spreadRadius: 2, // ขนาดกระจาย
                                  blurRadius: 4, // ความเบลอ
                                  offset: Offset(
                                    2,
                                    5,
                                  ), // ทิศทาง x, y (0 คือกึ่งกลาง, 4 คือดันลงล่าง)
                                ),
                              ],
                            ),
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
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/legospike.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
