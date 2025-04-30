import 'package:flutter/cupertino.dart';

class SearchBar extends StatelessWidget {
  final String placeholder;
  final Function(String) onChanged;

  const SearchBar({
    super.key,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: placeholder,
      onChanged: onChanged,
    );
  }
}