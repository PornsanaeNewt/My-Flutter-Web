import 'package:flutter/material.dart';
import 'package:project_web/services/custom_app_bar.dart';
import 'package:project_web/widgets/list_course_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/controllers/courseController.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  List<Map<String, dynamic>> _courseTypes = [];
  Set<int> _selectedTypeIds = {};

  int _currentPage = 1;
  int _itemsPerPage = 8;
  int _totalCourses = 0;
  String? schoolID;

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  bool _isLoadingTypes = true;


  @override
  void initState() {
    super.initState();
    _fetchCourseTypes();
    _fetchCourses();
    _searchController.addListener(_filterCourses);
    _minPriceController.addListener(_filterCourses);
    _maxPriceController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCourses);
    _searchController.dispose();
    _minPriceController.removeListener(_filterCourses);
    _maxPriceController.removeListener(_filterCourses);
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourseTypes() async {
    setState(() {
      _isLoadingTypes = true;
    });
    try {
      _courseTypes = await CourseController.fetchCourseTypes();
    } catch (e) {
      print('Error fetching course types: $e');
    } finally {
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolID = prefs.getString('schoolID');

      if (schoolID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบ schoolID')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      _allCourses = await CourseController.fetchCoursesBySchoolId(schoolID);
      _filterCourses();
    } catch (e) {
      print('Error loading courses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deleteCourse(Course course) async {
    try {
      await CourseController.deleteCourse(course);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ "${course.name}" สำเร็จ')),
      );
      _fetchCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ข้อผิดพลาด: $e')),
      );
    }
  }


  void _confirmDelete(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบ "${course.name}" ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCourse(course);
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  void _filterCourses() {
    List<Course> tempCourses = _allCourses;

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      tempCourses = tempCourses.where((course) =>
          course.name!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          course.description!.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    // Filter by course types
    if (_selectedTypeIds.isNotEmpty) {
      tempCourses = tempCourses.where((course) => _selectedTypeIds.contains(course.courseTypeId)).toList();
    }

    // อัปเดต: กรองตามช่วงราคาที่ผู้ใช้กำหนด (Min และ Max)
    final minPriceText = _minPriceController.text;
    final maxPriceText = _maxPriceController.text;

    final double minPrice = double.tryParse(minPriceText) ?? 0.0;
    // กำหนดราคาสูงสุดเป็นอนันต์ ถ้าผู้ใช้ไม่ได้กำหนดค่า Max
    final double maxPrice = double.tryParse(maxPriceText) ?? double.infinity; 

    // ใช้ตัวกรองราคาถ้ามีการป้อนค่า Min หรือ Max
    if (minPrice > 0 || maxPrice != double.infinity) {
        tempCourses = tempCourses.where((course) {
        // ใช้ 0.0 เป็นค่าเริ่มต้น หาก course.price เป็น null
        final double price = course.price?.toDouble() ?? 0.0;
        
        // ตรวจสอบเงื่อนไข Min และ Max
        final bool meetsMin = price >= minPrice;
        final bool meetsMax = price <= maxPrice;

        return meetsMin && meetsMax;

      }).toList();
    }
    
    // ลบ: ส่วนการกรองราคาเดิม

    setState(() {
      _filteredCourses = tempCourses;
      _totalCourses = _filteredCourses.length;
      _currentPage = 1;
    });
  }

  void _onTypeChanged(bool? newValue, int typeId) {
    setState(() {
      if (newValue == true) {
        _selectedTypeIds.add(typeId);
      } else {
        _selectedTypeIds.remove(typeId);
      }
      _filterCourses();
    });
  }
  
  // ลบ: เมธอด _onPriceChanged ถูกลบเนื่องจากเปลี่ยนไปใช้ TextEditingController

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onPreviousPage() {
    setState(() {
      _currentPage--;
    });
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
  }
  
  int get _totalPages {
    if (_totalCourses == 0) return 1;
    return (_totalCourses / _itemsPerPage).ceil();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const CustomAppBar(activeMenu: 'หลักสูตร'),
      body: ListCourseWidget(
        searchController: _searchController,
        courseTypes: _courseTypes,
        selectedTypeIds: _selectedTypeIds,
        onTypeChanged: _onTypeChanged,
        filteredCourses: _filteredCourses,
        isLoading: _isLoading,
        isLoadingTypes: _isLoadingTypes,
        currentPage: _currentPage,
        totalPages: _totalPages,
        onPageChanged: _onPageChanged,
        onPreviousPage: _onPreviousPage,
        onNextPage: _onNextPage,
        onConfirmDelete: _confirmDelete,
        minPriceController: _minPriceController,
        maxPriceController: _maxPriceController,
        onFilterChanged: _filterCourses,
      ),
    );
  }
}