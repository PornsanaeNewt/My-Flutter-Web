import 'dart:convert';
import 'package:project_web/model/Notifications.dart';
import 'package:project_web/services/api.dart';

class NotificationController {
  
  static Future<List<dynamic>> fetchRegistrationData(int scheduleId) async {
    try {
      final response = await Api.listRegistBySchedule(scheduleId);
      if (response.statusCode != 200) {
        throw Exception('Failed to load registrations: ${response.body}');
      }
      final List<dynamic> registrationData = jsonDecode(response.body);
      return registrationData;
    } catch (e) {
      throw Exception('Error loading data: $e');
    }
  }

  static Future<void> addNotification(Notifications notification) async {
    try {
      final response = await Api.addNotification(notification.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }
}