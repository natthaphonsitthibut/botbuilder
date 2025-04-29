import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage()];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // --- Header User ---
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFFF9A9A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 35),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        'assets/images/legospike.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Natthaphon",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        Text(
                          "User",
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- เนื้อหาของแต่ละหน้า ---
            Expanded(child: _pages[_currentIndex]),

            // --- Bottom Navigation ---
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ), // เพิ่ม padding ด้านบนให้ทั้ง TabBar
              child: CupertinoTabBar(
                backgroundColor: CupertinoColors.systemGrey6,
                activeColor: CupertinoColors.activeBlue,
                inactiveColor: CupertinoColors.inactiveGray,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Icon(CupertinoIcons.home),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Icon(CupertinoIcons.calendar),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
