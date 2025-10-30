import 'dart:convert';
import 'package:project_web/model/School.dart';
import 'package:project_web/services/SharedPreferences.dart'; 
import 'package:project_web/services/api.dart'; 

class LoginController {
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await Api.login(email, password);

      print('Login response status code: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        print('Login Data: ${data}');

        if (data.isEmpty) {
          return null; 
        }
        
        final school = School.fromJson(data[0]);

        if (school.schoolPassword == password) {
          
          if (school.schoolStatus == 'active') {
            if (school.schoolId != null) {
              await saveSchoolID(school.schoolId!);
              return data[0].cast<String, dynamic>();
            }
          } else if (school.schoolStatus == 'wait') {
            return {'error': 'wait_for_approval'};
          }
        }
      } 
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

}
