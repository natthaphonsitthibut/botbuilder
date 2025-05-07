import 'package:botbuilder/main.dart';
import 'package:botbuilder/models/user.dart';
import 'package:botbuilder/pages/profileuser_page.dart';
import 'package:botbuilder/services/auth_service.dart';
import 'package:botbuilder/services/branch_service.dart';
import 'package:botbuilder/services/role_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class MainLayout extends StatefulWidget {
  final Widget page;

  const MainLayout({super.key, required this.page});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with RouteAware {
  final _authService = AuthService();
  final _roleService = RoleService();
  final _branchService = BranchService();
  User? user;
  String? role;
  String? branch;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // สมัครสมาชิกให้เรียก didPopNext
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    loadUserData(); // รีเฟรชข้อมูลผู้ใช้เมื่อกลับมาที่หน้า
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    try {
      final fetchedUser = await _authService.getUser();
      setState(() {
        user = fetchedUser != null ? User.fromJson(fetchedUser) : null;
        isLoading = false;
      });
      await loadRoleAndBranch(); // เรียกใช้ฟังก์ชันโหลดข้อมูล role และ branch
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  // โหลดข้อมูล Role และ Branch
  Future<void> loadRoleAndBranch() async {
    if (user != null) {
      try {
        final roleData = await _roleService.getById(user!.roleId);
        final branchData = await _branchService.getById(user!.branchId);

        setState(() {
          role = roleData.name;
          branch = branchData.name;
        });
      } catch (e) {
        print('Error loading role and branch: $e');
      }
    }
  }

  void handleLogout() async {
    await _authService.logout();
    Get.offNamed('/login');
  }

  ImageProvider getUserImage() {
    if (user?.imageUrl?.isEmpty ?? true) {
      return const AssetImage('assets/images/legospike.png');
    }

    final fullUrl =
        user!.imageUrl!.startsWith('http')
            ? user!.imageUrl!
            : '${dotenv.env['API_BASE_URL']}${user!.imageUrl}';

    return NetworkImage(fullUrl);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        bottom: false,
        child:
            isLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 16))
                : Column(
                  children: [
                    // Header
                    Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9A9A),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).toInt()),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 35),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => ProfileUserPage());
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: getUserImage(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user!.firstname,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  Text(
                                    '$role - $branch',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              onPressed: handleLogout,
                              child: const Icon(
                                CupertinoIcons.power,
                                color: CupertinoColors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Page content
                    Expanded(child: widget.page),
                  ],
                ),
      ),
    );
  }
}
