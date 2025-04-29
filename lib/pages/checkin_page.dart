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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Check In / Out'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                child: const Text('Check In'),
                onPressed: () => _launchUrl(checkInUrl),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.systemGrey,
                child: const Text('Check Out'),
                onPressed: () => _launchUrl(checkOutUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
