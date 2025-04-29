import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget page; // <<< รับ Widget เดี่ยวๆ เลย

  const MainLayout({super.key, required this.page});

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
                padding: const EdgeInsets.only(top: 35),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        'assets/images/legospike.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            // --- เนื้อหาที่รับเข้ามา ---
            Expanded(child: page),
          ],
        ),
      ),
    );
  }
}
