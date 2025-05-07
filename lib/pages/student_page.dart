import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:botbuilder/models/student.dart';
import 'package:botbuilder/services/student_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:botbuilder/pages/addstudent_page.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final StudentService _studentService = StudentService();
  List<Student> students = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // Fetch students data from API
  Future<void> loadStudents() async {
    setState(() => isLoading = true);
    final fetched = await _studentService.getStudents();
    setState(() {
      students = fetched;
      isLoading = false;
    });
  }

  // Function to handle delete operation
  Future<void> deleteStudent(int id) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this student?',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _studentService.deleteStudent(id);
      await loadStudents(); // Reload data after deleting
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents =
        students.where((student) {
          return student.firstname.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        }).toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Students'),
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
                        'Students',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      AddButton(
                        onPressed: () async {
                          final result = await Get.to(
                            () => const AddStudentPage(),
                          );
                          if (result == true) await loadStudents();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SearchBar(
                    placeholder: 'Search students...',
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // ส่วนกริดนักเรียน (เลื่อนได้)
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
                            : filteredStudents.isEmpty
                            ? SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No students found',
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
                                final student = filteredStudents[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(16),
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            student.imageUrl != null &&
                                                    student.imageUrl!.isNotEmpty
                                                ? Image.network(
                                                  '${dotenv.env['API_BASE_URL']}${student.imageUrl!}',
                                                  fit: BoxFit.cover,
                                                  width: 150,
                                                  height: 150,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 150,
                                                      height: 150,
                                                      color:
                                                          CupertinoColors
                                                              .systemGrey4,
                                                      child: const Icon(
                                                        CupertinoIcons.person,
                                                        size: 120,
                                                        color:
                                                            CupertinoColors
                                                                .inactiveGray,
                                                      ),
                                                    );
                                                  },
                                                )
                                                : Container(
                                                  width: 150,
                                                  height: 150,
                                                  color:
                                                      CupertinoColors
                                                          .systemGrey4,
                                                  child: const Icon(
                                                    CupertinoIcons.person,
                                                    size: 120,
                                                    color:
                                                        CupertinoColors
                                                            .inactiveGray,
                                                  ),
                                                ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        student.firstname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: CupertinoColors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        student.lastname,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minSize: 0,
                                            child: const Icon(
                                              CupertinoIcons.pencil,
                                              size: 20,
                                              color: CupertinoColors.activeBlue,
                                            ),
                                            onPressed: () async {
                                              final result = await Get.to(
                                                () => AddStudentPage(
                                                  existingStudent: student,
                                                ),
                                              );
                                              if (result == true)
                                                await loadStudents();
                                            },
                                          ),
                                          CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
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
                                                () => deleteStudent(student.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }, childCount: filteredStudents.length),
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
