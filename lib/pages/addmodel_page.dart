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
                ? const CupertinoActivityIndicator(radius: 12)
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    isEditing ? 'Update' : 'Save',
                    style: const TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ListView(
            children: [
              // Image Upload
              const Text(
                'Model Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
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
                  child:
                      _imageFile != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.photo,
                                  size: 48,
                                  color: CupertinoColors.inactiveGray,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Model Name
              const Text(
                'Model Name *',
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
                  placeholder: 'Enter model name',
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

              // PDF URL
              const Text(
                'PDF URL (Optional)',
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
                  controller: _pdfUrlController,
                  placeholder: 'Enter PDF link',
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
                                                c.courseCategoryId ==
                                                category.id,
                                          )
                                          .toList();
                                  selectedCourse =
                                      filtered.isNotEmpty
                                          ? filtered.first
                                          : null;
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

              // Course
              const Text(
                'Course *',
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
                      Text(
                        selectedCourse?.name ?? 'Select course',
                        style: TextStyle(
                          color:
                              selectedCourse != null
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
            ],
          ),
        ),
      ),
    );
  }
}
