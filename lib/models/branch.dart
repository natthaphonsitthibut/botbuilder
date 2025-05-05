class Branch {
  final int id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) =>
      Branch(id: json['id'], name: json['name']);
}
