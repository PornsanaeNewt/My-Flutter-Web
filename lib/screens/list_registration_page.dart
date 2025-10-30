import 'package:flutter/material.dart';
import 'package:project_web/controllers/registrationController.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/model/CourseDetail.dart'; 
import 'package:project_web/screens/send_notification_page.dart';
import 'package:project_web/widgets/list_registration_widget.dart'; 
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/widgets/countdow_widget.dart'; 

class ListRegistrationPage extends StatefulWidget {
  final int scheduleId;
  final String courseId;

  const ListRegistrationPage({
    super.key,
    required this.scheduleId,
    required this.courseId,
  });

  @override
  State<ListRegistrationPage> createState() => _ListRegistrationPageState();
}

class _ListRegistrationPageState extends State<ListRegistrationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allRegistrations = [];
  List<dynamic> _filteredRegistrations = [];
  bool _isLoading = true;
  String? _error;
  
  String _startDate = ''; 
  String _endDate = '';   
  bool _isCourseManuallyCompleted = false;
  
  final List<String> _allStatuses = [
    'All', 
    'In progress', 
    'Payment completed', 
    'Completed', 
    'Reviewed'
  ];
  String _selectedStatus = 'All'; 

  @override
  void initState() {
    super.initState();
    _fetchPageData(); 
    _searchController.addListener(_filterRegistration);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRegistration);
    _searchController.dispose();
    super.dispose();
  }
  
  void _handleCountdownComplete() {
    if (mounted) {
      setState(() {
        _isCourseManuallyCompleted = true; 
      });
      _showSnackBar('หลักสูตรเสร็จสิ้นโดยอัตโนมัติเนื่องจากหมดเวลา', Colors.orange.shade700);
      
      try {
        CourseController.openAndCloseSchedule(widget.scheduleId, 'close');
        print('Schedule status set to close after auto-complete.');
      } catch (e) {
        print('Error setting schedule status to close: $e');
      }
    }
  }
  
  Future<void> _fetchPageData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _fetchCourseDetail();
      await _fetchRegistrationData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดข้อมูลทั้งหมด: $e');
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isLoading = false; 
      });
    }
  }

  Future<void> _fetchCourseDetail() async {
      try {
        final List<CourseDetail> courseDetails = await CourseController.fetchCourseDetails(widget.courseId);

        final CourseDetail targetSchedule = courseDetails.firstWhere(
            (detail) => detail.id == widget.scheduleId,
            orElse: () => throw Exception('Schedule ID ${widget.scheduleId} not found in course details.'),
        );

        final String formattedStartDate = targetSchedule.startDate.split('T').first;
        final String formattedEndDate = targetSchedule.endDate.split('T').first;
        
        setState(() {
          _startDate = formattedStartDate;
          _endDate = formattedEndDate;
          
          final String status = targetSchedule.scheduleStatus.toLowerCase();
          if (status == 'completed' || status == 'close') {
             _isCourseManuallyCompleted = true;
          } else {
             _isCourseManuallyCompleted = false;
          }
        });
        
      } catch (e) {
        throw Exception('Failed to fetch course details for countdown: $e');
      }
  }
  
  Future<void> _fetchRegistrationData() async {
    try {
      final List<Map<String, dynamic>> registrationData = 
          await RegistrationController.fetchRegistrationData(widget.scheduleId); 

      _allRegistrations = registrationData;
      _filterRegistration();
      
    } catch (e) {
      throw Exception('Failed to load registration data: $e');
    }
  }

  void _filterRegistration() {
    List<dynamic> tempRegist = _allRegistrations;

    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      tempRegist = tempRegist.where((registrationMap) {
        final fullName = '${registrationMap['stuName']?.toLowerCase() ?? ''} ${registrationMap['stuLname']?.toLowerCase() ?? ''}';
        return fullName.contains(searchTerm);
      }).toList();
    }

    if (_selectedStatus != 'All') {
      tempRegist = tempRegist.where((registrationMap) {
        final registStatus = registrationMap['registStatus'] as String? ?? '';
        return registStatus.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    setState(() {
      _filteredRegistrations = tempRegist;
    });
  }
  
  void _onStatusChanged(String? newStatus) {
    if (newStatus != null) {
      setState(() {
        _selectedStatus = newStatus;
        _filterRegistration(); 
      });
    }
  }

  Future<void> _deleteRegistration(int registId, String registStatus) async {
    print('Delete registration function called but disabled (ID: $registId, Status: $registStatus).');
    _showSnackBar('ฟังก์ชันลบรายการถูกปิดใช้งานเนื่องจากคอลัมน์ "จัดการ" ถูกนำออก', Colors.grey);
    return;
  }
  
  Future<void> _completeAllRegistrations() async {
    if (_allRegistrations.isEmpty) return; 

    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text('ยืนยันการเสร็จสิ้นหลักสูตร', style: TextStyles.title.copyWith(fontSize: 18)),
                content: const Text(
                    'คุณต้องการเสร็จสิ้นหลักสูตรนี้หรือไม่'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          foregroundColor: AppColors.buttonText,
                        ),
                        child: const Text('ยืนยัน'),
                    ),
                ],
            );
        },
    );

    if (confirmed == true) {
        setState(() {
            _isLoading = true;
        });
        try {
            final List<int> allRegistIds = _allRegistrations
                .map((reg) => reg['registId'] as int)
                .toList();
                
            for (final registId in allRegistIds) {
                final String stuId = await RegistrationController.getStudentIdByRegist(registId);
                await RegistrationController.completeRegistration(widget.scheduleId, stuId); 
            }
            
            await CourseController.openAndCloseSchedule(widget.scheduleId, 'close');
            
            setState(() {
                _isCourseManuallyCompleted = true; 
            });
            
            _showSnackBar('หลักสูตรเสร็จสิ้นสมบูรณ์', Colors.green.shade700);
            _fetchRegistrationData(); 
        } catch (e) {
            _showSnackBar('เกิดข้อผิดพลาดในการแก้ไขสถานะ: $e', Colors.red.shade700);
        } finally {
            setState(() {
                _isLoading = false;
            });
        }
    }
  }

  void _sendNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendNotificationPage(scheduleId: widget.scheduleId),
      ),
    );
  }
  
  void _showSnackBar(String message, [Color backgroundColor = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDateDataReady = _startDate.isNotEmpty && _endDate.isNotEmpty;
    final bool isButtonDisabled = _isCourseManuallyCompleted || _allRegistrations.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('รายชื่อผู้ลงทะเบียน', style: TextStyles.title.copyWith(color: AppColors.primaryBlack, fontSize: 20)),
        backgroundColor: AppColors.formBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDateDataReady) 
              ScheduleCountdownWidget(
                scheduleId: widget.scheduleId,
                startDate: _startDate, 
                endDate: _endDate,
                isManuallyCompleted: _isCourseManuallyCompleted,
                onCountdownComplete: _handleCountdownComplete, 
              ),
            
            if (!isDateDataReady)
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else 
              const SizedBox(height: 20),
            
            Expanded(
              child: ListRegistrationWidget(
                searchController: _searchController,
                filteredRegistrations: _filteredRegistrations,
                isLoading: _isLoading,
                error: _error, 
                onSendNotification: _sendNotification,
                onDeleteRegistration: _deleteRegistration,
                onSearchChanged: _filterRegistration,
                allStatuses: _allStatuses,
                selectedStatus: _selectedStatus,
                onStatusChanged: _onStatusChanged,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: isButtonDisabled ? null : _completeAllRegistrations,
            icon: const Icon(Icons.done_all),
            label: const Text('เสร็จสิ้นหลักสูตร'),
            backgroundColor: isButtonDisabled ? Colors.grey : AppColors.primaryButton,
            foregroundColor: AppColors.buttonText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
        ),
    );
  }
}