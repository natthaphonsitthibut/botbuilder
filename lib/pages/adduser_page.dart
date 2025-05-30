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
                ? const CupertinoActivityIndicator(radius: 12)
                : CupertinoButton(
                  padding: EdgeInsets.zero,

                  onPressed: _submitUser,
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
              // User Image
              const Text(
                'User Image',
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

              // Username
              const Text(
                'Username *',
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
                  controller: _usernameController,
                  placeholder: 'Enter username',
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

              // Email
              const Text(
                'Email *',
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
                  controller: _emailController,
                  placeholder: 'Enter email',
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

              // Password
              const Text(
                'Password',
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
                  controller: _passwordController,
                  placeholder: 'Enter password',
                  placeholderStyle: TextStyle(
                    color: CupertinoColors.inactiveGray.withOpacity(0.6),
                  ),
                  obscureText: true,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Gender
              const Text(
                'Gender *',
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
                child: CupertinoSegmentedControl<String>(
                  children: const {
                    'Male': Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text('Male', style: TextStyle(fontSize: 16)),
                    ),
                    'Female': Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text('Female', style: TextStyle(fontSize: 16)),
                    ),
                  },
                  groupValue: selectedGender,
                  onValueChanged:
                      (value) => setState(() => selectedGender = value),
                  borderColor: CupertinoColors.activeBlue,
                  selectedColor: CupertinoColors.activeBlue,
                  unselectedColor: CupertinoColors.white,
                  pressedColor: CupertinoColors.activeBlue.withOpacity(0.2),
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

              // Role
              const Text(
                'Role *',
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
                                  roles.indexWhere(
                                    (r) => r.id == selectedRole?.id,
                                  ),
                                ),
                              ),
                              onSelectedItemChanged:
                                  (index) => setState(
                                    () => selectedRole = roles[index],
                                  ),
                              children: roles.map((r) => Text(r.name)).toList(),
                            ),
                          ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedRole?.name ?? 'Select role',
                        style: TextStyle(
                          color:
                              selectedRole != null
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
