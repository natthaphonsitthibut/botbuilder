import 'package:flutter/cupertino.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const MenuCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
