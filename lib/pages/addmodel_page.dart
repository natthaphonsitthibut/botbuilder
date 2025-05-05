import 'dart:io';
import 'dart:math';
import 'package:botbuilder/models/courseCategory.dart';
import 'package:botbuilder/services/courseCategory_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:botbuilder/models/model.dart';
import 'package:botbuilder/models/course.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:botbuilder/services/course_service.dart';

class AddModelPage extends StatefulWidget {
  final Model? existingModel;
  const AddModelPage({super.key, this.existingModel});

  @override
  State<AddModelPage> createState() => _AddModelPageState();
}

class _AddModelPageState extends State<AddModelPage> {
  final _modelService = ModelService();
  final _courseService = CourseService();
  final _courseCategoryService = CourseCategoryService();

  final _nameController = TextEditingController();
  final _pdfUrlController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  List<CourseCategory> courseCategories = [];
  List<Course> courses = [];
  CourseCategory? selectedCategory;
  Course? selectedCourse;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingModel?.name ?? '';
    _pdfUrlController.text = widget.existingModel?.pdfUrl ?? '';
    loadCategoriesAndCourses();
  }

  Future<void> loadCategoriesAndCourses() async {
    try {
      final categories = await _courseCategoryService.getAll();
      final allCourses = await _courseService.getCourses();

      setState(() {
        courseCategories = categories;
        courses = allCourses;

        if (widget.existingModel != null) {
          final currentCourse = allCourses.firstWhere(
            (c) => c.id == widget.existingModel!.courseId,
          );
          selectedCourse = currentCourse;
          selectedCategory = categories.firstWhere(
            (cat) => cat.id == currentCourse.courseCategoryId,
          );
        } else {
          selectedCategory = categories.isNotEmpty ? categories.first : null;
          selectedCourse = allCourses.firstWhere(
            (c) => c.courseCategoryId == selectedCategory?.id,
          );
        }
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _createModel() async {
    if (_nameController.text.isEmpty || selectedCourse == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final model = Model(
        name: _nameController.text,
        pdfUrl:
            _pdfUrlController.text.isNotEmpty ? _pdfUrlController.text : null,
        courseId: selectedCourse!.id,
      );

      await _modelService.createModel(model, _imageFile);
      if (mounted) Get.back(result: true);
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateModel(int id) async {
    if (_nameController.text.isEmpty || selectedCourse == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final model = Model(
        id: id,
        name: _nameController.text,
        pdfUrl:
            _pdfUrlController.text.isNotEmpty ? _pdfUrlController.text : null,
        courseId: selectedCourse!.id,
      );

      await _modelService.updateModel(id, model, _imageFile);
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
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingModel != null;
    final filteredCourses =
        courses
            .where((c) => c.courseCategoryId == selectedCategory?.id)
            .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Edit Model' : 'Add Model'),
        trailing:
            _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(isEditing ? 'Update' : 'Save'),
                  onPressed: () {
                    if (isEditing) {
                      _updateModel(widget.existingModel!.id!);
                    } else {
                      _createModel();
                    }
                  },
                ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey3),
                  ),
                  child:
                      _imageFile != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                          : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.photo,
                                  size: 48,
                                  color: CupertinoColors.systemGrey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to upload image',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Model Name *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Enter model name',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PDF URL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _pdfUrlController,
                placeholder: 'Optional PDF link',
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
                              initialItem: max(
                                0,
                                courseCategories.indexWhere(
                                  (c) => c.id == selectedCategory?.id,
                                ),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              final category = courseCategories[index];
                              setState(() {
                                selectedCategory = category;
                                final filtered =
                                    courses
                                        .where(
                                          (c) =>
                                              c.courseCategoryId == category.id,
                                        )
                                        .toList();
                                selectedCourse =
                                    filtered.isNotEmpty ? filtered.first : null;
                              });
                            },
                            children:
                                courseCategories
                                    .map((c) => Text(c.name))
                                    .toList(),
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
                'Course *',
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
                              initialItem: max(
                                0,
                                filteredCourses.indexWhere(
                                  (c) => c.id == selectedCourse?.id,
                                ),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedCourse = filteredCourses[index];
                              });
                            },
                            children:
                                filteredCourses
                                    .map((c) => Text(c.name))
                                    .toList(),
                          ),
                        ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedCourse?.name ?? 'Select course'),
                    const Icon(CupertinoIcons.chevron_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
