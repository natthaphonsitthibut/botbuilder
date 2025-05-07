import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      navigatorObservers: [
        routeObserver,
      ], //แอปสามารถสังเกตการเปลี่ยนแปลงของเส้นทาง (route).
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: appRoutes,
    );
  }
}
