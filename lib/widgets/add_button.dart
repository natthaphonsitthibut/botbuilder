import 'package:flutter/cupertino.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AddButton({super.key, required this.onPressed, this.label = 'ADD'});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: CupertinoColors.activeGreen,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
