class Model {
  final int id;
  final String name;
  final String? imageUrl;
  final String? pdfUrl;
  final int? courseId;

  Model({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pdfUrl,
    required this.courseId,
  });

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    id: json['id'],
    name: json['name'],
    imageUrl: json['imageUrl'] as String?,
    pdfUrl: json['pdfUrl'],
    courseId: json['course']?['id'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'pdfUrl': pdfUrl,
    'courseId': courseId,
  };
}
