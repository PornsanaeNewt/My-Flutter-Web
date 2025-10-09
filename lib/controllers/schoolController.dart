import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:project_web/services/api.dart';
import 'package:project_web/model/School.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class SchoolController {

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied'); 
      }
    }
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<http.Response> submitSchoolRegistration({
    required String schoolName,
    required String schoolEmail,
    required String schoolPassword,
    required String schoolTel,
    required String schoolAddress,
    required String schoolLatitude,
    required String schoolLongitude,
    required String schoolDetail,
    XFile? pickedImage,
    Uint8List? pickedImageBytes,
  }) async {
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/school/addSchool'),
    );

    // Set form fields
    request.fields['schoolID'] = "${DateTime.now().millisecondsSinceEpoch}".substring(3);
    request.fields['schoolName'] = schoolName;
    request.fields['schoolEmail'] = schoolEmail;
    request.fields['schoolPassword'] = schoolPassword;
    request.fields['schoolTel'] = schoolTel;
    request.fields['schoolAddress'] = schoolAddress;
    request.fields['schoolLatitude'] = schoolLatitude;
    request.fields['schoolLongitude'] = schoolLongitude;
    request.fields['schoolDetail'] = schoolDetail;
    request.fields['schoolStatus'] = "wait";

    // Set image file
    if (pickedImage != null) {
      if (kIsWeb && pickedImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'schoolPicture',
            pickedImageBytes,
            filename: pickedImage.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'schoolPicture',
            pickedImage.path,
            filename: pickedImage.name,
          ),
        );
      }
    } else {
      request.fields['schoolPicture'] = '';
    }

    // Send request and return the response
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
  
  static Future<School> fetchSchoolById(String schoolId) async {
    try {
      final response = await Api.getSchoolById(schoolId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];
        return School.fromJson(data);
      } else {
        throw Exception('Failed to load school data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching school data: $e');
    }
  }

  static Future<String?> getSchoolIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('schoolID');
  }

  static Future<void> updateSchool({
    required String schoolId,
    required String schoolName,
    required String schoolEmail,
    required String schoolPassword,
    required String schoolDetail,
    required String schoolAddress,
    required String schoolTel,
    required String schoolStatus,
    required String schoolLatitude,
    required String schoolLongitude,
    XFile? pickedImage,
    Uint8List? pickedImageBytes,
    required bool clearPictureFlag,
  }) async {
    final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'http://localhost:3000/school/updateSchool/$schoolId'));

    request.fields['schoolName'] = schoolName;
    request.fields['schoolEmail'] = schoolEmail;
    request.fields['schoolPassword'] = schoolPassword;
    request.fields['schoolDetail'] = schoolDetail;
    request.fields['schoolAddress'] = schoolAddress;
    request.fields['schoolLatitude'] = schoolLatitude;
    request.fields['schoolLongitude'] = schoolLongitude;
    request.fields['schoolStatus'] = schoolStatus;
    request.fields['schoolTel'] = schoolTel;
    
    if (pickedImage != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'schoolPicture',
          pickedImageBytes!,
          filename: pickedImage.name,
          contentType: MediaType('image', pickedImage.name.split('.').last),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'schoolPicture',
          pickedImage.path,
          filename: pickedImage.name,
          contentType: MediaType('image', pickedImage.name.split('.').last),
        ));
      }
    } else if (clearPictureFlag) {
      request.fields['clearPicture'] = 'true';
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('อัปเดตไม่สำเร็จ: ${response.statusCode} - $responseBody');
    }
  }
}