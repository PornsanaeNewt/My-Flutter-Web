import 'dart:convert';
import 'package:project_web/services/api.dart';
import 'package:http/http.dart' as http;

class RegistrationController {

  static Future<List<Map<String, dynamic>>> fetchRegistrationData(int scheduleId) async {
    try {
      final response = await Api.listRegistBySchedule(scheduleId);
      if (response.statusCode != 200) {
        throw Exception('Failed to load registrations: ${response.statusCode}');
      }

      final List<dynamic> registrationData = jsonDecode(response.body);
      
      return registrationData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching registration and student data: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<void> sendNotification(int scheduleId) async {
    print('Sending notifications for schedule ID: $scheduleId');
    await Future.delayed(const Duration(seconds: 1));
  }
  
  static Future<void> editRegistration(int registId) async {
    print('Editing registration ID: $registId');
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> completeRegistration(int scheduleId, String stuId) async {
    try {
      final http.Response response = await Api.completeStudy(scheduleId, stuId); 
      if (response.statusCode != 200) {
        throw Exception('Failed to complete registration: ${response.statusCode}. Body: ${response.body}');
      }
      print('Successfully completed registration for StuId: $stuId');
    } catch (e) {
      print('Error completing registration: $e');
      throw Exception('Failed to update data: $e');
    }
  }
  
  static Future<void> startRegistration(int scheduleId, String stuId) async {
    try {
      final http.Response response = await Api.startStudy(scheduleId, stuId); 
      if (response.statusCode != 200) {
        throw Exception('Failed to start registration: ${response.statusCode}. Body: ${response.body}');
      }
      print('Successfully started registration for StuId: $stuId');
    } catch (e) {
      print('Error starting registration: $e');
      throw Exception('Failed to update data: $e');
    }
  }

  static Future<String> getStudentIdByRegist(int registId) async {
    try {
      final http.Response response = await Api.getStudentByRegist(registId); 
      if (response.statusCode != 200) {
        throw Exception('Failed to get student ID for regist ID $registId: ${response.statusCode}. Body: ${response.body}');
      }
      
      final dynamic decodedData = jsonDecode(response.body);
      
      Map<String, dynamic> data;
      if (decodedData is List && decodedData.isNotEmpty) {
        data = decodedData[0] as Map<String, dynamic>; 
      } else if (decodedData is Map<String, dynamic>) {
        data = decodedData; 
      } else {
        throw Exception('Invalid data format received from API for regist ID $registId.');
      }

      final String stuId = data['stuId'] as String? ?? '';
      
      if (stuId.isEmpty) {
        throw Exception('stuId not found in the response data for regist ID $registId.');
      }
      return stuId;
    } catch (e) {
      print('Error fetching student ID for regist ID $registId: $e');
      throw Exception('Failed to get student ID for registration: ${e.toString()}');
    }
  }

  static Future<void> deleteRegistration(int registId) async {
    try {
      final http.Response response = await Api.deleteRegistration(registId);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete registration: ${response.statusCode}');
      }
      print('Successfully deleted registration ID: $registId');
    } catch (e) {
      print('Error deleting registration: $e');
      throw Exception('Failed to delete registration: $e');
    }
  }
}