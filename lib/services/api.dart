import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class Api {
  static const String baseUrl = "http://localhost:3000/";
  //School API
  //Login School
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("${baseUrl}school/login");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'schoolEmail': email,
        'schoolPassword': password,
      }),
    );
  }
  // get a school by its email address
  static Future<http.Response> getSchoolByEmail(String email) async {
    final response = await http.get(
      Uri.parse('${baseUrl}school/read/single/$email'),
    );
    return response;
  }

  //instructor API
  // list instructor
  static Future<http.Response> listInstructors(String schoolId) async {
    final url = Uri.parse("${baseUrl}instructor/listInstructorBySchool/$schoolId");
    return await http.get(url);
  }

  // get instructor name
  static Future<http.Response> getInstructorName(int instructorId) async {
    final url = Uri.parse("${baseUrl}getInstructorName/$instructorId");
    return await http.get(url);
  }

  // get instructor by ID
  static Future<http.Response> getInstructorById(String instructorId) async {
    final url = Uri.parse("${baseUrl}instructor/getInstructorById/$instructorId");
    return await http.get(url);
  }

  // delete instructor
  static Future<http.Response> deleteInstructor(String instructorID) async {
    final url = Uri.parse("${baseUrl}instructor/deleteInstructor/$instructorID");
    return await http.delete(url);
  }

  //Course API
  // list course type
  static Future<http.Response> listCourseTypes() async {
    final url = Uri.parse("${baseUrl}coursetype/listCourseType");
    return await http.get(url);
  }

  //get a course type by its ID
  static Future<http.Response> getCourseTypeById(String courseTypeId) async {
    final url = Uri.parse("${baseUrl}coursetype/getCourseTypeById/$courseTypeId");
    return await http.get(url);
  }

  //get a course by ID
  static Future<http.Response> getCourseById(String courseId) async {
    final url = Uri.parse("${baseUrl}course/getCourseById/$courseId");
    return await http.get(url);
  }

  // update course
  static Future<http.Response> updateCourse(String courseId, Map<String, dynamic> cdata) async {
    final url = Uri.parse("${baseUrl}course/updateCourse/$courseId");
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cdata),
    );
  }

  // delete course
  static Future<http.Response> deleteCourse(String courseId) async {
    final url = Uri.parse("${baseUrl}course/deleteCourse/$courseId");
    return await http.delete(url);
  }

  //Course Detail API
  //get a course detail by instructor ID
  static Future<http.Response> getCourseDetailByInstructor(String instructorId) async {
    final url = Uri.parse("${baseUrl}coursedetail/getCourseDetailByInstructor/$instructorId");
    return await http.get(url);
  }

  // delete course detail
  static Future<http.Response> deleteCourseDetail(int scheduleId) async {
    final url = Uri.parse("${baseUrl}coursedetail/deleteSchedule/$scheduleId");
    return await http.delete(url);
  }

  //update course detail
  static Future<http.Response> updateCourseDetail(int scheduleId, Map<String, dynamic> cdata) async {
    final url = Uri.parse("${baseUrl}coursedetail/updateSchedule/$scheduleId");
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cdata),
    );
  }
  
  //get course pictures by course ID
  static Future<http.Response> getCoursePictureById(String courseId) async {
    final url = Uri.parse("${baseUrl}course/getCoursePictureById/$courseId");
    return await http.get(url);
  }

  // create schedule
  static Future<http.Response> createSchedule(Map<String, dynamic> sdata) async {
    final url = Uri.parse("${baseUrl}coursedetail/createSchedule");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sdata),
    );
  }
  // get course detail 
  static Future<http.Response> getCourseDetails(String courseId) async {
    final url = Uri.parse("${baseUrl}coursedetail/getCourseDetailById/$courseId");
    return await http.get(url);
  }

  //List Course By school
  static Future<http.Response> listCourseBySchool(String schoolId) async {
    final url = Uri.parse("${baseUrl}course/listCourseBySchool/$schoolId");
    return await http.get(url);
  }

  //Registration
  //Count Registration
  static Future<http.Response> countRegistration(int scheduleId) async {
    final url = Uri.parse("${baseUrl}registration/countRegistration/$scheduleId");
    return await http.get(url);
  }

  //List Registration by Schedule
  static Future<http.Response> listRegistBySchedule(int scheduleId) async {
    final url = Uri.parse("${baseUrl}registration/listRegistBySchedule/$scheduleId");
    return await http.get(url);
  }

  static Future<http.Response> deleteRegistration(int registId) async {
  final url = Uri.parse("${baseUrl}registration/deleteRegistration/$registId");
  return await http.delete(url);
}

  static Future<http.Response> completeStudy(int scheduleId) async {
  final url = Uri.parse("${baseUrl}registration/completeStudy/$scheduleId");
  return await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'registStatus': 'Completed',
    }),
  );
  }
  
  // open and close schedule
  static Future<http.Response> openAndCloseSchedule(int scheduleId, Map<String, dynamic> status) async {
    final url = Uri.parse("${baseUrl}coursedetail/OpenAndClose/$scheduleId");
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(status),
    );
  }

   // fetching a student by their ID.
  static Future<http.Response> getStudentById(String stuId) async {
    final url = Uri.parse("${baseUrl}student/getStudentById/$stuId");
    return await http.get(url);
  }

  // function to upload images
  static Future<http.Response> uploadCourseImages({
    required String courseId,
    required List<XFile> pickedImageFiles,
    required List<Uint8List> pickedImageBytesList,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}course/uploadImage'),
    );
    request.fields['courseId'] = courseId;

    for (int i = 0; i < pickedImageFiles.length; i++) {
      final file = pickedImageFiles[i];
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'imageUrl',
          pickedImageBytesList[i],
          filename: file.name,
          contentType: MediaType('image', file.name.split('.').last),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'imageUrl',
          file.path,
          filename: file.name,
          contentType: MediaType('image', file.name.split('.').last),
        ));
      }
    }

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  // Delete course image
  static Future<http.Response> deleteCourseImage(String imageUrl) async {
    final url = Uri.parse('${baseUrl}course/deleteImage/$imageUrl');
    return await http.delete(url);
  }

  //School API
  //get a school by ID
  static Future<http.Response> getSchoolById(String schoolId) async {
    final url = Uri.parse("${baseUrl}school/getSchoolById/$schoolId");
    return await http.get(url);
  }

  //Notification API
  // Add new notification
  static Future<http.Response> addNotification(Map<String, dynamic> data) async {
    final url = Uri.parse("${baseUrl}notification/addNotification");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  // Review API
  static Future<http.Response> listReviewsByCourse(String courseId) async {
    final url = Uri.parse("${baseUrl}review/listReviewByCourse/$courseId");
    return await http.get(url);
  }

}
