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

  static Future<void> completeAllRegistrations(int scheduleId) async {
    try {
      final http.Response response = await Api.completeStudy(scheduleId);
      if (response.statusCode != 200) {
        throw Exception('Failed to update registrations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating registrations: $e');
      throw Exception('Failed to update data: $e');
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