import 'package:flutter/cupertino.dart';

class MenuIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const MenuIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: CupertinoColors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: CupertinoColors.black),
        ),
      ],
    );
  }
}
