class Model {
  final int? id;
  final String name;
  final String? imageUrl;
  final String? pdfUrl;
  final int? courseId;

  Model({
    this.id,
    required this.name,
    this.imageUrl,
    this.pdfUrl,
    this.courseId,
  });

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    id: json['id'] as int?,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    pdfUrl: json['pdfUrl'] as String?,
    courseId: json['course']?['id'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'pdfUrl': pdfUrl,
    'courseId': courseId,
  };
}
