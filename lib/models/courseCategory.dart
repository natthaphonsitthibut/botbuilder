class CourseCategory {
  final int id;
  final String name;

  CourseCategory({required this.id, required this.name});

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
