import 'package:botbuilder/widgets/menu_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemBackground, // <<< ทำให้พื้นหลังไม่ดำ

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today Schedule",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 20),

            // --- ปฏิทิน (Mock UI) ---
            Container(
              padding: const EdgeInsets.all(12),
              height: 350,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Calendar",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Google Calendar will be here",
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- ปุ่มเมนู ---
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MenuIconButton(
                  icon: CupertinoIcons.book,
                  label: 'Course',
                  onPressed: () => Get.toNamed('/courses'),
                ),
                MenuIconButton(
                  icon: CupertinoIcons.cube_box,
                  label: 'Model',
                  onPressed: () => Get.toNamed('/models'),
                ),
                MenuIconButton(
                  icon: CupertinoIcons.person_2,
                  label: 'Student',
                  onPressed: () => Get.toNamed('/students'),
                ),
                MenuIconButton(
                  icon: CupertinoIcons.doc_text,
                  label: 'Report',
                  onPressed: () {
                    // ไปหน้า report ถ้ามี
                  },
                ),
                MenuIconButton(
                  icon: CupertinoIcons.location,
                  label: 'CheckIn',
                  onPressed: () => Get.toNamed('/checkin'),
                ),
                MenuIconButton(
                  icon: CupertinoIcons.person,
                  label: 'User',
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
