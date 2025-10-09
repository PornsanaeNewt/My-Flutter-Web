import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/services/api.dart';

class CourseController {

  static final Random _random = Random();
  static const _chars = '1234567890';

  static String _generateRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)))); //
  
  static String generateNewCourseId() {
    return 'Course${_generateRandomString(4)}';
  }
  
  static Future<List<Map<String, dynamic>>> loadCourseTypes() async {
    try {
      final response = await Api.listCourseTypes();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load course types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading course types: $e');
    }
  }

  //get instructor
  static Future<List<Instructor>> loadInstructors(String schoolID) async {
    try {
      final response = await Api.listInstructors(schoolID);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Instructor(
          instructorId: json['instructorId'].toString(),
          instructorName: json['instructorName'],
          instructorLname: json['instructorLname'],
          instructorEmail: json['instructorEmail'],
          instructorBirthday: DateTime.tryParse(json['instructorBirthday'] ?? ''),
          instructorGender: json['instructorGender'] == 1,
          instructorPicture: json['instructorPicture'],
          instructorTel: json['instructorTel'],
          schoolId: json['schoolId'].toString(),
        )).toList();
      } else {
        throw Exception('Failed to load instructors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading instructors: $e');
    }
  }

  static Future<bool> createCourse({
    required String courseId,
    required String courseName,
    required String courseDescription,
    required String coursePrice,
    required String courseRating,
    required String courseTypeId,
    required String schoolId,
    required List<XFile> pickedImageFiles,
    required List<Uint8List> imageBytesList,
    required List<CourseDetail> courseSchedules,
  }) async {
    // Step 1: Create Course
    var courseRequest = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/course/createCourse'),
    );
    courseRequest.fields['courseId'] = courseId;
    courseRequest.fields['courseDescription'] = courseDescription;
    courseRequest.fields['courseName'] = courseName;
    courseRequest.fields['coursePrice'] = coursePrice;
    courseRequest.fields['courseRating'] = courseRating;
    courseRequest.fields['courseTypeId'] = courseTypeId;
    courseRequest.fields['schoolId'] = schoolId;

    var courseResponse = await courseRequest.send();
    var courseResponseBody = await courseResponse.stream.bytesToString();

    if (courseResponse.statusCode != 201) {
      throw Exception('Failed to create course: $courseResponseBody');
    }

    // Step 2: Upload Images
    var imageRequest = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/course/uploadImage'),
    );
    imageRequest.fields['courseId'] = courseId;
    for (int i = 0; i < pickedImageFiles.length; i++) {
      if (kIsWeb) {
        imageRequest.files.add(http.MultipartFile.fromBytes(
          'imageUrl',
          imageBytesList[i],
          filename: pickedImageFiles[i].name,
          contentType: MediaType('image', pickedImageFiles[i].name.split('.').last),
        ));
      } else {
        imageRequest.files.add(await http.MultipartFile.fromPath(
          'imageUrl',
          pickedImageFiles[i].path,
          filename: pickedImageFiles[i].name,
          contentType: MediaType('image', pickedImageFiles[i].name.split('.').last),
        ));
      }
    }

    var imageResponse = await imageRequest.send();
    var imageResponseBody = await imageResponse.stream.bytesToString();

    if (imageResponse.statusCode != 201) {
      throw Exception('Failed to upload images: $imageResponseBody');
    }

    // Step 3: Create Schedules
    bool allSchedulesAdded = true;
    for (var schedule in courseSchedules) {
      var scheduleBody = {
        'scheduleId': schedule.id == 0 ? null : schedule.id,
        'capacity': schedule.capacity,
        'endDate': schedule.endDate,
        'registClose': schedule.registClose,
        'registOpen': schedule.registOpen,
        'scheduleStatus': 'open',
        'startDate': schedule.startDate,
        'studyTime': schedule.time,
        'courseId': courseId,
        'instructorId': schedule.instructorId,
      };

      final scheduleResponse = await http.post(
        Uri.parse('http://localhost:3000/coursedetail/createSchedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(scheduleBody),
      );
      if (scheduleResponse.statusCode != 201) {
        allSchedulesAdded = false;
        print('Failed to add schedule: ${scheduleResponse.body}');
        break;
      }
    }
    if (!allSchedulesAdded) {
      throw Exception('Failed to add all schedules.');
    }
    
    return true;
  }
  // Get Course By Id
  static Future<Course> fetchCourseById(String courseId) async {
    try {
      final response = await Api.getCourseById(courseId);
      if (response.statusCode == 200) {
        final List<dynamic> courseData = jsonDecode(response.body);
        if (courseData.isNotEmpty) {
          return Course.fromJson(courseData[0]);
        }
      }
      throw Exception('Failed to load course details');
    } catch (e) {
      throw Exception('Error fetching course details: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCourseTypes() async {
    try {
      final response = await Api.listCourseTypes();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load course types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading course types: $e');
    }
  }

  static Future<List<Course>> fetchCoursesBySchoolId(String schoolId) async {
    try {
      final response = await Api.listCourseBySchool(schoolId);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Course.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading courses: $e');
    }
  }
  
  static Future<void> deleteCourse(Course course) async {
    if (course.id == null) {
      throw Exception('Course ID cannot be null for deletion.');
    }
    try {
      final imageUrls = await fetchCourseImages(course.id!);
      for (final imageUrl in imageUrls) {
        await deleteCourseImage(imageUrl);
        print('Deleted image: $imageUrl');
      }
      final response = await Api.deleteCourse(course.id!);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting course or its images: $e');
    }
  }

  //fetch course type name
  static Future<String> fetchCourseTypeName(int courseTypeId) async {
    try {
      final response = await Api.getCourseTypeById(courseTypeId.toString());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.isNotEmpty ? data[0]['courseType'] : 'Unknown';
      }
    } catch (e) {
      print('Error fetching course type: $e');
    }
    return 'Unknown';
  }

  // fetch a random course image
  static Future<String?> fetchCourseRandomImage(String? courseId) async {
    if (courseId == null) return null;
    try {
      final response = await Api.getCoursePictureById(courseId);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['imageUrls'] != null && data['imageUrls'] is List && data['imageUrls'].isNotEmpty) {
          List<String> imageUrls = List<String>.from(data['imageUrls']);
          final _random = Random();
          return imageUrls[_random.nextInt(imageUrls.length)];
        }
      }
    } catch (e) {
      print('Error fetching course image: $e');
    }
    return null;
  }
  //fetch a course image
  static Future<List<String>> fetchCourseImages(String courseId) async {
    try {
      final response = await Api.getCoursePictureById(courseId);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['imageUrls'] != null && data['imageUrls'] is List) {
          return List<String>.from(data['imageUrls']);
        }
      }
    } catch (e) {
      print('Error fetching course images: $e');
    }
    return [];
  }

  //Course Detail
  static Future<List<CourseDetail>> fetchCourseDetails(String courseId) async {
    try {
      final response = await Api.getCourseDetails(courseId);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CourseDetail.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching course schedules: $e');
    }
    return [];
  }
  //fetch a Instructors
  static Future<List<Instructor>> fetchInstructors(String schoolID) async {
    try {
      final response = await Api.listInstructors(schoolID);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Instructor(
          instructorId: json['instructorId'].toString(),
          instructorName: json['instructorName'],
          instructorLname: json['instructorLname'],
          instructorEmail: json['instructorEmail'],
          instructorBirthday: DateTime.tryParse(json['instructorBirthday'] ?? ''),
          instructorGender: json['instructorGender'] == 1,
          instructorPicture: json['instructorPicture'],
          instructorTel: json['instructorTel'],
          schoolId: json['schoolId'].toString(),
        )).toList();
      }
    } catch (e) {
      print('Error fetching instructors: $e');
    }
    return [];
  }

  //count registration
  static Future<int> fetchRegistrationCount(int scheduleId) async {
  try {
    final response = await Api.countRegistration(scheduleId);
    print("Result Count : ${response.body}");
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body);
      if (results is Map && results['count'] != null) {
        return results['count'] as int;
      }
    }
  } catch (e) {
    print('Error fetching registration count: $e');
  }
  return 0;
  }

  //add schedule
  static Future<void> addSchedule(CourseDetail newSchedule) async {
    try {
      final response = await Api.createSchedule(newSchedule.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to add schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding schedule: $e');
    }
  }

  //update schedule
  static Future<void> updateSchedule(CourseDetail updatedSchedule) async {
    try {
      final response = await Api.updateCourseDetail(updatedSchedule.id, updatedSchedule.toJson());
      if (response.statusCode != 200) {
        throw Exception('Failed to update schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating schedule: $e');
    }
  }

  //delete schedlue
  static Future<void> deleteSchedule(int scheduleId) async {
    try {
      final response = await Api.deleteCourseDetail(scheduleId);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting schedule: $e');
    }
  }

  //open and close course
  static Future<void> openAndCloseSchedule(int scheduleId, String newStatus) async {
    try {
      final response = await Api.openAndCloseSchedule(scheduleId, {'scheduleStatus': newStatus});
      if (response.statusCode != 200) {
        throw Exception('Failed to update schedule status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating schedule status: $e');
    }
  }

  // Check for schedule overlap
  static Future<bool> checkInstructorScheduleOverlap(String instructorId, String startDate, String endDate, int? currentScheduleId) async {
    try {
      final response = await Api.getCourseDetailByInstructor(instructorId);
      if (response.statusCode == 200) {
        final List<dynamic> schedules = jsonDecode(response.body);
        final newStartDate = DateTime.parse(startDate);
        final newEndDate = DateTime.parse(endDate);
        
        for (var scheduleJson in schedules) {
          final schedule = CourseDetail.fromJson(scheduleJson);
          if (schedule.id == currentScheduleId) {
            continue;
          }
          final existingStartDate = DateTime.parse(schedule.startDate);
          final existingEndDate = DateTime.parse(schedule.endDate);
          
          if (newStartDate.isBefore(existingEndDate) && newEndDate.isAfter(existingStartDate)) {
            return true;
          }
        }
        return false;
      } else if (response.statusCode == 404) {
        return false;
      }
    } catch (e) {
      print('Error checking for overlap: $e');
      return true;
    }
    return true;
  }

  // New function to update course details and upload images
  static Future<void> updateCourseDetails({
    required String courseId,
    required String courseName,
    required String courseDescription,
    required double coursePrice,
    required int courseTypeId,
    required List<XFile> pickedImageFiles,
    required List<Uint8List> pickedImageBytesList,
  }) async {
    final courseData = {
      'courseName': courseName,
      'courseDescription': courseDescription,
      'coursePrice': coursePrice,
      'courseTypeId': courseTypeId,
    };
    final updateResponse = await Api.updateCourse(
      courseId,
      courseData,
    );

    if (updateResponse.statusCode != 200) {
      throw Exception('Failed to update course details: ${updateResponse.body}');
    }

    if (pickedImageFiles.isNotEmpty) {
      final uploadResponse = await Api.uploadCourseImages(
        courseId: courseId,
        pickedImageFiles: pickedImageFiles,
        pickedImageBytesList: pickedImageBytesList,
      );

      if (uploadResponse.statusCode != 201) {
        throw Exception('Failed to upload new images: ${uploadResponse.body}');
      }
    }
  }
  
  // function to delete an existing course image
  static Future<void> deleteCourseImage(String imageUrl) async {
    final response = await Api.deleteCourseImage(imageUrl);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete image: ${response.body}');
    }
  }

}