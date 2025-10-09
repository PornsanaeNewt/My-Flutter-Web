class Course {
  final String? id;
  final String? name;
  final String? description;
  final double? rating;
  final double? price;
  final int courseTypeId;
  final String? schoolId;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.courseTypeId,
    required this.schoolId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['courseId'].toString(),
      name: json['courseName'] ?? '',
      description: json['courseDescription'] ?? '',
      price: (json['coursePrice'] ?? 0).toDouble(),
      rating: (json['courseRating'] ?? 0.0).toDouble(),
      courseTypeId: json['courseTypeId'],
      schoolId: json['schoolId'].toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'courseTypeId': courseTypeId,
      'schoolId': courseTypeId,
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? description,
    double? rating,
    double? price,
    int? courseTypeId,
    String? schoolId,
    
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      courseTypeId: courseTypeId ?? this.courseTypeId,
      price: price ?? this.price,
      schoolId: schoolId ?? this.schoolId,
    );
  }
}