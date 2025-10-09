import 'package:flutter/material.dart';
import 'package:project_web/services/custom_app_bar.dart'; 
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/screens/add_instructor_page.dart';
import 'package:project_web/screens/edit_instructor_page.dart';
import 'package:project_web/controllers/instructorController.dart';
import 'package:project_web/widgets/list_instructor_widget.dart';
import 'package:project_web/styles/text-style.dart'; 

class ListInstructorPage extends StatefulWidget {
  const ListInstructorPage({super.key});

  @override
  State<ListInstructorPage> createState() => _ListInstructorPageState();
}

class _ListInstructorPageState extends State<ListInstructorPage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> instructors = [];
  List<dynamic> filteredInstructors = [];
  bool isLoading = true;
  int currentPage = 1;
  int itemsPerPage = 7;
  int totalPages = 1;
  String? schoolID;

  @override
  void initState() {
    super.initState();
    _loadInstructors();
    searchController.addListener(_searchInstructors);
  }

  @override
  void dispose() {
    searchController.removeListener(_searchInstructors);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    setState(() => isLoading = true);
    try {
      schoolID = await InstructorController.getSchoolID();
      if (schoolID == null) {
        throw Exception('School ID not found.');
      }
      final loadedInstructors = await InstructorController.loadInstructorsBySchool(schoolID!);
      setState(() {
        instructors = loadedInstructors.map((e) => e.toJson()).toList();
        filteredInstructors = instructors;
        isLoading = false;
        _updatePagination();
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error loading instructors: $e', Colors.red);
    }
  }

  void _updatePagination() {
    totalPages = (filteredInstructors.length / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
  }

  void _searchInstructors() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredInstructors = instructors;
      } else {
        filteredInstructors = instructors.where((instructor) {
          final fullName = '${instructor['instructorName']} ${instructor['instructorLname']}'.toLowerCase();
          final email = instructor['instructorEmail']?.toLowerCase() ?? '';
          final tel = instructor['instructorTel']?.toLowerCase() ?? '';
          return fullName.contains(query) ||
              email.contains(query) ||
              tel.contains(query);
        }).toList();
      }
      currentPage = 1;
      _updatePagination();
    });
  }

  void _onAddInstructor() async {
    if (schoolID != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddInstructorPage(schoolID: schoolID!)),
      );
      if (result == true) {
        _loadInstructors();
      }
    } else {
      _showSnackBar('ไม่พบ School ID. กรุณาเข้าสู่ระบบอีกครั้ง.', Colors.red);
    }
  }

  void _onEditInstructor(String instructorId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInstructorPage(instructorId: instructorId),
      ),
    );
    if (result == true) {
      _loadInstructors();
    }
  }

  Future<void> _deleteInstructor(Map<String, dynamic> instructor) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ', style: TextStyles.title.copyWith(fontSize: 18)),
          content: Text('คุณต้องการลบผู้สอน ${instructor['instructorName']} ${instructor['instructorLname']} ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton( 
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await InstructorController.deleteInstructor(instructor['instructorId']);
                  _showSnackBar('ลบผู้สอน "${instructor['instructorName']}" สำเร็จ', Colors.green);
                  _loadInstructors();
                } catch (e) {
                  _showSnackBar('เกิดข้อผิดพลาดขณะลบ: $e', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void _showSnackBar(String message, [Color backgroundColor = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground, 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: CustomAppBar(
          activeMenu: 'ผู้สอน',
        ),
      ),
      body: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1450),
          child: ListInstructorWidget(
            searchController: searchController,
            isLoading: isLoading,
            filteredInstructors: filteredInstructors,
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: _onPageChanged,
            onSearch: (value) => _searchInstructors(),
            onAddInstructor: _onAddInstructor,
            onDeleteInstructor: _deleteInstructor,
            onEditInstructor: _onEditInstructor,
          ),
        ),
      ),
    );
  }
}