import 'package:botbuilder/pages/checkin_page.dart';
import 'package:botbuilder/pages/course_page.dart';
import 'package:botbuilder/widgets/menu_icon_button.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today Schedule",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 20),
            // --- พื้นที่ปฏิทิน (Mock UI) ---
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
                children: [
                  const Text(
                    "Calendar",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
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
              shrinkWrap: true, // <<< สำคัญมาก ไม่งั้น GridView จะกินจอไม่หมด
              crossAxisCount: 3, // <<<  3 อันต่อแถว
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics:
                  const NeverScrollableScrollPhysics(), // <<< เพราะเราห่อด้วย SingleChildScrollView แล้ว
              children: [
                MenuIconButton(
                  icon: CupertinoIcons.book,
                  label: 'Course',
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const CoursePage(),
                      ),
                    );
                  },
                ),
                MenuIconButton(
                  icon: CupertinoIcons.cube_box,
                  label: 'Model',
                  onPressed: () {},
                ),
                MenuIconButton(
                  icon: CupertinoIcons.person_2,
                  label: 'Student',
                  onPressed: () {},
                ),
                MenuIconButton(
                  icon: CupertinoIcons.doc_text,
                  label: 'Report',
                  onPressed: () {},
                ),
                MenuIconButton(
                  icon: CupertinoIcons.location,
                  label: 'CheckIn',
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const CheckInPage(),
                      ),
                    );
                  },
                ),
                MenuIconButton(
                  icon: CupertinoIcons.person,
                  label: 'User',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
