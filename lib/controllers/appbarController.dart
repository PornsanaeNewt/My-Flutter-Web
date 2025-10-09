import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_web/screens/login_page.dart';
import 'package:project_web/services/SharedPreferences.dart'; 

class AppbarController {
  
  static Future<Map<String, dynamic>?> fetchSchoolData(String schoolId) async {
    final url = Uri.parse('http://localhost:3000/school/getSchoolById/$schoolId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          return responseData[0];
        }
      }
    } catch (e) {
      print('Error fetching school data: $e');
    }
    return null;
  }

  static Future<void> logout(BuildContext context) async {
    await clearSchoolID();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
