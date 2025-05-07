import 'dart:io';
import 'dart:math';
import 'package:botbuilder/models/student.dart';
import 'package:botbuilder/models/branch.dart';
import 'package:botbuilder/services/branch_service.dart';
import 'package:botbuilder/services/student_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddStudentPage extends StatefulWidget {
  final Student? existingStudent;
  const AddStudentPage({super.key, this.existingStudent});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _studentService = StudentService();
  final _branchService = BranchService();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  List<Branch> branches = [];
  Branch? selectedBranch;
  DateTime? selectedDate;
  File? selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();

    if (widget.existingStudent != null) {
      final u = widget.existingStudent!;
      _firstnameController.text = u.firstname;
      _lastnameController.text = u.lastname;
      selectedDate = DateTime.parse(u.birthdate);
    }
  }

  Future<void> _loadBranches() async {
    try {
      final fetchedBranches = await _branchService.getAll();
      setState(() {
        branches = fetchedBranches;
        if (widget.existingStudent != null) {
          selectedBranch = fetchedBranches.firstWhere(
            (b) => b.id == widget.existingStudent!.branchId,
          );
        } else {
          selectedBranch =
              fetchedBranches.isNotEmpty ? fetchedBranches.first : null;
        }
      });
    } catch (e) {
      print('Error loading branches: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitStudent() async {
    if (_firstnameController.text.isEmpty ||
        _lastnameController.text.isEmpty ||
        selectedDate == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = Student(
        id: widget.existingStudent?.id ?? 0,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        imageUrl: null,
        birthdate: DateFormat('yyyy-MM-dd').format(selectedDate!),
        branchId: selectedBranch!.id,
      );

      if (widget.existingStudent != null) {
        await _studentService.updateStudent(student.id, student, selectedImage);
      } else {
        print('Sending student data: ${student.toJson()}');
        await _studentService.createStudent(student, selectedImage);
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
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingStudent != null;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Edit Student' : 'Add Student'),
        trailing:
            _isLoading
                ? const CupertinoActivityIndicator(radius: 12)
                : CupertinoButton(
                  padding: EdgeInsets.zero,

                  onPressed: _submitStudent,
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
              // Student Image
              const Text(
                'Student Image',
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
                      selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
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

              // First Name
              const Text(
                'First Name *',
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
                  controller: _firstnameController,
                  placeholder: 'Enter first name',
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

              // Last Name
              const Text(
                'Last Name *',
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
                  controller: _lastnameController,
                  placeholder: 'Enter last name',
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

              // Birthdate
              const Text(
                'Birthdate *',
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
                  onPressed: () => _selectDate(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          color:
                              selectedDate != null
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

              // Branch
              const Text(
                'Branch *',
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
                          (_) => _buildBottomSheet(
                            CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(
                                initialItem: max(
                                  0,
                                  branches.indexWhere(
                                    (b) => b.id == selectedBranch?.id,
                                  ),
                                ),
                              ),
                              onSelectedItemChanged:
                                  (index) => setState(
                                    () => selectedBranch = branches[index],
                                  ),
                              children:
                                  branches.map((b) => Text(b.name)).toList(),
                            ),
                          ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedBranch?.name ?? 'Select branch',
                        style: TextStyle(
                          color:
                              selectedBranch != null
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

  Future<void> _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => _buildBottomSheet(
            CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate ?? DateTime(2000),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (date) => setState(() => selectedDate = date),
              dateOrder: DatePickerDateOrder.ymd,
            ),
          ),
    );
  }

  Widget _buildBottomSheet(Widget child) {
    return Container(
      height: 250,
      color: CupertinoColors.white,
      child: SafeArea(child: child),
    );
  }
}
