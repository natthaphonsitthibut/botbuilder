import 'package:botbuilder/widgets/add_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selectedCategory = "ADV";

  final List<Map<String, String>> courses = [
    {
      'title': 'Advance 1',
      'subtitle': 'Surrounding thing',
      'image': 'assets/images/legospike.png',
    },
    {
      'title': 'Advance 2',
      'subtitle': 'Story tale',
      'image': 'assets/images/legospike.png',
    },
    {
      'title': 'Advance 3',
      'subtitle': 'Zoo',
      'image': 'assets/images/legospike.png',
    },
    {
      'title': 'Advance 4',
      'subtitle': 'Smart city',
      'image': 'assets/images/legospike.png',
    },
    {
      'title': 'Advance 5',
      'subtitle': 'Training tracker',
      'image': 'assets/images/legospike.png',
    },
  ];

  final List<String> categories = ["ADV", "AAD", "INT", "OTHER"];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Course")),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Course",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  AddButton(onPressed: () {}),
                ],
              ),
              const SizedBox(height: 12),

              // Category Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    categories.map((category) {
                      final bool isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          color:
                              isSelected
                                  ? const Color.fromARGB(255, 255, 13, 0)
                                  : Color(0xFFFF9A9A),
                          child: Text(
                            category,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),

              // List of Courses
              Column(
                children:
                    courses.map((course) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  course['image']!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    course['subtitle']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
