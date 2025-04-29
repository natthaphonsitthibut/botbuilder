import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  TextStyle get barText => const TextStyle(fontSize: 16, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: Color(0xFFFF9A9A),
              child: Row(
                children: [
                  Padding(padding: EdgeInsets.only(left: 20)),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage("assets/images/legospike.png"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Natthaphon", style: barText),
                      Text("User", style: barText),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
