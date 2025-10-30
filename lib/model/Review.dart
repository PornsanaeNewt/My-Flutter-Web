class Review {
  final String reviewDate;
  final double reviewPoint; 
  final String reviews;
  final int registId;
  final int scheduleId;

  Review({
    required this.reviewDate,
    required this.reviewPoint,
    required this.reviews,
    required this.registId,
    required this.scheduleId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewDate: json['reviewDate'] as String,
      reviewPoint: (json['reviewPoint'] as num).toDouble(), 
      reviews: json['reviews'] as String,
      registId: json['registId'] as int,
      scheduleId: json['scheduleId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewDate': reviewDate,
      'reviewPoint': reviewPoint,
      'reviews': reviews,
      'registId': registId,
      'scheduleId': scheduleId,
    };
  }
}