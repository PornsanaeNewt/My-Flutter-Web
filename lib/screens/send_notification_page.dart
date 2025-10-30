import 'package:flutter/material.dart';
import 'package:project_web/controllers/notificationController.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_web/styles/text-style.dart';

class SendNotificationPage extends StatefulWidget {
  final int scheduleId;

  const SendNotificationPage({super.key, required this.scheduleId});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  List<dynamic> _allRegistrations = []; 
  List<dynamic> _filteredRegistrations = []; 
  Map<String, bool> _selectedStudents = {};
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
    initializeDateFormatting('th_TH', null);
    _fetchRegistrationData();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
  }

  Future<void> _fetchRegistrationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final registrationData =
          await NotificationController.fetchRegistrationData(widget.scheduleId);

      setState(() {
        _allRegistrations = registrationData; 
        _filterRegistrations(); 
        
        for (var reg in _allRegistrations) {
          _selectedStudents[reg['registId'].toString()] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }
  
  void _filterRegistrations() {
    List<dynamic> tempRegist = _allRegistrations;

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
        _filterRegistrations(); 
      });
    }
  }

  void _selectAll(bool? selectAll) {
    setState(() {
      for (var student in _filteredRegistrations) {
        final registId = student['registId'].toString();
        _selectedStudents[registId] = selectAll ?? false;
      }
    });
  }

  void _sendNotifications() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final selectedStudentsData = _filteredRegistrations
        .where((student) {
          final registId = student['registId'].toString();
          return _selectedStudents[registId] == true;
        })
        .map((student) {
          return {
            'registId': student['registId'] as int,
            'stuId': student['stuId'] as String,
          };
        })
        .toList();


    if (selectedStudentsData.isEmpty) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกผู้เรียนอย่างน้อยหนึ่งคน', style: TextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final notiDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()); 

    try {
      for (final studentData in selectedStudentsData) {
        
        final Map<String, dynamic> notificationData = {
          'notiId': 0, 
          'notiDate': notiDate,
          'notiDetails': _detailController.text,
          'notiType': _typeController.text,
          'notiStatus': "unread",
          'registId': studentData['registId'] as int,
          'stuId': studentData['stuId'] as String,
        };

        await NotificationController.addNotification(notificationData); 
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text('ส่งการแจ้งเตือนสำเร็จ', style: TextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
      ));

      _detailController.clear();
      _typeController.clear();
      setState(() {
        _selectedStudents.updateAll((key, value) => false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งการแจ้งเตือน: $e', style: TextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightAccent, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAllFilteredSelected = _filteredRegistrations.isNotEmpty && _filteredRegistrations.every((student) {
      return _selectedStudents[student['registId'].toString()] == true;
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('ส่งการแจ้งเตือน', style: TextStyles.title.copyWith(color: AppColors.primaryBlack, fontSize: 20)),
        backgroundColor: AppColors.formBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Couurse / Course Detail / Reigstrations / Send Notification',
                  style: TextStyles.body.copyWith(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: AppColors.formBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายละเอียดการแจ้งเตือน', style: TextStyles.title.copyWith(fontSize: 22)),
                                  const Divider(height: 2, color: AppColors.inputBorder),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _dateController,
                                          label: 'วันที่',
                                          readOnly: true,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _timeController,
                                          label: 'เวลา',
                                          readOnly: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _typeController,
                                    label: 'ประเภทการแจ้งเตือน (เช่น แจ้งเตือนการเรียน, ยกเลิกคลาส)',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรุณากรอกประเภทการแจ้งเตือน';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField( 
                                    controller: _detailController,
                                    label: 'รายละเอียดการแจ้งเตือน',
                                    // ลด maxLines จาก 8 เป็น 6 เพื่อลดความสูง
                                    maxLines: 6, 
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรุณากรอกรายละเอียดการแจ้งเตือน';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      
                      // 2. Student List (ขวา)
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: AppColors.formBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('รายชื่อผู้เรียน', style: TextStyles.title.copyWith(fontSize: 22)),
                                    // [START] Dropdown Filter
                                    _buildFilterDropdown(),
                                    // [END] Dropdown Filter
                                  ],
                                ),
                                const Divider(height: 30, color: AppColors.inputBorder),

                                // Select All
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isAllFilteredSelected, // ใช้สถานะกรองมาตรวจสอบ
                                        onChanged: _selectAll,
                                        activeColor: AppColors.darkAccent,
                                      ),
                                      Text('เลือกทั้งหมด (${_filteredRegistrations.length} คน)', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
                                    ],
                                  ),
                                ),
                                const Divider(color: AppColors.subtleGray),

                                _isLoading
                                    ? const Expanded(child: Center(child: CircularProgressIndicator()))
                                    : _error != null
                                    ? Expanded(child: Center(child: Text(_error!, style: TextStyles.body.copyWith(color: Colors.red))))
                                    : _filteredRegistrations.isEmpty
                                    ? Expanded(
                                      child: Center(
                                        child: Text(
                                          'ไม่พบผู้เรียนในสถานะ ${_selectedStatus == 'All' ? '' : _selectedStatus}',
                                          style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                                        ),
                                      ),
                                    )
                                    : Expanded(
                                      child: ListView.builder(
                                        itemCount: _filteredRegistrations.length,
                                        itemBuilder: (context, index) {
                                          final student = _filteredRegistrations[index];
                                          final registId = student['registId'].toString();
                                          final fullName = '${student['stuName']} ${student['stuLname']} ${student['stuId']}';

                                          final status = student['registStatus'] ?? 'N/A';
                                          final statusColor = _getStatusColor(status);

                                          return CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(fullName, style: TextStyles.input.copyWith(color: AppColors.primaryBlack)),
                                            subtitle: Text('${student['stuEmail']} (สถานะ: $status)', style: TextStyles.body.copyWith(color: statusColor)),
                                            value: _selectedStudents[registId],
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                _selectedStudents[registId] = newValue ?? false;
                                              });
                                            },
                                            activeColor: AppColors.darkAccent,
                                          );
                                        },
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // ส่วนปุ่มควบคุมที่ย้ายมาอยู่ขวาล่างของหน้าจอ
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.formBackground,
          border: const Border(top: BorderSide(color: AppColors.inputBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                side: const BorderSide(color: AppColors.mutedBrown),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'ยกเลิก',
                style: TextStyles.button.copyWith(color: AppColors.mutedBrown, fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _sendNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
              ),
              child: Text(
                'ส่งการแจ้งเตือน',
                style: TextStyles.button.copyWith(color: AppColors.buttonText, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับปุ่ม Dropdown Filter
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: Icon(Icons.filter_list, color: AppColors.mutedBrown),
          style: TextStyles.body.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.w500),
          dropdownColor: AppColors.formBackground,
          items: _allStatuses.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: _onStatusChanged,
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.blue.shade700;
      case 'payment completed':
        return Colors.orange.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancel':
        return Colors.red.shade700;
      case 'reviewed':
        return AppColors.mutedBrown;
      default:
        return AppColors.secondaryText;
    }
  }
}