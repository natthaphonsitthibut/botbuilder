import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final List<Map<String, String>> users = [
    {
      'name': 'Natthaphon Sitthibut',
      'email': 'natthaphonstb@gmail.com',
      'image': 'assets/images/legospike.png',
    },
    {
      'name': 'Siriwan J.',
      'email': 'siriwan@email.com',
      'image': 'assets/images/legospike.png',
    },
    {
      'name': 'Anan S.',
      'email': 'anan@email.com',
      'image': 'assets/images/legospike.png',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        users
            .where(
              (u) =>
                  u['name']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  u['email']!.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('User')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ปุ่ม Add และช่องค้นหา
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      placeholder: 'Search',
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: CupertinoColors.activeGreen,
                    onPressed: () {
                      // TODO: Add action
                    },
                    child: const Text('ADD'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // รายการผู้ใช้งาน
              Expanded(
                child: GridView.builder(
                  itemCount: filteredUsers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    childAspectRatio: 4,
                  ),
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
                            child: Image.asset(
                              user['image']!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user['email']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.inactiveGray,
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
