import 'dart:io';
import 'dart:math';
import 'package:botbuilder/models/user.dart';
import 'package:botbuilder/models/role.dart';
import 'package:botbuilder/models/branch.dart';
import 'package:botbuilder/services/role_service.dart';
import 'package:botbuilder/services/branch_service.dart';
import 'package:botbuilder/services/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddUserPage extends StatefulWidget {
  final User? existingUser;
  const AddUserPage({super.key, this.existingUser});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _userService = UserService();
  final _roleService = RoleService();
  final _branchService = BranchService();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Role> roles = [];
  Role? selectedRole;

  List<Branch> branches = [];
  Branch? selectedBranch;

  String selectedGender = 'Male';
  DateTime? selectedDate;
  File? selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _loadBranches();

    if (widget.existingUser != null) {
      final u = widget.existingUser!;
      _firstnameController.text = u.firstname;
      _lastnameController.text = u.lastname;
      _usernameController.text = u.username;
      _emailController.text = u.email;
      _passwordController.text = u.password ?? '';
      selectedGender = u.gender;
      selectedDate = DateTime.parse(u.birthdate);
    }
  }

  Future<void> _loadRoles() async {
    try {
      final fetchedRoles = await _roleService.getAll();
      setState(() {
        roles = fetchedRoles;
        if (widget.existingUser != null) {
          selectedRole = fetchedRoles.firstWhere(
            (r) => r.id == widget.existingUser!.roleId,
          );
        } else {
          selectedRole = fetchedRoles.isNotEmpty ? fetchedRoles.first : null;
        }
      });
    } catch (e) {
      print('Error loading roles: $e');
    }
  }

  Future<void> _loadBranches() async {
    try {
      final fetchedBranches = await _branchService.getAll();
      setState(() {
        branches = fetchedBranches;
        if (widget.existingUser != null) {
          selectedBranch = fetchedBranches.firstWhere(
            (b) => b.id == widget.existingUser!.branchId,
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

  Future<void> _submitUser() async {
    if (_firstnameController.text.isEmpty ||
        _lastnameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        selectedDate == null ||
        selectedRole == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = User(
        id: widget.existingUser?.id ?? 0,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password:
            _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
        gender: selectedGender,
        imageUrl: null,
        birthdate: DateFormat('yyyy-MM-dd').format(selectedDate!),
        roleId: selectedRole!.id!,
        branchId: selectedBranch!.id,
      );

      if (widget.existingUser != null) {
        await _userService.updateUser(user.id, user, selectedImage);
      } else {
        print('Sending user data: ${user.toJson()}');
        await _userService.createUser(user, selectedImage);
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingUser != null;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? 'Edit User' : 'Add User'),
        trailing:
            _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _submitUser,
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
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
              _buildTextField('First Name *', _firstnameController),
              _buildTextField('Last Name *', _lastnameController),
              _buildTextField('Username *', _usernameController),
              _buildTextField('Email *', _emailController),
              _buildTextField('Password', _passwordController, isObscure: true),
              const SizedBox(height: 12),
              const Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CupertinoSegmentedControl<String>(
                children: const {
                  'Male': Text('Male'),
                  'Female': Text('Female'),
                },
                groupValue: selectedGender,
                onValueChanged:
                    (value) => setState(() => selectedGender = value),
              ),
              const SizedBox(height: 16),
              const Text(
                'Birthdate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                child: Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : 'Select Date',
                ),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
              CupertinoButton(
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
                                roles.indexWhere(
                                  (r) => r.id == selectedRole?.id,
                                ),
                              ),
                            ),
                            onSelectedItemChanged:
                                (index) =>
                                    setState(() => selectedRole = roles[index]),
                            children: roles.map((r) => Text(r.name)).toList(),
                          ),
                        ),
                  );
                },
                child: Text(selectedRole?.name ?? 'Select Role'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Branch',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
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
                child: Text(selectedBranch?.name ?? 'Select Branch'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          obscureText: isObscure,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
      ],
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
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(child: child),
    );
  }
}
