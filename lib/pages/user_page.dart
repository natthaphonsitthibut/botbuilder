import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:botbuilder/models/user.dart';
import 'package:botbuilder/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../pages/adduser_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  List<User> users = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    final fetched = await _userService.getUsers();
    setState(() {
      users = fetched;
      isLoading = false;
    });
  }

  Future<void> deleteUser(int id) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this user?'),
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
      await _userService.deleteUser(id);
      await loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        users.where((u) {
          return u.firstname.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              u.email.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('User')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "User",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AddButton(
                            onPressed: () async {
                              final result = await Get.to(
                                () => const AddUserPage(),
                              );
                              if (result == true) await loadUsers();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search Bar
                      SearchBar(
                        placeholder: 'Search...',
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // User List
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredUsers.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        user.imageUrl != null
                                            ? Image.network(
                                              '${dotenv.env['API_BASE_URL']}${user.imageUrl!}',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                            : const Icon(
                                              CupertinoIcons.person,
                                              size: 60,
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.firstname,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.inactiveGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minSize: 0,
                                        onPressed: () async {
                                          final result = await Get.to(
                                            () =>
                                                AddUserPage(existingUser: user),
                                          );
                                          if (result == true) await loadUsers();
                                        },
                                        child: const Icon(
                                          CupertinoIcons.pencil,
                                          size: 22,
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minSize: 0,
                                        onPressed: () => deleteUser(user.id),
                                        child: const Icon(
                                          CupertinoIcons.delete,
                                          size: 22,
                                          color: CupertinoColors.destructiveRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
