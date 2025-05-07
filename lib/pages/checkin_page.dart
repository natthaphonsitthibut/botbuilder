import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  // URL ของฟอร์ม Check-In และ Check-Out
  final String checkInUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScfWtY1O9h6LRFSpG2a48QRjCB3LWtD6-KVN7o5dmTXSKCxyg/viewform';
  final String checkOutUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScYZ_i7McsuA4o_FYYZ3K6WbsLm5eT2F_ezjiBN-U6f_W80iA/viewform';

  // ฟังก์ชันเปิดลิงก์
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Check In / Out'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check in or out below',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.inactiveGray,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _launchUrl(checkInUrl),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Check In',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _launchUrl(checkOutUrl),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_left_circle_fill,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Check Out',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
