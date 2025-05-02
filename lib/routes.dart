import 'package:botbuilder/layouts/main_layout.dart';
import 'package:botbuilder/pages/checkin_page.dart';
import 'package:botbuilder/pages/course_page.dart';
import 'package:get/get.dart';
import 'package:botbuilder/pages/login_page.dart';
import 'package:botbuilder/pages/home_page.dart';
import 'package:botbuilder/pages/user_page.dart';
import 'package:botbuilder/pages/student_page.dart';
import 'package:botbuilder/pages/model_page.dart';

final List<GetPage> appRoutes = [
  GetPage(name: '/login', page: () => const LoginPage()),
  GetPage(name: '/home', page: () => const MainLayout(page: HomePage())),
  GetPage(name: '/users', page: () => const UserPage()),
  GetPage(name: '/students', page: () => const StudentPage()),
  GetPage(name: '/models', page: () => const ModelPage()),
  GetPage(name: '/checkin', page: () => const CheckInPage()),
  GetPage(name: '/courses', page: () => const CoursePage()),
];
