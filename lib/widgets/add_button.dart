import 'package:flutter/cupertino.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? color;

  const AddButton({
    super.key,
    required this.onPressed,
    this.label = 'ADD',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? CupertinoColors.activeGreen;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: buttonColor,
        minSize: 44,
        borderRadius: BorderRadius.circular(12),
        pressedOpacity: 0.8,
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
