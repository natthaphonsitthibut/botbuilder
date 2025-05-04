import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:botbuilder/models/model.dart';
import 'package:botbuilder/models/course.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:botbuilder/services/course_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart' show Icons;

class AddModelPage extends StatefulWidget {
  const AddModelPage({super.key});

  @override
  State<AddModelPage> createState() => _AddModelPageState();
}

class _AddModelPageState extends State<AddModelPage> {
  final _modelService = ModelService();
  final _courseService = CourseService();

  final _nameController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _courseIdController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  List<Course> courses = [];
  Course? selectedCourse;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      final data = await _courseService.getCourses();
      setState(() {
        courses = data;
        if (courses.isNotEmpty) {
          selectedCourse = courses.first;
          _courseIdController.text = selectedCourse!.id.toString();
        }
      });
    } catch (e) {
      print("Error loading courses: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _createModel() async {
    if (_nameController.text.isEmpty || selectedCourse == null) {
      _showErrorDialog('กรุณากรอกชื่อและเลือกคอร์ส');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final model = Model(
        name: _nameController.text,
        pdfUrl:
            _pdfUrlController.text.isNotEmpty ? _pdfUrlController.text : null,
        courseId: selectedCourse!.id,
      );

      await _modelService.createModel(model, _imageFile);

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Error creating model: $e');
      if (context.mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('ข้อผิดพลาด'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('ตกลง'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pdfUrlController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('เพิ่มโมเดล'),
        trailing:
            _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('บันทึก'),
                  onPressed: _createModel,
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
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  CupertinoIcons.photo,
                                  size: 48,
                                  color: CupertinoColors.systemGrey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'แตะเพื่ออัปโหลดรูปภาพ',
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
                'ชื่อโมเดล *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'กรอกชื่อโมเดล',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ลิงก์ PDF',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _pdfUrlController,
                placeholder: 'ลิงก์ PDF (ถ้ามี)',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'เลือกคอร์ส *',
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
                            scrollController: FixedExtentScrollController(
                              initialItem: courses.indexWhere(
                                (c) => c.id == selectedCourse?.id,
                              ),
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedCourse = courses[index];
                                _courseIdController.text =
                                    selectedCourse!.id.toString();
                              });
                            },
                            children: courses.map((c) => Text(c.name)).toList(),
                          ),
                        ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCourse?.name ?? 'เลือกคอร์ส',
                      style: const TextStyle(fontSize: 16),
                    ),
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
