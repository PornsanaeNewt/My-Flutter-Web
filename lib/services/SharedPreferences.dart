import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSchoolID(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('schoolID', id);
}

Future<String?> getSchoolID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('schoolID');
}

Future<void> clearSchoolID() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('schoolID');
}

