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
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(isEditing ? 'Update' : 'Save'),
                  onPressed: _submitCourse,
                ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                'Course Name *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Enter course name',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Course Category *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: CupertinoColors.systemGrey5,
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
                    Text(selectedCategory?.name ?? 'Select category'),
                    const Icon(CupertinoIcons.chevron_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Models (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children:
                    allModels.map((model) {
                      final isSelected = selectedModelIds.contains(model.id);
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
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
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.circle,
                              color:
                                  isSelected
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.inactiveGray,
                            ),
                            const SizedBox(width: 8),
                            Text(model.name),
                          ],
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
