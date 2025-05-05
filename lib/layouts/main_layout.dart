import 'package:botbuilder/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainLayout extends StatefulWidget {
  final Widget page;

  const MainLayout({super.key, required this.page});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final authService = AuthService();
  String firstname = 'Loading...';
  String role = '';
  String branch = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final user = await authService.getUser();
    if (user != null) {
      setState(() {
        firstname = user['firstname'] ?? 'Unknown';
        role = user['role']?['name'] ?? '';
        branch = user['branch']?['name'] ?? '';
        imageUrl = user['imageUrl'] ?? '';
      });
    }
  }

  void handleLogout() async {
    await authService.logout();
  }

  ImageProvider getUserImage() {
    if (imageUrl.isEmpty) {
      return const AssetImage('assets/images/legospike.png');
    }

    final fullUrl =
        imageUrl.startsWith('http')
            ? imageUrl
            : '${dotenv.env['API_BASE_URL']}$imageUrl';

    return NetworkImage(fullUrl);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
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
                    CircleAvatar(radius: 25, backgroundImage: getUserImage()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstname,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
