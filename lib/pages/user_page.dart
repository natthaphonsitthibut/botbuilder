import 'package:botbuilder/services/branch_service.dart';
import 'package:botbuilder/services/role_service.dart';
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
  final BranchService _branchService = BranchService();
  final RoleService _roleService = RoleService();
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

  int calculateAge(String birthdate) {
    final birthDate = DateTime.parse(birthdate);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Users'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Users',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
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
                  SearchBar(
                    placeholder: 'Search users...',
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
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
                            : filteredUsers.isEmpty
                            ? SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final user = filteredUsers[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                user.imageUrl != null &&
                                                        user
                                                            .imageUrl!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      '${dotenv.env['API_BASE_URL']}${user.imageUrl!}',
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 60,
                                                          height: 60,
                                                          color:
                                                              CupertinoColors
                                                                  .systemGrey4,
                                                          child: const Icon(
                                                            CupertinoIcons
                                                                .person,
                                                            size: 40,
                                                            color:
                                                                CupertinoColors
                                                                    .inactiveGray,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Container(
                                                      width: 60,
                                                      height: 60,
                                                      color:
                                                          CupertinoColors
                                                              .systemGrey4,
                                                      child: const Icon(
                                                        CupertinoIcons.person,
                                                        size: 40,
                                                        color:
                                                            CupertinoColors
                                                                .inactiveGray,
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${user.firstname} ${user.lastname}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color:
                                                        CupertinoColors.black,
                                                  ),
                                                ),
                                                Text(
                                                  user.email,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        CupertinoColors
                                                            .inactiveGray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        'Username: ${user.username}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Gender: ${user.gender}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Age: ${calculateAge(user.birthdate)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Birthdate: ${user.birthdate}',
                                        style: const TextStyle(fontSize: 14),
                                      ),

                                      FutureBuilder(
                                        future: _roleService.getById(
                                          user.roleId,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('Loading...');
                                          }
                                          final role = snapshot.data;
                                          return Text(
                                            'Role: ${role!.name}',

                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          );
                                        },
                                      ),
                                      FutureBuilder(
                                        future: _branchService.getById(
                                          user.branchId,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('Loading...');
                                          }
                                          final branch = snapshot.data;
                                          return Text(
                                            'Branch: ${branch!.name}',

                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                () => AddUserPage(
                                                  existingUser: user,
                                                ),
                                              );
                                              if (result == true)
                                                await loadUsers();
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
                                                () => deleteUser(user.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }, childCount: filteredUsers.length),
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
