class Course {
  final int id;
  final String name;
  final int courseCategoryId;
  final List<int>? modelsId;

  Course({
    required this.id,
    required this.name,
    required this.courseCategoryId,
    this.modelsId,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'],
    name: json['name'],
    courseCategoryId: json['courseCategory']['id'] as int,
    modelsId:
        (json['models'] as List<dynamic>?)
            ?.map((e) => e['id'] as int)
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'courseCategoryId': courseCategoryId,
    'modelsId': modelsId,
  };
}
