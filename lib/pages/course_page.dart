import 'package:botbuilder/models/courseCategory.dart';
import 'package:botbuilder/services/courseCategory_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/models/course.dart';
import 'package:botbuilder/models/model.dart';
import 'package:botbuilder/services/course_service.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final _courseService = CourseService();
  final _categoryService = CourseCategoryService();
  final _modelService = ModelService();

  List<Course> courses = [];
  List<CourseCategory> categories = [];
  List<Model> allModels = [];
  int? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final fetchedCourses = await _courseService.getCourses();
      final fetchedCategories = await _categoryService.getAll();
      final fetchedModels = await _modelService.getModels();

      setState(() {
        courses = fetchedCourses;
        categories = fetchedCategories;
        allModels = fetchedModels;
        selectedCategoryId =
            fetchedCategories.isNotEmpty ? fetchedCategories.first.id : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  String getCategoryName(int id) {
    return categories
        .firstWhere(
          (cat) => cat.id == id,
          orElse: () => CourseCategory(id: id, name: 'Unknown'),
        )
        .name;
  }

  void openPdfUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }

  void showModelDialog(BuildContext context, Course course) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: Text(course.name),
            message:
                course.modelsId.isEmpty
                    ? const Text("No models in this course.")
                    : SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              course.modelsId.map((id) {
                                final model = allModels.firstWhere(
                                  (m) => m.id == id,
                                  orElse:
                                      () => Model(
                                        id: id,
                                        name: 'Unknown',
                                        imageUrl: null,
                                        pdfUrl: null,
                                        courseId: null,
                                      ),
                                );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child:
                                            model.imageUrl != null
                                                ? Image.network(
                                                  '${dotenv.env['API_BASE_URL']}${model.imageUrl}',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.contain,
                                                )
                                                : Container(
                                                  width: 50,
                                                  height: 50,
                                                  color:
                                                      CupertinoColors
                                                          .systemGrey4,
                                                  child: const Icon(
                                                    CupertinoIcons.photo,
                                                  ),
                                                ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          model.name,
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed:
                                            () => openPdfUrl(model.pdfUrl),
                                        child: const Icon(
                                          CupertinoIcons.doc_text,
                                          color: CupertinoColors.activeBlue,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses =
        courses
            .where((course) => course.courseCategoryId == selectedCategoryId)
            .toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Course")),
      child: SafeArea(
        child:
            isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Course",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AddButton(onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              categories.map((category) {
                                final isSelected =
                                    selectedCategoryId == category.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    color:
                                        isSelected
                                            ? const Color.fromARGB(
                                              255,
                                              255,
                                              13,
                                              0,
                                            )
                                            : const Color(0xFFFF9A9A),
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedCategoryId = category.id;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Scrollable Course List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCourses.length,
                          itemBuilder: (_, index) {
                            final course = filteredCourses[index];
                            final categoryName = getCategoryName(
                              course.courseCategoryId,
                            );
                            final firstModel =
                                course.modelsId.isNotEmpty
                                    ? allModels.firstWhere(
                                      (m) => m.id == course.modelsId.first,
                                      orElse:
                                          () => Model(name: '', imageUrl: null),
                                    )
                                    : null;

                            final imageWidget =
                                firstModel?.imageUrl != null
                                    ? Image.network(
                                      '${dotenv.env['API_BASE_URL']}${firstModel!.imageUrl}',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      'assets/images/legospike.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => showModelDialog(context, course),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey5,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            (() {
                                              final firstModel =
                                                  course.modelsId.isNotEmpty
                                                      ? allModels.firstWhere(
                                                        (m) =>
                                                            m.id ==
                                                            course
                                                                .modelsId
                                                                .first,
                                                        orElse:
                                                            () => Model(
                                                              name: '',
                                                              imageUrl: null,
                                                            ),
                                                      )
                                                      : null;

                                              return firstModel?.imageUrl !=
                                                      null
                                                  ? Image.network(
                                                    '${dotenv.env['API_BASE_URL']}${firstModel!.imageUrl}',
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.asset(
                                                    'assets/images/legospike.png',
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  );
                                            })(),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            categoryName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
