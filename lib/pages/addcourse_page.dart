import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:botbuilder/models/course.dart';
import 'package:botbuilder/models/courseCategory.dart';
import 'package:botbuilder/models/model.dart';
import 'package:botbuilder/services/course_service.dart';
import 'package:botbuilder/services/courseCategory_service.dart';
import 'package:botbuilder/services/model_service.dart';

class AddCoursePage extends StatefulWidget {
  final Course? existingCourse;
  const AddCoursePage({super.key, this.existingCourse});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _courseService = CourseService();
  final _categoryService = CourseCategoryService();
  final _modelService = ModelService();

  final _nameController = TextEditingController();
  bool _isLoading = false;

  List<CourseCategory> categories = [];
  List<Model> allModels = [];
  List<int> selectedModelIds = [];
  CourseCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.existingCourse != null) {
      _nameController.text = widget.existingCourse!.name;
      selectedModelIds = List<int>.from(widget.existingCourse!.modelsId ?? []);
    }
    loadCategories();
    loadModels();
  }

  Future<void> loadCategories() async {
    try {
      final data = await _categoryService.getAll();
      setState(() {
        categories = data;
        if (widget.existingCourse != null) {
          selectedCategory = data.firstWhere(
            (c) => c.id == widget.existingCourse!.courseCategoryId,
          );
        } else {
          selectedCategory = data.isNotEmpty ? data.first : null;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> loadModels() async {
    try {
      final data = await _modelService.getModels();
      setState(() {
        allModels = data;
      });
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  Future<void> _submitCourse() async {
    if (_nameController.text.isEmpty || selectedCategory == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.existingCourse != null) {
        // แก้ไข
        await _courseService.updateCourse(
          id: widget.existingCourse!.id,
          name: _nameController.text,
          courseCategoryId: selectedCategory!.id,
          modelsId: selectedModelIds,
        );
      } else {
        // เพิ่มใหม่
        await _courseService.createCourse(
          name: _nameController.text,
          courseCategoryId: selectedCategory!.id,
          modelsId: selectedModelIds,
        );
      }
      if (mounted) Get.back(result: true);
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Get.back(),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCourse != null;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Edit Course' : 'Add Course'),
        trailing:
            _isLoading
                ? const CupertinoActivityIndicator(radius: 12)
                : CupertinoButton(
                  padding: EdgeInsets.zero,

                  onPressed: _submitCourse,
                  child: Text(
                    isEditing ? 'Update' : 'Save',
                    style: const TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            children: [
              // Course Name
              const Text(
                'Course Name *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Enter course name',
                  placeholderStyle: TextStyle(
                    color: CupertinoColors.inactiveGray.withOpacity(0.6),
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Course Category
              const Text(
                'Course Category *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  color: CupertinoColors.white,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder:
                          (_) => Container(
                            height: 250,
                            color: CupertinoColors.white,
                            child: CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(
                                initialItem: categories.indexWhere(
                                  (c) => c.id == selectedCategory?.id,
                                ),
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedCategory = categories[index];
                                });
                              },
                              children:
                                  categories.map((c) => Text(c.name)).toList(),
                            ),
                          ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory?.name ?? 'Select category',
                        style: TextStyle(
                          color:
                              selectedCategory != null
                                  ? CupertinoColors.black
                                  : CupertinoColors.inactiveGray,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 20,
                        color: CupertinoColors.activeBlue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Models
              const Text(
                'Models (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              allModels.isEmpty
                  ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withAlpha(
                            (0.1 * 255).toInt(),
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No models available',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                    ),
                  )
                  : Column(
                    children:
                        allModels.map((model) {
                          final isSelected = selectedModelIds.contains(
                            model.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.black.withAlpha(
                                      (0.1 * 255).toInt(),
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                color: CupertinoColors.white,
                                onPressed: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedModelIds.remove(model.id);
                                    } else {
                                      selectedModelIds.add(model.id!);
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? CupertinoIcons.checkmark_circle_fill
                                          : CupertinoIcons.circle,
                                      color:
                                          isSelected
                                              ? CupertinoColors.activeGreen
                                              : CupertinoColors.inactiveGray,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        model.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: CupertinoColors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
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
