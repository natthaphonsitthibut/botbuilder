class User {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final String? password;
  final String gender;
  final String? imageUrl;
  final String birthdate;
  final int roleId;
  final int branchId;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    this.imageUrl,
    required this.birthdate,
    required this.roleId,
    required this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    firstname: json['firstname'],
    lastname: json['lastname'],
    username: json['username'],
    email: json['email'],
    password: json['password'],
    gender: json['gender'],
    imageUrl: json['imageUrl'] as String?,
    birthdate: json['birthdate'],
    roleId: json['role']['id'] as int,
    branchId: json['branch']?['id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'username': username,
    'email': email,
    'password': password,
    'gender': gender,
    'imageUrl': imageUrl,
    'birthdate': birthdate,
    'roleId': roleId,
    'branchId': branchId,
  };
}
