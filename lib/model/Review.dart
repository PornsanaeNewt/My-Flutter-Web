class Review {
  final String reviewDate;
  final double reviewPoint; 
  final String reviews;
  final int registId;
  final String courseId;

  Review({
    required this.reviewDate,
    required this.reviewPoint,
    required this.reviews,
    required this.registId,
    required this.courseId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewDate: json['reviewDate'] as String,
      reviewPoint: (json['reviewPoint'] as num).toDouble(), 
      reviews: json['reviews'] as String,
      registId: json['registId'] as int,
      courseId: json['courseId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewDate': reviewDate,
      'reviewPoint': reviewPoint,
      'reviews': reviews,
      'registId': registId,
      'courseId': courseId,
    };
  }
}