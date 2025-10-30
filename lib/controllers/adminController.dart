import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_web/model/School.dart';
import 'package:project_web/services/api.dart';

class AdminController {

  List<School> _allSchools = []; 
  List<School> _pendingSchools = []; 
  bool _isLoading = false;
  String _errorMessage = '';

  List<School> get allSchools => _allSchools; 
  List<School> get pendingSchools => _pendingSchools;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  static Future<List<School>> fetchSchools() async {
    try {
      final http.Response response = await Api.listAllSchools(); 

      print("All School :${response.body}");

      if (response.statusCode == 200) {
        final schoolData = json.decode(response.body) as List<dynamic>;
        return schoolData.map((json) => School.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schools: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during API call: $e');
    }
  }

  static Future<void> updateSchoolStatus(String schoolId, String schoolStatus) async {
    try {
      final http.Response response = await Api.updateSchoolStatus(
        schoolId,
        schoolStatus,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  static Future<List<dynamic>?> listAdmin() async {
    try {
      final response = await Api.listAdmin();

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        print('Failed to load admin list. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error listing admins: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAdmin(String id) async {
    try {
      final response = await Api.getAdmin(id);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load admin details for ID $id. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting admin details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> adminLogin(String email, String password) async {
    try {
      final response = await Api.getAdminByEmail(email);
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        if (results.isEmpty) {
          return null; 
        }
        final adminData = results.first;
        if (adminData['password'] == password) { 
          return adminData;
        } else {
          return null;
        }
      } else {
        print('Admin Login API failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during Admin Login: $e');
      return null;
    }
  }

}