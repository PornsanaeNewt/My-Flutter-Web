import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_web/services/api.dart';

class InstructorController {
  static Future<List<Instructor>> loadInstructorsBySchool(String schoolID) async {
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
      print('Error loading instructors: $e');
      throw Exception('Failed to load instructors: $e');
    }
  }

  static Future<String?> getSchoolID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('schoolID');
  }

  // delete instructor
  static Future<void> deleteInstructor(String instructorID) async {
    try {
      final response = await Api.deleteInstructor(instructorID);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete instructor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete instructor: $e');
    }
  }

  // New method to fetch instructor details by ID
  static Future<Instructor> fetchInstructorDetails(String instructorId) async {
    try {
      final response = await Api.getInstructorById(instructorId);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Instructor(
            instructorId: data['instructorId']?.toString(),
            instructorName: data['instructorName'],
            instructorLname: data['instructorLname'],
            instructorEmail: data['instructorEmail'],
            instructorBirthday: DateTime.tryParse(data['instructorBirthday'] ?? ''),
            instructorGender: data['instructorGender'] == 1,
            instructorPicture: data['instructorPicture'],
            instructorTel: data['instructorTel'],
            schoolId: data['schoolId']?.toString(),
        );
      } else {
        throw Exception('Failed to load instructor details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching instructor details: $e');
    }
  }

  // New method to add an instructor
  static Future<bool> addInstructor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String birthday,
    required String gender,
    required String schoolId,
    XFile? pickedImage,
    Uint8List? pickedImageBytes,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse("http://localhost:3000/instructor/addInstructor"),
      );

      request.fields['instructorId'] = "${DateTime.now().millisecondsSinceEpoch}".substring(3);
      request.fields['instructorBirthday'] = birthday;
      request.fields['instructorEmail'] = email;
      request.fields['instructorGender'] = (gender == 'ชาย' ? '0' : '1');
      request.fields['instructorLname'] = lastName;
      request.fields['instructorName'] = firstName;
      request.fields['instructorTel'] = phone;
      request.fields['schoolId'] = schoolId;
      
      if (pickedImage != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'instructorPicture',
            pickedImageBytes!,
            filename: pickedImage.name,
            contentType: MediaType('image', pickedImage.name.split('.').last),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'instructorPicture',
            pickedImage.path,
            filename: pickedImage.name,
            contentType: MediaType('image', pickedImage.name.split('.').last),
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add instructor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding instructor: $e');
    }
  }

  // New method to update instructor data
  static Future<bool> updateInstructor({
    required String instructorId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String birthday,
    required String gender,
    required String schoolId,
    XFile? pickedImage,
    Uint8List? pickedImageBytes,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT', 
        Uri.parse("http://localhost:3000/instructor/updateInstructor/$instructorId"),
      );

      request.fields['instructorBirthday'] = birthday;
      request.fields['instructorEmail'] = email;
      request.fields['instructorGender'] = (gender == 'ชาย' ? '0' : '1');
      request.fields['instructorLname'] = lastName;
      request.fields['instructorName'] = firstName;
      request.fields['instructorTel'] = phone;
      request.fields['schoolId'] = schoolId;
      
      if (pickedImage != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'instructorPicture',
            pickedImageBytes!,
            filename: pickedImage.name,
            contentType: MediaType('image', pickedImage.name.split('.').last),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'instructorPicture',
            pickedImage.path,
            filename: pickedImage.name,
            contentType: MediaType('image', pickedImage.name.split('.').last),
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update instructor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating instructor: $e');
    }
  }
}
