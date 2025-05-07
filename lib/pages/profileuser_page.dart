import 'package:botbuilder/models/user.dart';
import 'package:botbuilder/services/auth_service.dart';
import 'package:botbuilder/services/branch_service.dart';
import 'package:botbuilder/services/role_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({super.key});

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final BranchService _branchService = BranchService();
  final RoleService _roleService = RoleService();
  final AuthService _authService = AuthService();
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    final fetchedUser = await _authService.getUser();
    setState(() {
      user = User.fromJson(fetchedUser!);
      isLoading = false;
    });
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child:
            isLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 16))
                : user == null
                ? Center(
                  child: Text(
                    'No user data found',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User Header (Image, Name, Email)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  user!.imageUrl != null
                                      ? Image.network(
                                        '${dotenv.env['API_BASE_URL']}${user!.imageUrl}',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: CupertinoColors.systemGrey4,
                                            child: const Icon(
                                              CupertinoIcons.person,
                                              size: 64,
                                              color:
                                                  CupertinoColors.inactiveGray,
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        width: 100,
                                        height: 100,
                                        color: CupertinoColors.systemGrey4,
                                        child: const Icon(
                                          CupertinoIcons.person,
                                          size: 64,
                                          color: CupertinoColors.inactiveGray,
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${user!.firstname} ${user!.lastname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: CupertinoColors.black,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user!.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.inactiveGray,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Username: ${user!.username}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gender: ${user!.gender}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Age: ${calculateAge(user!.birthdate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Birthdate: ${user!.birthdate}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder(
                              future: _roleService.getById(user!.roleId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(fontSize: 16),
                                  );
                                }
                                final role = snapshot.data;
                                return Text(
                                  'Role: ${role!.name}',
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder(
                              future: _branchService.getById(user!.branchId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(fontSize: 16),
                                  );
                                }
                                final branch = snapshot.data;
                                return Text(
                                  'Branch: ${branch!.name}',
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
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
