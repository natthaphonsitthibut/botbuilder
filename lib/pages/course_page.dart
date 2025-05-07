import 'package:botbuilder/models/courseCategory.dart';
import 'package:botbuilder/pages/addcourse_page.dart';
import 'package:botbuilder/services/courseCategory_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/models/course.dart';
import 'package:botbuilder/models/model.dart';
import 'package:botbuilder/services/course_service.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:get/get.dart';
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
        categories = [
          CourseCategory(id: -1, name: 'All'),
          ...fetchedCategories,
        ];
        allModels = fetchedModels;
        selectedCategoryId = -1;
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
    final modelIds = course.modelsId ?? [];
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: Text(course.name),
            message:
                modelIds.isEmpty
                    ? const Text("No models in this course.")
                    : SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              modelIds.map((id) {
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

  Future<void> deleteCourse(int id) async {
    final confirm = await showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this course?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Get.back(result: false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await _courseService.deleteCourse(id);
      await loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses =
        (selectedCategoryId == -1
              ? courses
              : courses
                  .where(
                    (course) => course.courseCategoryId == selectedCategoryId,
                  )
                  .toList())
          ..sort((a, b) {
            final categoryCompare = a.courseCategoryId.compareTo(
              b.courseCategoryId,
            );
            return categoryCompare != 0
                ? categoryCompare
                : a.id.compareTo(b.id);
          });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Courses'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ส่วนหัว (คงที่)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Courses',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      AddButton(
                        onPressed: () async {
                          final result = await Get.to(() => AddCoursePage());
                          if (result == true) await loadData();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFFFF9A9A),
                    child: Text(
                      categories
                          .firstWhere(
                            (c) => c.id == selectedCategoryId,
                            orElse:
                                () => CourseCategory(
                                  id: -1,
                                  name: 'Select Category',
                                ),
                          )
                          .name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder:
                            (_) => SizedBox(
                              height: 250,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: categories.indexWhere(
                                    (c) => c.id == selectedCategoryId,
                                  ),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedCategoryId = categories[index].id;
                                  });
                                },
                                children:
                                    categories
                                        .map((c) => Text(c.name))
                                        .toList(),
                              ),
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // ส่วนกริดคอร์ส (เลื่อนได้)
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver:
                        isLoading
                            ? const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 16),
                                ),
                              ),
                            )
                            : filteredCourses.isEmpty
                            ? SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No courses found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final course = filteredCourses[index];
                                final categoryName = getCategoryName(
                                  course.courseCategoryId,
                                );
                                final hasModels =
                                    course.modelsId != null &&
                                    course.modelsId!.isNotEmpty;
                                final firstModel =
                                    hasModels
                                        ? allModels.firstWhere(
                                          (m) => m.id == course.modelsId!.first,
                                          orElse:
                                              () => Model(
                                                name: '',
                                                imageUrl: null,
                                              ),
                                        )
                                        : null;
                                return GestureDetector(
                                  onTap: () => showModelDialog(context, course),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CupertinoColors.black
                                              .withAlpha((0.1 * 255).toInt()),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              firstModel?.imageUrl != null
                                                  ? Image.network(
                                                    '${dotenv.env['API_BASE_URL']}${firstModel!.imageUrl}',
                                                    width: 150,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        'assets/images/legospike.png',
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                  : Image.asset(
                                                    'assets/images/legospike.png',
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: CupertinoColors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Text(
                                          categoryName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.inactiveGray,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CupertinoButton(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              minSize: 0,
                                              child: const Icon(
                                                CupertinoIcons.pencil,
                                                size: 20,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              ),
                                              onPressed: () async {
                                                final result = await Get.to(
                                                  () => AddCoursePage(
                                                    existingCourse: course,
                                                  ),
                                                );
                                                if (result == true)
                                                  await loadData();
                                              },
                                            ),
                                            CupertinoButton(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              minSize: 0,
                                              child: const Icon(
                                                CupertinoIcons.delete,
                                                size: 20,
                                                color:
                                                    CupertinoColors
                                                        .destructiveRed,
                                              ),
                                              onPressed:
                                                  () => deleteCourse(course.id),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }, childCount: filteredCourses.length),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
