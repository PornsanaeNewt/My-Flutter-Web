import 'package:flutter/material.dart';
import 'package:project_web/controllers/schoolController.dart';
import 'package:project_web/model/School.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/widgets/school_detail_widget.dart';

class SchoolDetailPage extends StatefulWidget {
  final String? schoolID;

  const SchoolDetailPage({super.key, required this.schoolID});

  @override
  State<SchoolDetailPage> createState() => _SchoolDetailPageState();
}

class _SchoolDetailPageState extends State<SchoolDetailPage> {
  School? _schoolData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSchool();
  }

  Future<void> _fetchSchool() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.schoolID == null) {
        setState(() {
          _error = 'School ID is missing.';
          _isLoading = false;
        });
        return;
      }
      final schoolData = await SchoolController.fetchSchoolById(widget.schoolID!);
      setState(() {
        _schoolData = schoolData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching school data: $e';
        _isLoading = false;
      });
      print('Error fetching school data: $e');
    }
  }
  
  void _onEditComplete(bool result) {
    if (result) {
      _fetchSchool();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดโรงเรียน', style: TextStyles.title.copyWith(color: AppColors.primaryText)),
        backgroundColor: AppColors.formBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ListCoursePage()),
          ),
        ),
      ),
      backgroundColor: AppColors.primaryBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: TextStyles.body.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _schoolData != null
                  ? SchoolDetailWidget(
                      schoolData: _schoolData!,
                      onEditComplete: (result) => _onEditComplete(result),
                    )
                  : const SizedBox.shrink(),
    );
  }
}