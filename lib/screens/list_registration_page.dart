import 'package:flutter/material.dart';
import 'package:project_web/controllers/registrationController.dart';
import 'package:project_web/screens/send_notification_page.dart';
import 'package:project_web/widgets/list_registration_widget.dart'; 
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';

class ListRegistrationPage extends StatefulWidget {
  final int scheduleId;

  const ListRegistrationPage({
    super.key,
    required this.scheduleId,
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
  
  final List<String> _allStatuses = [
    'All', 
    'In progress', 
    'Payment completed', 
    'Completed', 
    'Cancel', 
    'Reviewed'
  ];
  String _selectedStatus = 'All'; 

  @override
  void initState() {
    super.initState();
    _fetchRegistrationData();
    _searchController.addListener(_filterRegistration);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRegistration);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRegistrationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Map<String, dynamic>> registrationData = 
          await RegistrationController.fetchRegistrationData(widget.scheduleId);

      setState(() {
        _allRegistrations = registrationData;
        _filterRegistration();
        _isLoading = false;
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isLoading = false;
      });
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
    if (registStatus.toLowerCase() != 'cancel') {
      _showSnackBar('ไม่สามารถลบข้อมูลได้: สถานะผู้ลงทะเบียนต้องเป็น "Cancel" เท่านั้น', Colors.red.shade700);
      return; 
    }
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text('ยืนยันการลบข้อมูล', style: TextStyles.title.copyWith(fontSize: 18)),
                content: const Text(
                    'คุณแน่ใจหรือไม่ที่จะลบข้อมูลผู้ลงทะเบียนนี้?'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton( 
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ยืนยัน'),
                    ),
                ],
            );
        },
    );

    if (confirmed == true) {
        try {
            await RegistrationController.deleteRegistration(registId);
            _showSnackBar('ลบข้อมูลสำเร็จ', Colors.green.shade700);
            _fetchRegistrationData();
        } catch (e) {
            _showSnackBar('เกิดข้อผิดพลาดในการลบข้อมูล: $e', Colors.red.shade700);
        }
    }
  }
  
  Future<void> _completeAllRegistrations() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text('ยืนยันการเสร็จสิ้นหลักสูตร', style: TextStyles.title.copyWith(fontSize: 18)),
                content: const Text(
                    'คุณต้องการเสร็จสิ้นหลักสูตรสอนทำอาหารนี้หรือไม่'),
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
            await RegistrationController.completeAllRegistrations(widget.scheduleId);
            _showSnackBar('แก้ไขสถานะผู้ลงทะเบียนสำเร็จ', Colors.green.shade700);
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
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('รายชื่อผู้ลงทะเบียน', style: TextStyles.title.copyWith(color: AppColors.primaryBlack, fontSize: 20)),
        backgroundColor: AppColors.formBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        actions: const [],
      ),
      body: ListRegistrationWidget(
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
      floatingActionButton: FloatingActionButton.extended(
            onPressed: _completeAllRegistrations,
            icon: const Icon(Icons.done_all),
            label: const Text('เสร็จสิ้นหลักสูตร'),
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.buttonText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
        ),
    );
  }
}