import 'package:botbuilder/widgets/menu_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัว
            const Text(
              'Today Schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan your day with ease',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.inactiveGray,
              ),
            ),
            const SizedBox(height: 24),

            // ส่วนปฏิทิน
            Container(
              padding: const EdgeInsets.all(16),
              height: 300,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 28,
                        color: CupertinoColors.activeBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.calendar_today,
                            size: 48,
                            color: CupertinoColors.inactiveGray,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Google Calendar will be here',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.inactiveGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ส่วนเมนู
            const Text(
              'Quick Access',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              children: [
                MenuCard(
                  icon: CupertinoIcons.book,
                  label: 'Course',
                  color: CupertinoColors.activeBlue,
                  onPressed: () => Get.toNamed('/courses'),
                ),
                MenuCard(
                  icon: CupertinoIcons.cube_box,
                  label: 'Model',
                  color: CupertinoColors.activeGreen,
                  onPressed: () => Get.toNamed('/models'),
                ),
                MenuCard(
                  icon: CupertinoIcons.person_2,
                  label: 'Student',
                  color: CupertinoColors.activeOrange,
                  onPressed: () => Get.toNamed('/students'),
                ),
                MenuCard(
                  icon: CupertinoIcons.doc_text,
                  label: 'Report',
                  color: CupertinoColors.systemPurple,
                  onPressed: () {
                    // ไปหน้า report ถ้ามี
                  },
                ),
                MenuCard(
                  icon: CupertinoIcons.location,
                  label: 'CheckIn',
                  color: CupertinoColors.systemTeal,
                  onPressed: () => Get.toNamed('/checkin'),
                ),
                MenuCard(
                  icon: CupertinoIcons.person,
                  label: 'User',
                  color: CupertinoColors.systemIndigo,
                  onPressed: () => Get.toNamed('/users'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
