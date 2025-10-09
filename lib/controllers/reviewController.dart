import 'dart:convert';
import 'package:project_web/services/api.dart';

class ReviewService {
  Future<List<dynamic>> fetchReviewsByCourse(String courseId) async {
    try {
      final response = await Api.listReviewsByCourse(courseId);

      if (response.statusCode == 200) {
        final List<dynamic> reviewJson = jsonDecode(response.body);
        return reviewJson; 
      } else {
        print('Failed to load reviews. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('An error occurred while fetching reviews: $e');
      return [];
    }
  }
}