import 'package:botbuilder/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); //load env
  runApp(
    const CupertinoApp(home: LoginPage(), debugShowCheckedModeBanner: false),
  );
}
