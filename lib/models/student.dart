class Student {
  final int id;
  final String firstname;
  final String lastname;
  final String? imageUrl;
  final String birthdate;
  final int branchId;

  Student({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.imageUrl,
    required this.birthdate,
    required this.branchId,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    firstname: json['firstname'],
    lastname: json['lastname'],
    imageUrl: json['imageUrl'] as String?,
    birthdate: json['birthdate'],
    branchId: json['branch']?['id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'imageUrl': imageUrl,
    'birthdate': birthdate,
    'branchId': branchId,
  };
}
