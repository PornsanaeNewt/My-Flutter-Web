import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_web/styles/text-style.dart' ;

class HomePageForm extends StatefulWidget {
  const HomePageForm({super.key});

  @override
  State<HomePageForm> createState() => _HomePageFormState();
}

class _HomePageFormState extends State<HomePageForm> {
  String? schoolID;

  @override
  void initState() {
    super.initState();
    loadSchoolID();
  }

  Future<void> loadSchoolID() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('schoolID');
    setState(() {
      schoolID = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome, School ID: ${schoolID ?? "-"}',
            style: TextStyles.title.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
