import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:botbuilder/models/user.dart';
import 'package:botbuilder/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final fetched = await _userService.getUsers();
    setState(() {
      users = fetched;
      isLoading = false;
    });
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
                      // Header: Title + Add Button
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
                            onPressed: () {
                              // TODO: ADD action
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search Bar (แยกมาแล้ว)
                      SearchBar(
                        placeholder: 'Search...',
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Grid View
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 1,
                          mainAxisSpacing: 16,
                          childAspectRatio: 4,
                          children:
                              filteredUsers.map((user) {
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
                                                  dotenv.env['API_BASE_URL']! +
                                                      user.imageUrl!,
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
                                      Column(
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
                                              color:
                                                  CupertinoColors.inactiveGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
